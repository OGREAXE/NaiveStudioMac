//
//  NCMainViewController.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/2/26.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCMainViewController.h"
#import "NCMainViewCell.h"
#import "NCProject.h"
#import "NCProjectContentViewController.h"
#import "NCEditorViewController.h"
#import "Common.h"
#import "NCConnectionViewController.h"

@interface NCMainViewController ()<NSTableViewDelegate,NSTableViewDataSource>

//@property  (nonatomic) IBOutlet UITableView * tableView;
//
//@property (nonatomic) IBOutlet UIButton * playgroundButton;

@property  (nonatomic) NSTableView * tableView;

@property (nonatomic) NSButton * playgroundButton;

@property (nonatomic) NSButton * connectToHostButton;

@property (nonatomic) NSMutableArray * projectList;

@end

@implementation NCMainViewController

-(void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 600, 800)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [NCBuiltinManager addAll];
    
    self.tableView = [[NSTableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.playgroundButton = [NSButton buttonWithTitle:@"playground" target:self action:@selector(didTapGotoPlaygound:)];
    self.playgroundButton.frame = CGRectMake(200, 80, 200, 80);
    
    self.connectToHostButton = [NSButton buttonWithTitle:@"connect" target:self action:@selector(didTapConnect:)];
    self.connectToHostButton.frame = CGRectMake(200, 80, 200, 80);
//    [self.playgroundButton setTitle:@"playground" forState:UIControlStateNormal];
//    [self.playgroundButton addTarget:self action:@selector(didTapGotoPlaygound:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playgroundButton];
    [self.view addSubview:self.connectToHostButton];
    
//    UIBarButtonItem *btn0 = [[UIBarButtonItem alloc] initWithTitle:@"New Project"
//                                                             style:UIBarButtonItemStylePlain
//                                                            target:self
//                                                            action:@selector(didTapNewProject:)];
//    self.navigationItem.rightBarButtonItems = @[btn0];
//
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.projectList = [NSMutableArray arrayWithObject:[[NCProjectManager sharedManager] defaultProject]];
    
    [self.tableView reloadData];
}

-(void)viewDidLayout{
    [super viewDidLayout];
    
    CGFloat buttonHeight = 50;
    CGSize mainSize = self.view.frame.size;
    self.playgroundButton.frame = CGRectMake(10, 10, 200, buttonHeight);
    self.connectToHostButton.frame = CGRectMake(220, 10, 100, buttonHeight);
    self.tableView.frame = CGRectMake(0, 0, mainSize.width, mainSize.height-buttonHeight);
}

#define MAINVIEWCELL_REUSEIDENTIFIER @"mainViewCell"

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.projectList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCMainViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:MAINVIEWCELL_REUSEIDENTIFIER];
    if (!cell) {
        cell = [[NCMainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MAINVIEWCELL_REUSEIDENTIFIER];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NCProject * project = self.projectList[indexPath.row];
    
    cell.textLabel.text = project.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NCProjectContentViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCProjectContentViewController class])];
    
    controller.project = self.projectList[indexPath.row];
    
    [self.navigationController pushViewController:controller animated:YES];
}*/

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    NSTableCellView *result = [tableView makeViewWithIdentifier:MAINVIEWCELL_REUSEIDENTIFIER owner:self];
    
    // Set the stringValue of the cell's text field to the nameArray value at row
    NCProject * project = self.projectList[row];
    
    result.textField.stringValue = project.name;
    
    // Return the result
    return result;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.projectList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return self.projectList[row];
}

/*- (void)tableView:(NSTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 //    NCEditorViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCEditorViewController class])];
 
 NCEditorViewController * editVC = [[NCEditorViewController alloc] init];
 
 editVC.mode = self.mode;
 editVC.sourceFile = self.project.sourceFiles[indexPath.row];
 editVC.interpreter = self.interpreter;
 
 [self.navigationController pushViewController:editVC animated:YES];
 }*/

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
//    NSTableView *tableView = notification.object;
//    NCEditorViewController * editVC = [[NCEditorViewController alloc] init];
//
//    editVC.mode = self.mode;
//    editVC.sourceFile = self.project.sourceFiles[tableView.selectedRow];
//    editVC.interpreter = self.interpreter;
//
//    [self presentViewControllerAsModalWindow:editVC];
}

-(void)didTapNewProject :(id)sender{
    
}

-(IBAction)didTapGotoPlaygound:(id)sender{
    [self goToPlayground];
}

-(IBAction)didTapConnect:(id)sender{
    NCConnectionViewController * controller = [[NCConnectionViewController alloc] init];
    
    [self presentViewControllerAsSheet:controller];
}

-(void)goToPlayground{
    if (![[NCProjectManager sharedManager] playgroundExist]) {
        [[NCProjectManager sharedManager] createPlayground];
    }
    
    NCProjectContentViewController * controller = [[NCProjectContentViewController alloc] init];
    
//    controller.mode = NCInterpretorModeCommandLine;
    controller.project = [NCProjectManager sharedManager].playground;
    
//    [self presentViewControllerAsModalWindow:controller];
    self.view.window.contentViewController = controller;
}

@end
