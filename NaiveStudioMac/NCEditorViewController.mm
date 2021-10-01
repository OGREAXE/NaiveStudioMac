//
//  NCEditorViewController.m
//  NaiveC
//
//  Created by 梁志远 on 16/09/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import "NCEditorViewController.h"
#import "NCScriptInterpreter.h"
#import "NCCodeTemplate.h"
#import "NCProject.h"
#import "Common.h"
#import "NCCodeFastInputViewController.h"
#import "NCProjectContentViewController.h"
#import "NCRemoteManager.h"

//#include "NCTokenizer.hpp"
//#include "NCParser.hpp"
//#include "NCInterpreter.hpp"
#include "NCTextManager.h"

@interface DummyTextView : NSTextView

@end

@implementation DummyTextView

-(void)setFrame:(NSRect)frame{
    [super setFrame:frame];
    
    if (frame.size.height < 100) {
        NSLog(@"?");
    }
    
}

@end


@interface NCEditorViewController ()< NCCodeFastInputViewControllerDelegate>

//@property (weak, nonatomic) IBOutlet  UITextView * textView;
//
//@property (weak, nonatomic) IBOutlet  UITextView * outputView;
//
//@property (weak, nonatomic) IBOutlet  UIButton * runButton;

@property (nonatomic)  NSTextView * textView;
@property (nonatomic)  NSScrollView * textViewScrollView;

@property (nonatomic)  NSTextView * outputView;
@property (nonatomic)  NSScrollView * outputViewScrollView;

@property (nonatomic)  NSTextField * titleTextField;

@property (nonatomic)  NSTextField * networkStatusTextField;

@property (nonatomic) NCTextManager * textManager;

@property (nonatomic) NCTextViewDataSource * textViewDataSource;  //only one

@property (nonatomic) NSMutableArray * fileDataSourceArray;  //could be many

@property (nonatomic) NSRange selectedRange;

//buttons
@property (nonatomic)  NSView * inputPanel;

@property (nonatomic)  NSButton * runButton;

@property (nonatomic)  NSButton * moveUpButton;
@property (nonatomic)  NSButton * moveDownButton;
@property (nonatomic)  NSButton * moveLeftButton;
@property (nonatomic)  NSButton * moveRightButton;

@property (nonatomic)  NSButton * closeButton;
@property (nonatomic)  NSButton * saveButton;

@end

@implementation NCEditorViewController

-(void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 1300, 900)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.backgroundColor  = [NSColor grayColor].CGColor;
    
    self.textView = [[DummyTextView alloc] initWithFrame:CGRectZero];
    self.textView.verticallyResizable = NO;
    [self.view addSubview:self.textView];
    
    self.outputView = [[NSTextView alloc] initWithFrame:CGRectZero];
    self.outputView.verticallyResizable = NO;
    [self.view addSubview:self.outputView];
    
    self.inputPanel = [[NSView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.inputPanel];
    
//    self.runButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.runButton setTitle:@"run" forState:UIControlStateNormal];
//    [self.runButton addTarget:self action:@selector(didTapCompile:) forControlEvents:UIControlEventTouchUpInside];
    self.runButton = [NSButton buttonWithTitle:@"run" target:self action:@selector(didTapRun:)];
    [self.inputPanel addSubview:self.runButton];
    
    self.saveButton = [NSButton buttonWithTitle:@"save" target:self action:@selector(didTapSave:)];
    [self.inputPanel addSubview:self.saveButton];
    
    self.closeButton = [NSButton buttonWithTitle:@"back" target:self action:@selector(didTapClose:)];
    [self.inputPanel addSubview:self.closeButton];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //    string str = "int i=0 \n if(i==0)i=2+1";
    _textViewDataSource  = [[NCTextViewDataSource alloc] initWithTextView:self.textView];
    
    _textManager = [[NCTextManager alloc] initWithDataSource:self.textViewDataSource];
//    _interpreter = [[NCInterpreterController alloc] init];
//    _interpreter.mode = self.mode;
    
    self.interpreter.delegate  = self.textManager;
    
    [self.textViewDataSource addDelegate:self.interpreter];
    self.textViewDataSource.linkedStorage = self.sourceFile.filepath;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePrintNotification:) name:@"NCPrintStringNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLogNotification:) name:@"NCLogNotification" object:nil];
    
    self.titleTextField = [[NSTextField alloc] initWithFrame:CGRectZero];
    self.titleTextField.stringValue = self.sourceFile.filename;
    self.titleTextField.bordered = NO;
    self.titleTextField.backgroundColor = [NSColor clearColor];
    self.titleTextField.editable = NO;
    self.titleTextField.font = [NSFont systemFontOfSize:25];
    self.titleTextField.alignment = NSTextAlignmentCenter;
    
    self.networkStatusTextField = [[NSTextField alloc] initWithFrame:CGRectZero];
    self.networkStatusTextField.bordered = NO;
    self.networkStatusTextField.backgroundColor = [NSColor clearColor];
    self.networkStatusTextField.editable = NO;
    
    self.networkStatusTextField.alignment = NSTextAlignmentLeft;
    
    [self.view addSubview:self.titleTextField];
    [self.view addSubview:self.networkStatusTextField];
    
    if ([NCRemoteManager sharedManager] .isConnected) {
        self.networkStatusTextField.stringValue = [NSString stringWithFormat: @"connected %@", [NCRemoteManager sharedManager].connectedHost];
        self.networkStatusTextField.textColor = [NSColor greenColor];
    }
    else {
        self.networkStatusTextField.stringValue = @"disconnected";
        self.networkStatusTextField.textColor = [NSColor redColor];
    }
}

-(void)viewDidAppear{
    [super viewDidAppear];
    
    [self.view.window center];
}

-(void)viewDidLayout{
    [super viewDidLayout];
    
    CGSize mainSize = self.view.frame.size;
    
    CGFloat textViewHeight = mainSize.height * 1/2;
    
    CGSize textViewSize = CGSizeMake(mainSize.width - 20, textViewHeight);
    self.outputView.frame = CGRectMake(10,10,textViewSize.width, mainSize.height * 1/3);
    
    self.inputPanel.frame = CGRectMake(10,CGRectGetMaxY(self.outputView.frame),textViewSize.width, 80);
    
    self.textView.frame = CGRectMake(10, CGRectGetMaxY(self.inputPanel.frame), mainSize.width - 20, textViewHeight);
    
    [self.titleTextField sizeToFit];
    CGSize titleSize = self.titleTextField.frame.size;
    self.titleTextField.frame = CGRectMake(self.view.frame.size.width/2 - titleSize.width/2, CGRectGetMaxY(self.textView.frame) + 15, titleSize.width, titleSize.height);
    
    self.networkStatusTextField.frame = CGRectMake(CGRectGetMaxX(self.titleTextField.frame) + 5, self.titleTextField.frame.origin.y, 600, 20);
    
    self.runButton.frame = CGRectMake(5,4,70, 40);
    self.saveButton.frame = CGRectMake(90,4,70, 40);
    self.closeButton.frame = CGRectMake(175,4,70, 40);
}


//-(void)testNC{
//
//    string str = self.textView.text.UTF8String;
//    NCTokenizer tokenizer(str);
//    auto  tokens = tokenizer.getTokens();
//    for (int i=0; i<tokens->size(); i++) {
//        const auto & aToken = (*tokens)[i];
//        NSLog(@"%s",aToken.token.c_str());
//    }
//
//    auto _tokens = tokens;
//    auto parser =  shared_ptr<NCParser>(new NCParser(_tokens));
//
//    auto interpreter = shared_ptr<NCInterpreter>(new NCInterpreter(parser->getRoot()));
//    interpreter->invoke_main();
//}


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
////    [self.view endEditing:YES];
//}

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

//-(void)showFastInputViewController:(NCFastInputType)type{
//    self.selectedRange = self.textView.selectedRange;
//
//    NCCodeFastInputViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCCodeFastInputViewController class])];
//    controller.type = type;
//    controller.delegate = self;
//
//    [self presentViewController:controller animated:YES completion:nil];
//}

-(void)codeFastInputViewController:(NCCodeFastInputViewController*)controller didInput:(NSArray*)textArray type:(NCFastInputType)type{
    [self.textManager insertCodeTemplate:(NCCodeTemplateType)type placeholdersFillerArray:textArray];
}

-(void)didClose:(NCCodeFastInputViewController *)controller{
    [self.textView becomeFirstResponder];
    self.textView.selectedRange  = self.selectedRange;
}

-(void)close{
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//
//    }];
}

@end
