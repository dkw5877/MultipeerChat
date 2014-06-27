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


+ (MultipeerManager*)sharedInstance
{
    static id sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance)
        {
            sharedInstance = [[self alloc]init];
        }
    });
    
    return sharedInstance;
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
    //post a notification when the state changes
    NSDictionary* stateDetail = @{@"peerID": peerID, @"state": [NSNumber numberWithInt:state]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification" object:nil userInfo:stateDetail];
}


- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    //post a notification when the state changes
    NSDictionary* stateDetail = @{@"peerID": peerID, @"data":data };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidRecieveDataNotification" object:nil userInfo:stateDetail];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSDictionary* resource = @{@"resourceName": resourceName, @"peerID":peerID, @"progress":progress};
    
    //post a notification
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCdidStartReceivingResourceNotification" object:nil userInfo:resource];
    
    //monitor the progress of receiving resource
    dispatch_async(dispatch_get_main_queue(), ^{
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    });
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

# pragma mark -  KVO related method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //post a progress notification
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCReceivingProgressNotification" object:nil userInfo:@{@"progress":(NSProgress*)object}];
}
@end
