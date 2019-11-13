//
//  ViewController.m
//  FHPrintPotocol
//
//  Created by pccw on 13/11/2019.
//  Copyright © 2019 pccw. All rights reserved.
//

#import "ViewController.h"
#import "ClassRepresentation.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ClassRepresentation printImplementationClassOfProtocol:@protocol(UITableViewDelegate)];
    [ClassRepresentation printHierarchyClass:[UIResponder class]];
}


@end
