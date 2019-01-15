//
//  ViewController.m
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/10.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "ViewController.h"
#import "NCMainViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NCMainViewController * controller = [[NCMainViewController alloc] init];
    self.view.window.contentViewController = controller;
//    [self presentViewControllerAsModalWindow:controller];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
