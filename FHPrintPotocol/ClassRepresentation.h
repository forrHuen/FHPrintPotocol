//
//  ClassRepresentation.h
//  FHPrintPotocol
//
//  Created by pccw on 7/11/2019.
//  Copyright © 2019 pccw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * Object used to represent a class in the hierarchy. Contains a name and an
 * array of subclasses.
 *
 * It's a DTO.
 */
@interface ClassRepresentation : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<ClassRepresentation *> *subclassesRepresentations;

+(void)printImplementationClassOfProtocol:(Protocol *)protocol;
+(void)printHierarchyClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
