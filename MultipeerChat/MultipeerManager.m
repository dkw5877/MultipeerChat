//
//  MultipeerManager.m
//  MultipeerChat
//
//  Created by user on 6/23/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "MultipeerManager.h"
@interface MultipeerManager ()
@property (nonatomic)NSString* sessionType;
@end


@implementation MultipeerManager

-(id)init
{
    
    if (self = [super init])
    {
        _peerId = nil;
        _session =  nil;
        _browser = nil;
        _advertisier = nil;
        _sessionType = @"chat-files";
    }
    
    return self;
}


#pragma mark - Custom Methods
- (void)setupPeerAndSessionWithDisplayName:(NSString*)displayName
{
    _peerId = [[MCPeerID alloc]initWithDisplayName:displayName];
    _session = [[MCSession alloc]initWithPeer:_peerId];
    _session.delegate = self;
}

/*
 * Use Apple's default peer browser view controller
 */
- (void)setupMCBrowser
{
    _browser = [[MCBrowserViewController alloc]initWithServiceType:_sessionType session:_session];
}

- (void)advertiseSelf:(BOOL)shouldAdvertise
{
    if (shouldAdvertise)
    {
        _advertisier = [[MCAdvertiserAssistant alloc]initWithServiceType:_sessionType discoveryInfo:nil session:_session];
        [_advertisier start];
    }
    else
    {
        [_advertisier stop];
        _advertisier = nil;
    }
}

#pragma MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
}


- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}
@end
