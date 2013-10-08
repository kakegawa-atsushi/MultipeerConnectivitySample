//
//  SessionHelper.h
//  P2PTest
//
//  Created by KAKEGAWA Atsushi on 2013/10/05.
//  Copyright (c) 2013年 KAKEGAWA Atsushi. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MultipeerConnectivity;

@class SessionHelper;

@protocol SessionHelperDelegate <NSObject>

@required
- (void)sessionHelperDidChangeConnectedPeers:(SessionHelper *)sessionHelper;
- (void)sessionHelperDidRecieveImage:(UIImage *)image peer:(MCPeerID *)peerID;

@end

@interface SessionHelper : NSObject

@property (nonatomic, readonly) MCSession *session;
@property (nonatomic, readonly) NSString *serviceType;
@property (nonatomic, readonly) NSUInteger connectedPeersCount;
@property (nonatomic, weak) id <SessionHelperDelegate> delegate;

- (instancetype)initWithDisplayName:(NSString *)displayName;

- (MCPeerID *)connectedPeerIDAtIndex:(NSUInteger)index;
- (void)sendImage:(UIImage *)image peerID:(MCPeerID *)peerID;

@end
