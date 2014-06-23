//
//  MultipeerManager.h
//  MultipeerChat
//
//  Created by user on 6/23/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MultipeerManager : NSObject < MCSessionDelegate >

@property (nonatomic)MCPeerID* peerId;
@property (nonatomic)MCSession* session;
@property (nonatomic)MCBrowserViewController* browser;
@property (nonatomic)MCAdvertiserAssistant* advertisier;

@end
