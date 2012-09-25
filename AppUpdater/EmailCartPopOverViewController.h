//
//  EmailCartPopOverViewController.h
//  AppUpdater
//
//  Created by mruschak on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ResourceFile.h"

@interface EmailCartPopOverViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
    NSMutableArray *cartContents;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cartContents;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSString *documentsPath;

@property (strong, nonatomic) MFMailComposeViewController *mailPDFViewController;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *emailFilesButton;

- (IBAction)emailAllFiles:(id)sender;
@end
