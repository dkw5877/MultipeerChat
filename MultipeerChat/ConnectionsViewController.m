//
//  ConnectionsViewController.m
//  MultipeerChat
//
//  Created by user on 6/23/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "ConnectionsViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MultipeerManager.h"

@interface ConnectionsViewController () <UITableViewDataSource, UITableViewDelegate, MCBrowserViewControllerDelegate >
@property (weak, nonatomic) IBOutlet UITextField *deviceDisplayNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *visibleSwitch;
@property (weak, nonatomic) IBOutlet UIButton *browseDevicesButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UITableView *connectedDevicesTableView;
@property (nonatomic) MultipeerManager* multipeerManager;

@end

@implementation ConnectionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     _multipeerManager = [MultipeerManager sharedInstance];
    [_multipeerManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [_multipeerManager advertiseSelf:_visibleSwitch.on];
}


#pragma mark - MCBrowserViewControllerDelegate Methods

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [_multipeerManager.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [_multipeerManager.browser dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    return cell;
}


#pragma mark - IBAction Methods


- (IBAction)onBrowseDevicePressed:(UIButton *)sender
{
    [_multipeerManager setupMCBrowser];
    _multipeerManager.browser.delegate = self;
    [self presentViewController:[_multipeerManager browser] animated:YES completion:nil];
}

- (IBAction)onDisconnectPressed:(UIButton *)sender
{
    
}

- (IBAction)toggleVisibility:(UISwitch *)sender
{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
