//
//  ALServerManager.m
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 12.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "ALServerManager.h"
#import "AFNetworking.h"
#import "ALSpellResult.h"

static NSString *ALYandexSpellerCheckText = @"checkText";
// static NSString *ALYandexSpellerCheckTexts = @"checkTexts";

@interface ALServerManager ()

@property(nonatomic, strong, readwrite)
    AFHTTPRequestOperationManager *requestOperationManager;

@end

@implementation ALServerManager

+ (ALServerManager *)sharedManager {
  static ALServerManager *manager = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[ALServerManager alloc] init];
  });

  return manager;
}

- (id)init {
  self = [super init];

  if (self) {
    NSURL *url =
        [NSURL URLWithString:
                   @"https://speller.yandex.net/services/spellservice.json/"];
    self.requestOperationManager =
        [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
  }

  return self;
}

#pragma mark - Check Internet Connection

- (void)checkInternetConnectionWithHandler:(void (^)(BOOL))handler {
  NSString *urlString = @"https://www.google.com/";
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"HEAD"];
  [[[NSURLSession sharedSession]
      dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response,
                            NSError *error) {
          handler(error == NULL);
        }] resume];
}

- (void)checkText:(NSString *)text
             lang:(NSString *)lang
          options:(NSString *)options
               ie:(NSString *)ie
        onSuccess:(void (^)(NSArray *result))success
        onFailure:(void (^)(NSError *error, NSInteger code))failure {

  NSDictionary *params = [NSDictionary
      dictionaryWithObjectsAndKeys:text, @"text", lang, @"lang", options,
                                   @"options", ie, @"ie", nil];

  [self.requestOperationManager GET:ALYandexSpellerCheckText
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"JSON : %@", responseObject);
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in responseObject) {

          NSNumber *code = [dict objectForKey:@"code"];
          NSNumber *column = [dict objectForKey:@"col"];
          NSNumber *length = [dict objectForKey:@"len"];
          NSNumber *position = [dict objectForKey:@"pos"];
          NSNumber *row = [dict objectForKey:@"row"];

          ALSpellResult *temp = [[ALSpellResult alloc]
              initWithStrings:[dict objectForKey:@"s"]
                         code:[code integerValue]
                       column:[column integerValue]
                       length:[length integerValue]
                     position:[position integerValue]
                          row:[row integerValue]
                         word:[dict objectForKey:@"word"]];
          [results addObject:temp];
        }
        NSArray *array = [NSArray arrayWithArray:results];
        if (success) {
          success(array);
        }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error : %@", error);
        if (failure) {
          failure(error, operation.response.statusCode);
        }
      }];
}

@end