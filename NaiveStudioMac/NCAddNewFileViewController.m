//
//  NCAddNewFileViewController.m
//  NaiveC
//
//  Created by 梁志远 on 01/01/2018.
//  Copyright © 2018 Ogreaxe. All rights reserved.
//

#import "NCAddNewFileViewController.h"
#import "Common.h"
#import "NCEditorViewController.h"
#import "NCProjectManager.h"
#import "Common.h"

@interface NCAddNewFileViewController ()

//@property (nonatomic) IBOutlet UITextField * textField;
//
//@property (nonatomic) IBOutlet UIButton * okButton;

@property (nonatomic) NSTextField * textField;

@property (nonatomic) NSButton * okButton;

@property (nonatomic) NSButton * cancelButton;

@end

@implementation NCAddNewFileViewController


-(void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(100, 0, 400, 350)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.textField = [[NSTextField alloc] initWithFrame:CGRectMake(30, 200, 340, 20)];
//    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.textField];
 
    _okButton = [NSButton buttonWithTitle:@"确定" target:self action:@selector(didTapOk:)];
    _okButton.frame = CGRectMake(80, 140, 100, 30);
    
    [self.view addSubview:self.okButton];
    
    _cancelButton = [NSButton buttonWithTitle:@"取消" target:self action:@selector(didTapCancel:)];
    _cancelButton.frame = CGRectMake(220, 140, 100, 30);
    
    [self.view addSubview:self.cancelButton];
}

-(void)viewDidLayout{
    [super viewDidLayout];
}


-(IBAction)didTapOk:(id)sender{
//    NSString * filename = self.textField.text;
//    NSString * projectPath = self.currentProject.rootDirectory;
//    NSString * filepath = [projectPath stringByAppendingPathComponent:filename];
//
    NSError * error = nil;
//    [@"" writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NCSourceFile * file = [[NCProjectManager sharedManager] createSourceFile:self.textField.stringValue project:self.currentProject error:&error];
    
    if (error) {
        NSLog(@"write file fail: %@",error);
    }
    else {

        NCEditorViewController * controller = [[NCEditorViewController alloc] init];
        controller.sourceFile = file;
        
        [self dismissViewController:self];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([self.delegate respondsToSelector:@selector(addNewFileViewController:didAddFile:)] ) {
                [self.delegate addNewFileViewController:self didAddFile:file];
            }
            
        });
    }
}

-(IBAction)didTapCancel:(id)sender{
    [self dismissViewController:self];
}

@end
