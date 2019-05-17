//
//  NSViewController+NCExtension.h
//  NaiveC
//
//  Created by 梁志远 on 01/01/2018.
//  Copyright © 2018 Ogreaxe. All rights reserved.
//

#import <AppKit/AppKit.h>

typedef void (^AlertComfirmHandler) (void);

@interface NSViewController (NCExtension)

-(void)ShowAlert:(NSString * )content comfirmHandler:(AlertComfirmHandler)handler;

@end
