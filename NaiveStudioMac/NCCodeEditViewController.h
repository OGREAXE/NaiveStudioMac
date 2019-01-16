//
//  NCCodeEditViewController.h
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/15.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NCProjectManager.h"
#import "NCInterpreterController.h"
#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCCodeEditViewController : NSViewController
@property (nonatomic) NCSourceFile * sourceFile;

@property (nonatomic) NCProject * project;

@property (nonatomic) NCInterpretorMode mode;

@property (nonatomic) NCInterpreterController * interpreter;
@end

NS_ASSUME_NONNULL_END
