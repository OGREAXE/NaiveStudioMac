//
//  NCCodeEditViewController.m
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/15.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCCodeEditViewController.h"
#import "NCInterpreterController.h"
#import "NCCodeTemplate.h"
#import "NCProject.h"
#import "Common.h"
#import "NCCodeFastInputViewController.h"
#import "NCProjectContentViewController.h"
#import "NCRemoteManager.h"
#include "NCTextManager.h"
#import "NCConnectionViewController.h"

@interface NCCodeEditViewController ()
@property (nonatomic) IBOutlet  NSTextView * textView;
@property (nonatomic) IBOutlet  NSScrollView * textViewScrollView;

@property (nonatomic) IBOutlet  NSTextView * outputView;
@property (nonatomic) IBOutlet  NSScrollView * outputViewScrollView;

@property (nonatomic) IBOutlet  NSTextField * titleTextField;

@property (nonatomic) IBOutlet  NSTextField * networkStatusTextField;
//buttons
@property (nonatomic) IBOutlet  NSButton * runButton;
@property (nonatomic) IBOutlet  NSButton * saveButton;
@property (nonatomic) IBOutlet  NSButton * clearButton;
@property (nonatomic) IBOutlet  NSButton * backButton;

@property (nonatomic) NCTextManager * textManager;

@property (nonatomic) NCTextViewDataSource * textViewDataSource;  //only one

@property (nonatomic) NSMutableArray * fileDataSourceArray;  //could be many

@property (nonatomic) NSRange selectedRange;


@end

@implementation NCCodeEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.backgroundColor  = [NSColor grayColor].CGColor;
    
    _textViewDataSource  = [[NCTextViewDataSource alloc] initWithTextView:self.textView];
    
    _textManager = [[NCTextManager alloc] initWithDataSource:self.textViewDataSource];
    
    self.interpreter.delegate  = self.textManager;
    
    [self.textViewDataSource addDelegate:self.interpreter];
    self.textViewDataSource.linkedStorage = self.sourceFile.filepath;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePrintNotification:) name:@"NCPrintStringNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLogNotification:) name:@"NCLogNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged) name:kConnectionStatusChangedNotificationName object:nil];
    
    [self updateNetworkStatus];
    NSClickGestureRecognizer *click = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(networkTextFieldClicked)];
    [self.networkStatusTextField addGestureRecognizer:click];
    
    self.titleTextField.stringValue = self.project.name;
}

-(void)connectionChanged{
    [self updateNetworkStatus];
}

-(void)networkTextFieldClicked{
    if (![NCRemoteManager sharedManager]. isConnected) {
        NCConnectionViewController * controller = [[NCConnectionViewController alloc] init];
        
        [self presentViewControllerAsSheet:controller];
    }
}

-(void)updateNetworkStatus{
    if ([NCRemoteManager sharedManager] .isConnected) {
        self.networkStatusTextField.stringValue = [NSString stringWithFormat: @"connected %@", [NCRemoteManager sharedManager].connectedHost];
        self.networkStatusTextField.textColor = [NSColor blueColor];
    }
    else {
        self.networkStatusTextField.stringValue = @"disconnected. click to connect";
        self.networkStatusTextField.textColor = [NSColor redColor];
    }
}

-(void)didReceivePrintNotification:(NSNotification*)notification{
    NSString * str = notification.object;
    
    self.outputView.string = [[[self.outputView.string stringByAppendingString:str]stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] stringByAppendingString:@"\n"];
}

-(void)didReceiveLogNotification:(NSNotification*)notification{
    NSString * str = notification.object;
    
    self.outputView.string = [[[self.outputView.string stringByAppendingString:str]stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] stringByAppendingString:@"\n"];
}

-(IBAction)didTapCompile:(id)sender{
    [self saveCurrentContent];
    
    NSString * codeText = self.textView.string;
    codeText = [self filterTextAsLegalCode:codeText];
    
    __weak typeof(self) weakSelf = self;
    [[NCRemoteManager sharedManager] sendCommandText:codeText executionResult:^(id  _Nonnull response, NSError * _Nonnull error) {
        //        weakSelf.outputView.string = [NSString stringWithFormat:@"%@\n%@",weakSelf.outputView.string,response];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", response]];
        [weakSelf.outputView.textStorage appendAttributedString:attrStr];
        [weakSelf.outputView scrollToEndOfDocument:nil];
    }];
    
}

-(NSString*)filterTextAsLegalCode:(NSString*)codeText{
    codeText = [codeText stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    return [codeText stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
}

-(IBAction)didTapUndo:(id)sender{
    NSUndoManager * manager = self.textView.undoManager;
    [manager undo];
}

-(IBAction)didTapSave:(id)sender{
    [self saveCurrentContent];
}

-(IBAction)didTapClose:(id)sender{
    NCProjectContentViewController * controller = [[NCProjectContentViewController alloc] init];
    controller.project = self.project;
    self.view.window.contentViewController = controller;
}

-(IBAction)didTapClear:(id)sender{
    self.outputView.string = @"";
}

-(BOOL)saveCurrentContent{
    NSError * error;
    if([self.textViewDataSource save:&error]){
        return YES;
    }
    if (error) {
        NSLog(@"save error:%@",error);
    }
    return NO;
}

-(void)didClose:(NCCodeFastInputViewController *)controller{
    [self.textView becomeFirstResponder];
    self.textView.selectedRange  = self.selectedRange;
}

@end
