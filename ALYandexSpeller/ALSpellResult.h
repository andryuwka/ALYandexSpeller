//
//  ALSpellResult.h
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 12.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALSpellResult : NSObject

@property(nonatomic) NSInteger code;
@property(nonatomic) NSInteger column;
@property(nonatomic) NSInteger length;
@property(nonatomic) NSInteger position;
@property(nonatomic) NSInteger row;
@property(nonatomic, strong) NSString *word;
@property(nonatomic, strong) NSArray *strings;
@property(nonatomic) BOOL correct;

- (id)initWithStrings:(NSArray *)strings
                 code:(NSInteger)code
               column:(NSInteger)column
               length:(NSInteger)length
             position:(NSInteger)position
                  row:(NSInteger)row
                 word:(NSString*)word;
- (void)description;





@end
