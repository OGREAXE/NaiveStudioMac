//
//  NCRemoteManager.h
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/7.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NCRemoteManager;

@protocol NCRemoteManagerDelegate <NSObject>

-(void)remoteManager:(NCRemoteManager*)manager connectionDidInterrupted:(NSError*)error;

@end

@interface NCRemoteCommand : NSObject

@property (nonatomic) NSString * commandText;

@end

@interface NCRemoteManager : NSObject

+(instancetype)sharedManager;

@property (nonatomic,readonly) BOOL isConnected;

@property (nonatomic,readonly) NSString * connectedHost;

@property (nonatomic,readonly) NSUInteger connectedPort;

-(void)sendCommand:(NCRemoteCommand*)command completion:(void (^)(BOOL result, NSError *error))completionHandler executionResult:(void (^)(id response, NSError *error))executionResultHandler;

-(void)sendCommandText:(NSString*)commandText executionResult:(void (^)(id response, NSError *error))executionResultHandler;

-(void)sendCommandText:(NSString*)commandText completion:(void (^)(BOOL result, NSError *error))completionHandler executionResult:(void (^)(id response, NSError *error))executionResultHandler;

-(void)connectToServerHost:(NSString*)address completion:(void (^)(BOOL result, NSError *error))completionHandler;

-(BOOL)disconnect;

@end

NS_ASSUME_NONNULL_END
