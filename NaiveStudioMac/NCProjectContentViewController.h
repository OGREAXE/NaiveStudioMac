//
//  NCProjectContentViewController.h
//  NaiveC
//
//  Created by 梁志远 on 31/12/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NCScriptInterpretor.h"

@class NCProject;

@interface NCProjectContentViewController : NSViewController
@property  (nonatomic) NCProject * project;
//@property (nonatomic) NCInterpretorMode mode;
@end
