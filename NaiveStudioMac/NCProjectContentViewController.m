//
//  NCProjectContentViewController.m
//  NaiveC
//
//  Created by 梁志远 on 31/12/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import "NCProjectContentViewController.h"
#import "NCProjectManager.h"
#import "NCEditorViewController.h"
#import "NCProjectTableViewCell.h"
#import "NCAddNewFileViewController.h"
#import "Common.h"
#import "NCCodeEditViewController.h"
#import "NCRemoteManager.h"
#import "NCConnectionViewController.h"

@interface NCRowView : NSTableRowView
@property (nonatomic) NSTextField * textField;
@end

@implementation NCRowView

-(id)init{
    self = [super init];
    if(self){
        _textField = [[NSTextField alloc] initWithFrame:CGRectZero];
        _textField.textColor = [NSColor blackColor];
        _textField.font = [NSFont systemFontOfSize:20];
        [self addSubview:_textField];
    }
    return self;
}

-(void)layout{
    [super layout];
    
    _textField.frame = self.bounds;
}

-(void)setEmphasized:(BOOL)emphasized{
    if(emphasized){
        _textField.textColor = [NSColor blueColor];
    }
    else {
        _textField.textColor = [NSColor blackColor];
    }
}

@end

#define TableViewWidth 350

@interface NCProjectContentViewController ()<NSTableViewDataSource, NSTableViewDelegate,NCAddNewFileViewControllerDelegate>

//@property  (nonatomic) IBOutlet UITableView * tableView;

@property  (nonatomic) NSScrollView * scrollView;

@property  (nonatomic) NSTableView * tableView;

@property  (nonatomic) NSTextField * networkStatusTextField;

@property (nonatomic) NCScriptInterpretor * interpreter;

@property (nonatomic) NSViewController * rightViewController;

@property (nonatomic) NSInteger lastSelectedRow;

@end

@implementation NCProjectContentViewController

-(void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 1200, 800)];
}

-(void)dealloc{
    NSLog(@"NCProjectContentViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lastSelectedRow = -1;
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 60, TableViewWidth, 800)];
    
//    self.tableView = [[NSTableView alloc] initWithFrame:CGRectMake(0, 60, 600, 800)];
    self.tableView = [[NSTableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSMenu * tableViewMenu = [[NSMenu alloc] init];
    NSMenuItem * delMenuItem = [[NSMenuItem alloc] initWithTitle:@"delete" action:@selector(didSelMenuItem:) keyEquivalent:@""];
    delMenuItem.target = self;
    [tableViewMenu insertItem:delMenuItem atIndex:0];
    self.tableView.menu = tableViewMenu;
    
    self.scrollView.documentView = self.tableView;
    [self.view addSubview:self.scrollView];
    
    [self.tableView reloadData];
    
    self.title= self.project.name;
    
    NSButton * addNewButton = [NSButton buttonWithTitle:@"new" target:self action:@selector(didTapAddNew)];
    addNewButton.frame = CGRectMake(0, 0, TableViewWidth, 60);
    [self.view addSubview:addNewButton];
    
    NSTextField * networkStatusTextField = [[NSTextField alloc] init];
    networkStatusTextField.frame = CGRectMake(0, 0, 600, 60);
    networkStatusTextField.editable = NO;
    networkStatusTextField.font = [NSFont systemFontOfSize:20];
    [self.view addSubview:networkStatusTextField];
    self.networkStatusTextField = networkStatusTextField;
    [self updateNetworkStatus];
    NSClickGestureRecognizer *click = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(networkTextFieldClicked)];
    [self.networkStatusTextField addGestureRecognizer:click];
    
    self.interpreter = [[NCScriptInterpretor alloc] init];
    self.interpreter.project = self.project;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged) name:kConnectionStatusChangedNotificationName object:nil];
}

-(void)viewWillAppear{
    [super viewDidAppear];
    
    [self.project reload];
    
    [self.tableView reloadData];
}

-(void)viewDidAppear{
    [super viewDidAppear];
    
    [self.view.window center];
}

-(void)viewDidLayout{
    [super viewDidLayout];
    
    CGFloat bottomBarViewHeight = 60;
    CGFloat topBarViewHeight = 30;
    self.scrollView.frame = CGRectMake(0, bottomBarViewHeight, TableViewWidth, self.view.frame.size.height - bottomBarViewHeight - topBarViewHeight);
    self.networkStatusTextField.frame = CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), TableViewWidth, topBarViewHeight);
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.project.sourceFiles.count;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 30;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

#define CONTENTVIEWCELL_REUSEIDENTIFIER @"contentViewCell"
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NCProjectTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:CONTENTVIEWCELL_REUSEIDENTIFIER];
//    if (!cell) {
//        cell = [[NCProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CONTENTVIEWCELL_REUSEIDENTIFIER];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    NCSourceFile * file = self.project.sourceFiles[indexPath.row];
//
//    cell.textLabel.text = file.filename;
//
//    return cell;
//}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    NSTableCellView *result = [tableView makeViewWithIdentifier:CONTENTVIEWCELL_REUSEIDENTIFIER owner:self];
    
    // Set the stringValue of the cell's text field to the nameArray value at row
    NCSourceFile * file  = [self.project.sourceFiles objectAtIndex:row];
    result.textField.stringValue = file.filename;
    
    // Return the result
    return result;
}

- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    NCRowView *rowView = [tableView makeViewWithIdentifier:@"rowView" owner:self];
    if (!rowView) {
        
        rowView = [[NCRowView alloc] init];
        rowView.identifier = @"rowView";
    }
    
    NCSourceFile * file  = [self.project.sourceFiles objectAtIndex:row];
    rowView.textField.stringValue = file.filename;
    
    return rowView;
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
    
    NSTableView *tableView = notification.object;
    
    if(self.lastSelectedRow != -1){
        NSTableRowView *lastSelectedRowView = [tableView rowViewAtRow:self.lastSelectedRow makeIfNecessary:NO];
        [lastSelectedRowView setEmphasized:NO];
    }
    
    NSInteger selectedRow = [tableView selectedRow];
    NSTableRowView * rowView = [tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
    [rowView setEmphasized:YES];
    
    self.lastSelectedRow = selectedRow;
    
    [self loadSourceFile:self.project.sourceFiles[tableView.selectedRow]];
}

-(BOOL)loadSourceFile:(NCSourceFile*)file{
    NCCodeEditViewController * editVC = [[NCCodeEditViewController alloc] initWithNibName:@"NCCodeEditViewController" bundle:nil];
    
    //    editVC.mode = self.mode;
    editVC.interpreter = self.interpreter;
    editVC.sourceFile = file;
    editVC.project = self.project;
    
    [self.rightViewController.view removeFromSuperview];
    
    self.rightViewController = editVC;
    [self.view addSubview:editVC.view];
    
    CGRect tableFrm = self.scrollView.frame;
    editVC.view.frame = CGRectMake(CGRectGetMaxX(tableFrm)+10, CGRectGetMinY(tableFrm)-20, self.view.frame.size.width - 10 -CGRectGetMinX(tableFrm) - TableViewWidth - 10, tableFrm.size.height+30);
    
    return YES;
}

-(void)didTapAddNew{
//    NCAddNewFileViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCAddNewFileViewController class])];
    NCAddNewFileViewController * controller = [[NCAddNewFileViewController alloc] init];
    
    controller.currentProject = self.project;
    controller.delegate = self;
    
    [self presentViewControllerAsSheet:controller];
//    self.view.window.contentViewController = controller;
}

-(void)addNewFileViewController:(NCAddNewFileViewController*)addNewController willPushtoEditController:(NCEditorViewController*)editController{
    
}

-(void)addNewFileViewController:(NCAddNewFileViewController*)addNewController didAddFile:(NCSourceFile*)file{
    

//    NCCodeEditViewController * editVC = [[NCCodeEditViewController alloc] initWithNibName:@"NCCodeEditViewController" bundle:nil];
//
//    //    editVC.mode = self.mode;
//    editVC.interpreter = self.interpreter;
//    editVC.sourceFile = file;
//    editVC.interpreter = self.interpreter;
//    editVC.project = self.project;
//
//    self.view.window.contentViewController = editVC;
    
    [self loadSourceFile:file];
    
    [self.project reload];
    [self.tableView reloadData];
}

-(void)didSelMenuItem:(id)sender{
    NSInteger row = self.tableView.clickedRow;
    NCSourceFile * srcFile =  self.project.sourceFiles[row];
    NSError * err = nil;
    [[NCProjectManager sharedManager] removeSourceFile:srcFile project:self.project error:&err];
    if (err) {
        NSAlert * alert = [NSAlert alertWithError:err];
        [alert addButtonWithTitle:@"确定"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
    
    [self.tableView reloadData];
}

@end
