//
//  FirstViewController.m
//  MultipeerChat
//
//  Created by user on 6/23/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "ChatBoxViewController.h"
#import "MultipeerManager.h"

@interface ChatBoxViewController () < UITextFieldDelegate >

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (nonatomic)MultipeerManager* multipeerManager;

@end

@implementation ChatBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_multipeerManager = [MultipeerManager sharedInstance];
    _messageTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveDataWithNotification:) name:@"MCDidRecieveDataNotification" object:nil];
}


#pragma mark - IBAction Methods
- (IBAction)onCancelPressed:(UIButton *)sender
{
    [_messageTextField resignFirstResponder];
}


- (IBAction)onSendPressed:(UIButton *)sender
{
    [self sendMyMessage];
}


#pragma mark - UITextFieldDelegate Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMyMessage];
    return YES;
}


#pragma mark - Custom Methods

- (void)didReceiveDataWithNotification:(NSNotification*)notification
{
    //get the peer (sender) and the data
    MCPeerID* peer = [notification userInfo][@"peerID"];
    NSData* data = [notification userInfo][@"data"];
    
    //convert the NSData to a string
    NSString* message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    //create a format string for posting to the text view
    NSString* formattedMessage = [NSString stringWithFormat:@"%@: %@\n",peer.displayName, message];
    
    //we need to perform updates to the UI on the main thread, but the data is received on a different thread
    [_chatTextView performSelectorOnMainThread:@selector(setText:) withObject:[_chatTextView.text stringByAppendingString:formattedMessage] waitUntilDone:NO];
}

- (void)sendMyMessage
{
    //convert the text to NSData for tranmission
    NSData* message = [_messageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    
    //get the list of peers to send the message
    NSArray* allPeers = _multipeerManager.session.connectedPeers;
    
    //create error for transmission
    NSError* error;
    
    //send the message to all peers
    [_multipeerManager.session sendData:message toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
    
    NSString* messageString = [NSString stringWithFormat:@"%@: %@\n",[UIDevice currentDevice].name,_messageTextField.text];
    
    //update the chat view
    [_chatTextView setText:[_chatTextView.text stringByAppendingString: messageString]];
    
    //clear message field
    _messageTextField.text = @"";
    
    //dissmiss keyboard
    [_messageTextField resignFirstResponder];
    
}

@end
