//
//  MultipeerManager.m
//  MultipeerChat
//
//  Created by user on 6/23/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "MultipeerManager.h"

@implementation MultipeerManager

-(id)init
{
    
    if (self = [super init])
    {
        _peerId = nil;
        _session =  nil;
        _browser = nil;
        _advertisier = nil;
    }
    
    return self;
}


#pragma mark - Custom Methods
- (void)setupPeerAndSessionWithDisplayName:(NSString*)displayName
{
    
}

- (void)setupMCBrowser
{
    
}

- (void)advertiseSelf:(BOOL)shouldAdvertise
{
    
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
