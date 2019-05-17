//
//  NCConnectionViewController.m
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/15.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCConnectionViewController.h"
#import "NCRemoteManager.h"

@interface NCConnectionViewController ()

@property (nonatomic) NSTextField * hostTextField;
@property (nonatomic) NSTextField * portTextField;

@property (nonatomic) NSButton * connectButton;
@property (nonatomic) NSButton * cancelButton;

@property (nonatomic) NSProgressIndicator * progressIndicator;

@end

#define kRecentlyConnectHost @"kRecentlyConnectHost"

@implementation NCConnectionViewController

-(void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(100, 0, 400, 350)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.hostTextField = [[NSTextField alloc] initWithFrame:CGRectMake(30, 200, 340, 20)];
    //    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.hostTextField];
    
    NSString * recentlyConnectedHost = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentlyConnectHost];
    if (recentlyConnectedHost) {
        self.hostTextField.stringValue = recentlyConnectedHost;
    }
    
    self.portTextField = [[NSTextField alloc] initWithFrame:CGRectMake(400, 200, 340, 20)];
    //    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.portTextField];
    
    _connectButton = [NSButton buttonWithTitle:@"确定" target:self action:@selector(didTapOk:)];
    _connectButton.frame = CGRectMake(80, 140, 100, 30);
    
    [self.view addSubview:self.connectButton];
    
    _cancelButton = [NSButton buttonWithTitle:@"取消" target:self action:@selector(didTapCancel:)];
    _cancelButton.frame = CGRectMake(220, 140, 100, 30);
    
    [self.view addSubview:self.cancelButton];
    
    self.progressIndicator.frame = CGRectMake(170, 240, 60, 30);
    self.progressIndicator.hidden = YES;
    self.progressIndicator.style = NSProgressIndicatorStyleSpinning;
    [self.view addSubview:self.progressIndicator];
}

-(void)viewDidLayout{
    [super viewDidLayout];
}

-(IBAction)didTapOk:(id)sender{
    NSString * host = self.hostTextField.stringValue;
//    NSUInteger port = self.portTextField.stringValue.integerValue;
    
    if (!self.progressIndicator.hidden) {
        return;
    }
    
    if (host) {
        [self.progressIndicator startAnimation:nil];
        self.progressIndicator.hidden = NO;
        
        [[NSUserDefaults standardUserDefaults] setObject:host forKey:kRecentlyConnectHost];
        
        [[NCRemoteManager sharedManager] connectToServerHost:host completion:^(BOOL result, NSError * _Nonnull error) {
            self.progressIndicator.hidden = YES;
            if (error) {
                NSAlert * alert = [NSAlert alertWithError:error];
                [alert addButtonWithTitle:@"确定"];
                [alert setAlertStyle:NSAlertStyleWarning];
                [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
            }
            else {
                [self dismissViewController:self];
            }
        }];
    }
}

-(IBAction)didTapCancel:(id)sender{
    [self dismissViewController:self];
}


-(NSProgressIndicator*)progressIndicator{
    if (!_progressIndicator) {
        _progressIndicator = [[NSProgressIndicator alloc] init];
    }
    return _progressIndicator;
}

@end
