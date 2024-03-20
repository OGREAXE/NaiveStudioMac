//
//  AppDelegate.m
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/10.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "AppDelegate.h"
#import "NCMainViewController.h"
#import "NCRemoteManager.h"

@interface AppDelegate ()
@property (nonatomic) NSWindowController * mainWinController;
@property (nonatomic) NSWindow* mainWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _mainWindow = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable backing:NSBackingStoreBuffered defer:NO];

    NCMainViewController * initialViewController = [[NCMainViewController alloc] init];
    
    _mainWindow.contentViewController = initialViewController;
    
    _mainWinController = [[NSWindowController alloc] initWithWindow:_mainWindow];
    [_mainWinController showWindow:nil];
    
    initialViewController.mainWindowController = _mainWinController;
    [_mainWindow center];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onNaiveCodeFromXcode:) name:@"NaiveCodeFromXcode" object:nil];
}

#pragma mark patch 10.220.15.0
- (void)onNaiveCodeFromXcode:(NSNotification *)not {
    NSLog(@"onNaiveCodeFromXcode %@", not.object);
    
    NSString *patchText = not.object;
    
    if (!patchText.length)return;
    
    NSString *commandText = [NSString stringWithFormat:@"%@%@", @"?NAIVE_PATCH?", patchText];
    
    [[NCRemoteManager sharedManager] sendCommandText:commandText  executionResult:^(id  _Nonnull response, NSError * _Nonnull error) {
            
        }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
