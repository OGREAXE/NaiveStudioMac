//
//  Common.h
//  NaiveC
//
//  Created by Liang,Zhiyuan(GIS) on 2017/12/26.
//  Copyright © 2017年 Ogreaxe. All rights reserved.
//

#ifndef Common_h
#define Common_h

#include "NCConsole.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

//#import "ViewController+NCExtension.h"

typedef NS_ENUM(NSUInteger, NCInterpretorMode) {
    NCInterpretorModeModular = 0,
    NCInterpretorModeCommandLine,
};

#define SAFE_RELEASE(p) if(p){delete p;p=nullptr;}

#define MainStoryBoardName @"NaiveStudio"

//c-style common function declaration start here
#if defined __cplusplus
extern "C" {
#endif

NSColor * colorWithRGBHexString(NSString *inColorString);

#if defined __cplusplus
};
#endif



#endif /* Common_h */
