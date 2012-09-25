//
//  RootViewController.h
//  AppUpdater
//
//  Created by mruschak on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"
#import "TBXML+HTTP.h"
#import "ResourceFile.h"
#import "ReaderViewController.h"
#import <dispatch/dispatch.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "EmailCartPopOverViewController.h"

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ReaderViewControllerDelegate, ASIHTTPRequestDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resources;

@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSURL *documentsURL;
@property (nonatomic, strong) NSString *documentsPath;
@property (nonatomic, strong) ASINetworkQueue *queue;
@property (nonatomic, strong) NSMutableArray *indexPaths;
@property (nonatomic, strong) UIBarButtonItem *updateButtonItem;

@property (nonatomic, strong) UIPopoverController * popOverController;
@property (nonatomic, strong) NSMutableArray *cartContents;

- (IBAction)updateListing:(id)sender;
- (void) reloadTableView;
- (void) openPopOver: (id) sender;

@end
