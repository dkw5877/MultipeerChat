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

@interface ConnectionsViewController () <UITableViewDataSource, UITableViewDelegate, MCBrowserViewControllerDelegate, UITextFieldDelegate >
@property (weak, nonatomic) IBOutlet UITextField *deviceDisplayNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *visibleSwitch;
@property (weak, nonatomic) IBOutlet UIButton *browseDevicesButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UITableView *connectedDevicesTableView;

@property (nonatomic)NSMutableArray* connectDevices;
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
    _connectDevices = [NSMutableArray new];
    
    _deviceDisplayNameTextField.delegate = self;
     _multipeerManager = [MultipeerManager sharedInstance];
    [_multipeerManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [_multipeerManager advertiseSelf:_visibleSwitch.on];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];
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
    return _connectDevices.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"connectedDeviceId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.text = _connectDevices[indexPath.row];
    return cell;
}


#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_deviceDisplayNameTextField resignFirstResponder];
    
    //reset the manager properties
    _multipeerManager.peerId = nil;
    _multipeerManager.session = nil;
    _multipeerManager.browser = nil;
    
    //if we are advertising stop
    if (_visibleSwitch.on)
    {
        [_multipeerManager.advertisier stop];
        [_multipeerManager advertiseSelf:NO];
    }
    
    _multipeerManager.advertisier = nil;
    
    //
    [_multipeerManager setupPeerAndSessionWithDisplayName:_deviceDisplayNameTextField.text];
    [_multipeerManager advertiseSelf:_visibleSwitch.on];
    [_multipeerManager setupMCBrowser];
    
    
    return YES;
}


#pragma mark -  MultipeerManagerNoitifcation Methods

- (void)peerDidChangeStateWithNotification:(NSNotification*)notificaton
{
    MCPeerID* peerID = [notificaton userInfo][@"peer"];
    MCSessionState state = [[notificaton userInfo][@"state"]intValue];
    
    if (state != MCSessionStateConnecting)
    {
        if (state == MCSessionStateConnected)
        {
            [_connectDevices addObject:peerID.displayName];
            
        }
        else if (state == MCSessionStateNotConnected)
        {
            if (_connectDevices.count > 0)
            {
//                int index = [_connectDevices indexOfObject:peerID.displayName];
//                [_connectDevices removeObjectAtIndex:index];
                [_connectDevices removeObjectIdenticalTo:peerID.displayName];
            }
        }
        
        //reload table
        [_connectedDevicesTableView reloadData];
        
        //check if any peers are connected, set the button status based on existence of peers
        BOOL peerExists = _multipeerManager.session.connectedPeers.count == 0;
        _deviceDisplayNameTextField.enabled = peerExists;
        _disconnectButton.enabled = !peerExists;
        
    }

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
    [_multipeerManager.session disconnect];
    [_connectDevices removeAllObjects];
    [_connectedDevicesTableView reloadData];
    _deviceDisplayNameTextField.enabled = true;

}

- (IBAction)toggleVisibility:(UISwitch *)sender
{
    [_multipeerManager advertiseSelf:_visibleSwitch.on];
}


@end
