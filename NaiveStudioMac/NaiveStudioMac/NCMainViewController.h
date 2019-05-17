//
//  NCMainViewController.h
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/2/26.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NCMainViewController : NSViewController

@property (nonatomic) BOOL isPresented;

@property (nonatomic,weak) NSWindowController * mainWindowController;

@end
