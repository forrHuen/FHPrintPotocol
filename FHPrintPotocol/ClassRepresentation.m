//
//  ClassRepresentation.m
//  FHPrintPotocol
//
//  Created by pccw on 7/11/2019.
//  Copyright © 2019 pccw. All rights reserved.
//

#import "ClassRepresentation.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
@implementation ClassRepresentation

+(void)printImplementationClassOfProtocol:(Protocol *)protocol{
    NSLog(@"");
    NSLog(@"Current Protocol = %@",NSStringFromProtocol(protocol));
    NSArray *classes = [ClassRepresentation bundleOwnClassesInfo];
    for (Class cls in classes) {
        if (class_conformsToProtocol(cls,protocol)) {
            NSLog(@"-%@",cls);
        }
    }
    NSLog(@"");
}

+(void)printHierarchyClass:(Class)cls{
    NSLog(@"");
    [ClassRepresentation printSuperClass:cls];
    [ClassRepresentation printSubClass:cls];
    NSLog(@"");
}

+(void)printSuperClass:(Class )cls{
    
    NSMutableArray *superClassList = [NSMutableArray array];
    [ClassRepresentation currentClass:cls superClassList:superClassList];
    
    for (int i = (int)superClassList.count-1; i >= 0; i--) {
        NSLog(@"+%@",superClassList[i]);
    }
}

+(void)currentClass:(Class )cls superClassList:(NSMutableArray *)classList{
    Class superClass = class_getSuperclass(cls);
    if (superClass != nil){
        [classList addObject:NSStringFromClass(superClass)];
        [ClassRepresentation currentClass:superClass superClassList:classList];
    }
}

+(void)printSubClass:(Class )cls{
    NSArray *classes = [ClassRepresentation bundleOwnClassesInfo];
    ClassRepresentation *classRepresentation = [ClassRepresentation representationOfClass:cls allClasses:classes];
    
    [ClassRepresentation recursivelyPrintClassRepresentation:classRepresentation indentationLevel:0];
}

+(void)recursivelyPrintClassRepresentation:(ClassRepresentation *)classRepresentation
                          indentationLevel:(int)indentationLevel{
    if (classRepresentation == nil) {
        return;
    }
    NSString *currentClassRepresentation = @"";
    for (int i=0; i<indentationLevel; i++) {
        currentClassRepresentation = [@"    " stringByAppendingString:currentClassRepresentation];
    }
    
    currentClassRepresentation = [currentClassRepresentation stringByAppendingString:[NSString stringWithFormat:@"* %@",classRepresentation.name]];
    
    NSLog(@"%@",currentClassRepresentation);
    for (ClassRepresentation *subclassRepresentation in classRepresentation.subclassesRepresentations) {
        [ClassRepresentation recursivelyPrintClassRepresentation:subclassRepresentation indentationLevel:indentationLevel+1];
    }
}

+ (ClassRepresentation *)representationOfClass:(Class)class allClasses:(NSArray<ClassRepresentation *> *)allClasses
{
    ClassRepresentation *classRepresentation = [[ClassRepresentation alloc] init];
    
    classRepresentation.name = NSStringFromClass(class);
    
    // Add the representation of the subclasses
    NSMutableArray *subclassesArray = [NSMutableArray array];
    for (Class cls in allClasses) {
        Class superClass = class_getSuperclass(cls);
        if (superClass == class) {
            [subclassesArray addObject:[ClassRepresentation representationOfClass:cls allClasses:allClasses]];
        }
    }
    classRepresentation.subclassesRepresentations = subclassesArray;
    
    return classRepresentation;
}

+ (NSArray <Class> *)bundleOwnClassesInfo{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    unsigned int classCount;
    const char **classes;
    Dl_info info;
    
    dladdr(&_mh_execute_header, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &classCount);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *className = [NSString stringWithCString:classes[index] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        [resultArray addObject:class];
        dispatch_semaphore_signal(semaphore);
    });
    
    return resultArray.mutableCopy;
}

/**
 获取当前工程下所有类（含系统类、cocoPods类）
 
 @return 数组
 */
+ (NSArray <NSString *> *)bundleAllClassesInfo{
    NSMutableArray *resultArray = [NSMutableArray new];
    
    int classCount = objc_getClassList(NULL, 0);
    
    Class *classes = NULL;
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) *classCount);
    classCount = objc_getClassList(classes, classCount);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        Class class = classes[index];
        NSString *className = [[NSString alloc] initWithUTF8String: class_getName(class)];
        [resultArray addObject:className];
        dispatch_semaphore_signal(semaphore);
    });
    
    free(classes);
    
    return resultArray.mutableCopy;
}


@end
