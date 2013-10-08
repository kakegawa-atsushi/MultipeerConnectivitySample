//
//  SessionHelper.m
//  P2PTest
//
//  Created by KAKEGAWA Atsushi on 2013/10/05.
//  Copyright (c) 2013年 KAKEGAWA Atsushi. All rights reserved.
//

#import "SessionHelper.h"

static NSString * const ServiceType = @"cm-p2ptest";

@interface SessionHelper () <MCSessionDelegate>

@property (nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@property (nonatomic) NSMutableArray *connectedPeerIDs;

@end

@implementation SessionHelper

#pragma mark - Accessor methods

- (NSString *)serviceType
{
    return ServiceType;
}

- (NSUInteger)connectedPeersCount
{
    return self.connectedPeerIDs.count;
}

#pragma mark - Lifecycle methods

- (instancetype)initWithDisplayName:(NSString *)displayName
{
    self = [super init];
    if (self) {
        self.connectedPeerIDs = [NSMutableArray new];
        
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        _session = [[MCSession alloc] initWithPeer:peerID];
        _session.delegate = self;
        
        self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:self.serviceType
                                                                        discoveryInfo:nil
                                                                              session:self.session];
        [self.advertiserAssistant start];
    }
    return self;
}

- (void)dealloc
{
    [self.advertiserAssistant stop];
    [self.session disconnect];
}

#pragma mark - MCSessionDelegate methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    BOOL needToNotify = NO;
    
    if (state == MCSessionStateConnected) {
        if (![self.connectedPeerIDs containsObject:peerID]) {
            [self.connectedPeerIDs addObject:peerID];
            needToNotify = YES;
        }
    } else {
        if ([self.connectedPeerIDs containsObject:peerID]) {
            [self.connectedPeerIDs removeObject:peerID];
            needToNotify = YES;
        }
    }
    
    if (needToNotify) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate sessionHelperDidChangeConnectedPeers:self];
        });
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate sessionHelperDidRecieveImage:image peer:peerID];
    });
}

- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress
{
    // Do nothing
}

- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error
{
    // Do nothing
}

- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID
{
    // Do nothing
}

#pragma mark - Public methods

- (MCPeerID *)connectedPeerIDAtIndex:(NSUInteger)index
{
    if (index >= self.connectedPeerIDs.count) {
        return nil;
    }
    
    return self.connectedPeerIDs[index];
}

- (void)sendImage:(UIImage *)image peerID:(MCPeerID *)peerID
{
    NSData *data = UIImageJPEGRepresentation(image, 0.9f);
    
    NSError *error;
    [self.session sendData:data
                   toPeers:@[peerID]
                  withMode:MCSessionSendDataReliable
                     error:&error];
    if (error) {
        NSLog(@"Failed %@", error);
    }
}

@end
