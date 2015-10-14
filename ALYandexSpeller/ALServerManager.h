//
//  ALServerManager.h
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 12.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALServerManager : NSObject




+ (ALServerManager *)sharedManager;
- (void)checkInternetConnectionWithHandler:(void (^)(BOOL))handler;
- (void)checkText:(NSString *)text
             lang:(NSString *)lang
          options:(NSString *)options
               ie:(NSString *)ie
        onSuccess:(void(^)(NSArray *result))success
        onFailure:(void(^)(NSError *error, NSInteger code))failure;

@end

