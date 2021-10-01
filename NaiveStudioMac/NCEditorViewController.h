//
//  NCEditorViewController.h
//  NaiveC
//
//  Created by 梁志远 on 16/09/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NCProjectManager.h"
#import "NCScriptInterpreter.h"
#import "Common.h"

@interface NCEditorViewController : NSViewController

@property (nonatomic) NCSourceFile * sourceFile;

@property (nonatomic) NCProject * project;

@property (nonatomic) NCInterpretorMode mode;

@property (nonatomic) NCScriptInterpreter * interpreter;

@end

