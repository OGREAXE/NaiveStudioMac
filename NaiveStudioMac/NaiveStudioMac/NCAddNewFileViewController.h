//
//  NCAddNewFileViewController.h
//  NaiveC
//
//  Created by 梁志远 on 01/01/2018.
//  Copyright © 2018 Ogreaxe. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NCProjectManager.h"

@class NCAddNewFileViewController;
@class NCEditorViewController;

@protocol NCAddNewFileViewControllerDelegate<NSObject>

//-(void)addNewFileViewController:(NCAddNewFileViewController*)addNewController willPushtoEditController:(NCEditorViewController*)editController;

-(void)addNewFileViewController:(NCAddNewFileViewController*)addNewController didAddFile:(NCSourceFile*)file;

@end

@interface NCAddNewFileViewController : NSViewController
@property (nonatomic) NCProject * currentProject;
@property (nonatomic,weak) id<NCAddNewFileViewControllerDelegate> delegate;
@end
