//
//  EmailCartPopOverViewController.m
//  AppUpdater
//
//  Created by mruschak on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailCartPopOverViewController.h"
#import "AppDelegate.h"

@interface EmailCartPopOverViewController ()

@end

@implementation EmailCartPopOverViewController

@synthesize tableView=_tableView;
@synthesize cartContents;
@synthesize emailFilesButton=_emailFilesButton;
@synthesize mailPDFViewController=_mailPDFViewController;
@synthesize documentsPath=_documentsPath;
@synthesize paths=_paths;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [_paths objectAtIndex:0];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

    ResourceFile *resourceFile = [cartContents objectAtIndex:[indexPath row]];
    cell.textLabel.text = resourceFile.fileLabel;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cartContents count];
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

- (IBAction)emailAllFiles:(id)sender {
     _mailPDFViewController = [[MFMailComposeViewController alloc] init];
    [_mailPDFViewController setModalPresentationStyle:UIModalPresentationPageSheet];
    _mailPDFViewController.mailComposeDelegate = self;
    for (int i = 0; i < [cartContents count]; i++)
    {
        ResourceFile *resourceFile = [cartContents objectAtIndex:i];
        NSString *attachmentPath = [NSString stringWithFormat:@"%@/%@", _documentsPath, resourceFile.fileName];
        NSData *pdfFileData =[[NSData alloc] initWithContentsOfFile:attachmentPath];
        [_mailPDFViewController addAttachmentData:pdfFileData mimeType:@"application/pdf" fileName:resourceFile.fileName];
        
    }
    
    [self presentViewController:_mailPDFViewController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [_mailPDFViewController dismissModalViewControllerAnimated:YES];
}

@end
