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
        _textField.font = [NSFont systemFontOfSize:30];
        [self addSubview:_textField];
    }
    return self;
}

-(void)layout{
    [super layout];
    
    _textField.frame = self.bounds;
}

@end

@interface NCProjectContentViewController ()<NSTableViewDataSource, NSTableViewDelegate,NCAddNewFileViewControllerDelegate>

//@property  (nonatomic) IBOutlet UITableView * tableView;

@property  (nonatomic) NSScrollView * scrollView;

@property  (nonatomic) NSTableView * tableView;

@property  (nonatomic) NSTextField * networkStatusTextField;

@property (nonatomic) NCInterpreterController * interpreter;

@end

@implementation NCProjectContentViewController

-(void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 600, 800)];
}

-(void)dealloc{
    NSLog(@"NCProjectContentViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 60, 600, 800)];
    
//    self.tableView = [[NSTableView alloc] initWithFrame:CGRectMake(0, 60, 600, 800)];
    self.tableView = [[NSTableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.scrollView.documentView = self.tableView;
    [self.view addSubview:self.scrollView];
    
    [self.tableView reloadData];
    
    self.title= self.project.name;
    
    NSButton * addNewButton = [NSButton buttonWithTitle:@"new" target:self action:@selector(didTapAddNew)];
    addNewButton.frame = CGRectMake(0, 0, 600, 60);
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
    
    self.interpreter = [[NCInterpreterController alloc] init];
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
    self.scrollView.frame = CGRectMake(0, bottomBarViewHeight, 600, self.view.frame.size.height - bottomBarViewHeight - topBarViewHeight);
    self.networkStatusTextField.frame = CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), 600, topBarViewHeight);
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
    return 50;
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
    
    NCCodeEditViewController * editVC = [[NCCodeEditViewController alloc] initWithNibName:@"NCCodeEditViewController" bundle:nil];
    
    //    editVC.mode = self.mode;
    editVC.interpreter = self.interpreter;
    editVC.sourceFile = self.project.sourceFiles[tableView.selectedRow];
    editVC.interpreter = self.interpreter;
    editVC.project = self.project;
    
    self.view.window.contentViewController = editVC;
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
    

    NCCodeEditViewController * editVC = [[NCCodeEditViewController alloc] initWithNibName:@"NCCodeEditViewController" bundle:nil];
    
    //    editVC.mode = self.mode;
    editVC.interpreter = self.interpreter;
    editVC.sourceFile = file;
    editVC.interpreter = self.interpreter;
    editVC.project = self.project;
    
    self.view.window.contentViewController = editVC;
}

@end
