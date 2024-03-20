//
//  SourceEditorCommand.m
//  NaivePatch
//
//  Created by mi on 2024/1/18.
//

#import "SourceEditorCommand.h"

@protocol XCNaiveProtocol <NSObject>

- (void)processCode:(NSString *)code;

@end

@interface HostAppXPCManager : NSObject

@property (nonatomic) NSXPCConnection *connection;

@property (nonatomic, readonly) id<XCNaiveProtocol> proxy;

@end

@implementation HostAppXPCManager

- (void)startConnection {
    NSXPCConnection *connection = [[NSXPCConnection alloc] initWithServiceName:@"com.xcservice.com"];
    connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XCNaiveProtocol)];
    
    [connection resume];
    
    self.connection = connection;
}

- (void)stopConnection {
    [self.connection invalidate];
    self.connection = nil;
}

- (id<XCNaiveProtocol>)proxy {
    return self.connection.remoteObjectProxy;
}

@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    NSLog(@"naive path class name %@", invocation.className);
    NSLog(@"naive path file line count %d", invocation.buffer.lines.count);
    
    HostAppXPCManager *xpcManager = [[HostAppXPCManager alloc] init];
    
    [xpcManager stopConnection];
    
    NSMutableString *code = [NSMutableString new];
    
    for (NSString *s in invocation.buffer.lines) {
        [code appendString:s];
    }
    
//    [xpcManager.proxy processCode:code];
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"NaiveCodeFromXcode"
                                                                   object:code
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
    
    completionHandler(nil);
}

@end
