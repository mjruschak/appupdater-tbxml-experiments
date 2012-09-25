//
//  RootViewController.m
//  AppUpdater
//
//  Created by mruschak on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize tableView=_tableView;
@synthesize resources=_resources;
@synthesize documentsURL=_documentsURL;
@synthesize documentsPath=_documentsPath;
@synthesize queue=_queue;
@synthesize paths=_paths;
@synthesize indexPaths=_indexPaths;
@synthesize updateButtonItem=_updateButtonItem;
@synthesize popOverController=_popOverController;
@synthesize cartContents=_cartContents;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization 
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [_paths objectAtIndex:0];
        _resources = [[NSMutableArray alloc] init];
        _cartContents = [[NSMutableArray alloc] init];
        _documentsURL = [appDelegate applicationDocumentsDirectory];
        
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _updateButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(updateListing:)];
        
        UIBarButtonItem * emailCart = [[UIBarButtonItem alloc] initWithTitle:@"Cart" style:UIBarButtonItemStyleBordered target:self action:@selector(openPopOver:)];
        
        [self.navigationItem setRightBarButtonItem: _updateButtonItem];
        [self.navigationItem setLeftBarButtonItem:emailCart];
        
        
        
        _queue = [[ASINetworkQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:2];
        [_queue setDelegate:self];
    }
    return self;
}
         
- (void) openPopOver: (id) sender {
    EmailCartPopOverViewController * emailCartPopOverViewController = [[EmailCartPopOverViewController alloc] initWithNibName:@"EmailCartPopOverViewController" bundle:nil];
    emailCartPopOverViewController.cartContents = _cartContents;
    _popOverController = [[UIPopoverController alloc] initWithContentViewController:emailCartPopOverViewController];
    _popOverController.delegate = self;
    [_popOverController presentPopoverFromRect:CGRectMake(0, 0, 60, 20) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
    
    ResourceFile *resourceFile = [_resources objectAtIndex:[indexPath row]];
    
    if ([resourceFile.fileDownloaded isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [cell.textLabel setTextColor: [UIColor grayColor]];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        [cell setUserInteractionEnabled:NO];
    } else {
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell setUserInteractionEnabled:YES];
    }
    
    cell.textLabel.text = resourceFile.fileLabel;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ResourceFile *resourceFile = [_resources objectAtIndex:[indexPath row]];
    [_cartContents addObject:resourceFile];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    ResourceFile *resourceFile = [_resources objectAtIndex:[indexPath row]];
    NSString *pdfFile = [NSString stringWithFormat:@"%@/%@", _documentsPath, resourceFile.fileName];
    ReaderDocument *readerDocument = [[ReaderDocument alloc] initWithFilePath:pdfFile password:nil];
    if (readerDocument != nil) {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:readerDocument];
        readerViewController.delegate = self;
        
        [self.navigationController pushViewController:readerViewController animated:YES];
    } else {
        NSLog(@"Failed");
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_resources count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updateListing:(id)sender {
    [_resources removeAllObjects];
    [_updateButtonItem setEnabled:NO];
     // Create a success block to be called when the async request completes
    TBXMLSuccessBlock successBlock = ^(TBXML *tbxmlDocument) {
        // If TBXML found a root node, process element and iterate all children
        if (tbxmlDocument.rootXMLElement != nil) {
            [self traverseElement:tbxmlDocument.rootXMLElement];
        }
    };
    
    // Create a failure block that gets called if something goes wrong
    TBXMLFailureBlock failureBlock = ^(TBXML *tbxmlDocument, NSError * error) {
        NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
    };
    
    
    TBXML * tbxml = [[TBXML alloc] initWithURL:[NSURL URLWithString: @"http://webservice.martinoflynnllc.com/app.xml"] success:successBlock failure:failureBlock];
}

-(void)traverseElement: (TBXMLElement *) element {
    dispatch_queue_t queue = dispatch_queue_create("com.martinoflynn.xmlparse", 0);
    
    dispatch_sync(queue, ^{
        
        TBXMLElement * filesAddedElement = [TBXML childElementNamed:@"filesAdded" parentElement:element];
        TBXMLElement * fileElement = [TBXML childElementNamed:@"file" parentElement:filesAddedElement];
        
        if (filesAddedElement != nil && fileElement != nil)
        {
            do {
                ResourceFile *resourceFile = [[ResourceFile alloc] init];
                resourceFile.fileId    = [NSNumber numberWithInt:[[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:fileElement] ] intValue]];
                resourceFile.fileLabel = [TBXML textForElement:[TBXML childElementNamed:@"label" parentElement:fileElement]];
                resourceFile.fileName  = [TBXML textForElement:[TBXML childElementNamed:@"fileName" parentElement:fileElement]];
                resourceFile.fileGroup = [TBXML textForElement:[TBXML childElementNamed:@"group" parentElement:fileElement]];
                resourceFile.fileType  = [TBXML textForElement:[TBXML childElementNamed:@"type" parentElement:fileElement]];
                resourceFile.fileDownloaded = [NSNumber numberWithInt:0];
                [_resources addObject:resourceFile];
                
                
            } while ((fileElement = fileElement->nextSibling));
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self reloadTableView];
            });
        }
        
        
    });
    
    dispatch_release(queue);
}


- (void) reloadTableView {
    [_tableView reloadData];
    [self downloadAllFiles];
    
}

- (void) downloadAllFiles {
    _indexPaths = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_resources count]; i++) {
        ResourceFile *resourceFile = [_resources objectAtIndex:i];
        NSURL *resourceFileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://webservice.martinoflynnllc.com/files/%@", resourceFile.fileName]];
        NSString *pdfDocumentFilename = [_documentsPath stringByAppendingPathComponent:resourceFile.fileName];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:resourceFileURL];
        [request setDelegate:self];
        [request setDownloadDestinationPath:pdfDocumentFilename];
        [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
        
        [request setCompletionBlock:^(void) {
            int row = i;
            ResourceFile *resourceFileCopy = [_resources objectAtIndex:row];
            resourceFileCopy.fileDownloaded = [NSNumber numberWithInt:1];
            [_resources replaceObjectAtIndex:row withObject:resourceFileCopy];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [_indexPaths addObject:indexPath];
            
            [self performSelectorOnMainThread:@selector(updateCells:) withObject:[NSNumber numberWithInt:i] waitUntilDone:YES];
            
        }];
        
        [_queue addOperation:request];
    }
    
    [_queue setQueueDidFinishSelector:@selector(queueFinished:)];
    [_queue go];
}


- (void)queueFinished:(ASINetworkQueue *)queue{
    [_updateButtonItem setEnabled:YES];
}  


- (void) updateCells: (id) sender {
    if ([_indexPaths count] > 0) {
        [_tableView reloadRowsAtIndexPaths:self.indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
