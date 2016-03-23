//
//  ContentManager.h
//  Gecko iOS
//
//  Created by Master on 6/4/14.
//  Copyright (c) 2014 Zipline, inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentManager : NSObject

+ (ContentManager *)sharedManager;

- (void)generateConversation:(NSNumber *)threadID;

@end
