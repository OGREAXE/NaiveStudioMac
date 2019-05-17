//
//  NCRemoteManager.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/7.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCRemoteManager.h"
#import "CocoaAsyncSocket.h"
#import "NCNetworkData.h"

#define LOG_REMOTE(fmt, ...) NSLog(fmt,##__VA_ARGS__)

typedef void (^CommandExecutionHandler)(id response, NSError *error);

typedef void (^ConnectionHandler)(BOOL result, NSError *error);

@interface NCRemoteManager () <GCDAsyncSocketDelegate>

@property (nonatomic) GCDAsyncSocket * socket;

@property (nonatomic) CommandExecutionHandler commandExecutionHandler;

@property (nonatomic) ConnectionHandler connectionHandler;

//@property (nonatomic) NSData * dataFragment;


@end

#define TAG_TEXT 101
#define TAG_BIN 102

@implementation NCRemoteManager
static NCRemoteManager *_instance = nil;

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NCRemoteManager alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}


-(GCDAsyncSocket*)socket{
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

-(void)sendCommandText:(NSString*)commandText executionResult:(void (^)(id response, NSError *error))executionResultHandler{
    NCNetworkData * networkData = [[NCNetworkData alloc] initWithString:commandText];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:networkData];
    NSMutableData * dataWithDelimiter = [[NSMutableData alloc] initWithData:data];
    [dataWithDelimiter appendData:DATA_FRAGMENT_DELIMITER];
    
    [self.socket writeData:dataWithDelimiter withTimeout:10 tag:TAG_TEXT];
    
    self.commandExecutionHandler = executionResultHandler;
    
//    [self.socket readDataWithTimeout:- 1 tag:0];
    [self.socket readDataToData:DATA_FRAGMENT_DELIMITER withTimeout:-1 tag:0];
}

#define CONNECT_PORT 12345

-(void)connectToServerHost:(NSString*)host completion:(void (^)(BOOL result, NSError *error))completionHandler{
    NSError * error = nil;
    BOOL result = [self.socket connectToHost:host onPort:CONNECT_PORT withTimeout:10 error:&error];
    if (!result) {
        LOG_REMOTE(@"connect to host %@:%d fail, error %@",host,CONNECT_PORT,error);
        
        if (completionHandler) {
            completionHandler(NO, error);
        }
        return;
    }
    else{
        self.connectionHandler = completionHandler;
    }
}

-(BOOL)disconnect{
    [self.socket disconnect];
    self.socket = nil;
    return YES;
}

-(BOOL)isConnected{
    return self.socket.isConnected;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    LOG_REMOTE(@"didConnectToHost %@:%d",host,CONNECT_PORT);
    
    if (self.connectionHandler) {
        self.connectionHandler(YES, nil);
        self.connectionHandler = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionStatusChangedNotificationName object:nil];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    if (self.connectionHandler) {
        LOG_REMOTE(@"can't connect, error %@",err);
        self.connectionHandler(NO, err);
        self.connectionHandler = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionStatusChangedNotificationName object:nil];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    LOG_REMOTE(@"didWriteDataWithTag %d",tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSData * dataWithoutDelim = [data subdataWithRange:NSMakeRange(0, data.length-2)];
    NCNetworkData * ncData = [NSKeyedUnarchiver unarchiveObjectWithData:dataWithoutDelim];
    
//    if (self.dataFragment) {
//        NSMutableData * combineData = [NSMutableData dataWithData:self.dataFragment];
//        [combineData appendData:data];
//        ncData = [NSKeyedUnarchiver unarchiveObjectWithData:combineData];
//
//        if (!ncData) {
//            self.dataFragment = combineData;
//        }
//        else {
//            self.dataFragment = nil;
//        }
//    }
//    else {
//        ncData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    }
//
//
//    if (!ncData) {
//        self.dataFragment = data;
//    }
    
    if(ncData){
        switch (ncData.type) {
            case NCNetworkDataTypeString:
            {
                LOG_REMOTE(@"didReadData:**************\n%@",ncData.string);
                
                if (self.commandExecutionHandler) {
                    NSString * str = ncData.string;
                    if (str) {
                        self.commandExecutionHandler(str, nil);
    //                    self.commandExecutionHandler = nil;
                    }
                }
            }
                break;
            case NCNetworkDataTypeImage:
            {
                LOG_REMOTE(@"didReadData:image");
                //todo image
            }
                break;
            default:
                break;
        }
    }
    
//    [self.socket readDataWithTimeout:- 1 tag:0];
    [self.socket readDataToData:DATA_FRAGMENT_DELIMITER withTimeout:-1 tag:0];
}

-(NSString*)connectedHost{
    return self.socket.connectedHost;
}

-(NSUInteger)connectedPort{
    return self.socket.connectedPort;
}

@end
