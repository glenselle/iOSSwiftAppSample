//
//  ContentManager.m
//  Gecko iOS
//
//  Created by Master on 6/4/14.
//  Copyright (c) 2014 Zipline, inc. All rights reserved.
//

#import "ContentManager.h"
#import "Message.h"
#import "SOMessageType.h"
#import <RestKit/RestKit.h>

@interface ContentManager ()

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) RKObjectManager *manager;
//@property (nonatomic, strong) NSArray *participants;
@end

@implementation ContentManager



+ (ContentManager *)sharedManager
{
    static ContentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)generateConversation:(NSNumber *)threadID
{
    [self loadThread:threadID];

}


- (void)configureRestKit:(NSNumber *)threadID
{
    NSURL *baseURL = [NSURL URLWithString:@"http://geckoapi.apiary-mock.com/"];
    
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    self.manager = [[RKObjectManager alloc]initWithHTTPClient:client];
    
    
    RKObjectMapping *conversationMapping =[RKObjectMapping mappingForClass:[Message class]];
    [conversationMapping addAttributeMappingsFromDictionary:@{@"id":@"id", @"money":@"money", @"data":@"data", @"createdAt":@"createdAt", @"updatedAt":@"date", @"type":@"dataType"}];

    
    
    RKObjectMapping *authorMapping =[RKObjectMapping mappingForClass:[Participants class]];
    [authorMapping addAttributeMappingsFromDictionary:@{@"avatar":@"avatar",@"id":@"userID",@"firstName":@"firstName",@"lastName":@"lastName"}];
    [conversationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"author" toKeyPath:@"author" withMapping:authorMapping]];
    
    NSUInteger threadNumber = threadID.integerValue;
    NSString *path = [NSString stringWithFormat:@"api/threads/34"];
    
    RKResponseDescriptor *responseDescriptor2 =
    [RKResponseDescriptor responseDescriptorWithMapping:conversationMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:path
                                                keyPath:@"conversation"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [self.manager addResponseDescriptor:responseDescriptor2];
}

- (void)loadThread:(NSNumber *)threadID
{
    [self configureRestKit:threadID];
    
    NSUInteger threadNumber = threadID.integerValue;
    NSString *path = [NSString stringWithFormat:@"/api/threads/34"];
    //Update when we have query parameters
    [self.manager getObjectsAtPath:path
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation2, RKMappingResult *mappingResult2) {
                                                  _messages = mappingResult2.array;
                                                  for(int i=0; i<_messages.count; i++)
                                                  {
                                                      [[_messages objectAtIndex:i ] configureSOMessage];
                                                  }
                                                  NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
                                                  [userInfo setObject:_messages forKey:@"messages"];
                                                  
                                                  [[NSNotificationCenter defaultCenter]
                                                   postNotificationName:@"MessagesLoaded"
                                                   object:self
                                                   userInfo:userInfo];
                                                  return;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"No Threads found: %@", error);
                                              }];
   
}



- (SOMessageType)messageTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"SOMessageTypeText"]) {
        return SOMessageTypeText;
    } else if ([string isEqualToString:@"SOMessageTypePhoto"]) {
        return SOMessageTypePhoto;
    } else if ([string isEqualToString:@"SOMessageTypeVideo"]) {
        return SOMessageTypeVideo;
    }
    
    return SOMessageTypeOther;
}

@end