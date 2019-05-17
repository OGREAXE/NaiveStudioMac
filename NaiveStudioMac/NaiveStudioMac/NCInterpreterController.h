//
//  NCInterpreterController.h
//  NaiveC
//
//  Created by Liang,Zhiyuan(GIS) on 2017/12/25.
//  Copyright © 2017年 Ogreaxe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCDataSource.h"
//#import <NaiveC/NCCodeEngine_iOS.h>
#import "NCProject.h"

@class NCInterpreterController;

@protocol NCInterpreterControllerDelegate<NSObject>

-(void)interpreterController:(NCInterpreterController*)controller didFinishParsingDataSource:(NCDataSource*)dataSource WithParser:(void*)parser;

//-(void)didFinishParsing:(NCInterpreterController*)controller;

@end

@interface NCInterpreterController : NSObject<NCDataSourceDelegate>

@property (nonatomic) id<NCInterpreterControllerDelegate> delegate;

//@property (nonatomic) NCInterpretorMode mode;

@property (nonatomic) NCProject * project;

-(BOOL)reinterprete;

-(BOOL)runProject;

-(BOOL)runWithDataSource:(NCDataSource*)source;

-(BOOL)reparse;

-(void)markDirty:(NSString*)filename;

@end
