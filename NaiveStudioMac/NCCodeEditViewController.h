//
//  NCCodeEditViewController.h
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/15.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NCProjectManager.h"
#import "NCScriptInterpretor.h"
#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCCodeEditViewController : NSViewController
@property (nonatomic) NCSourceFile * sourceFile;

@property (nonatomic) NCProject * project;

@property (nonatomic) NCInterpretorMode mode;

@property (nonatomic) NCScriptInterpretor * interpreter;

@property (nonatomic) NSViewController * lastViewController;

@end

NS_ASSUME_NONNULL_END
