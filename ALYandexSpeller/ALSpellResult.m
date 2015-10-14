//
//  ALSpellResult.m
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 12.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "ALSpellResult.h"

@implementation ALSpellResult

- (id)initWithStrings:(NSArray *)strings
                 code:(NSInteger)code
               column:(NSInteger)column
               length:(NSInteger)length
             position:(NSInteger)position
                  row:(NSInteger)row
                 word:(NSString*)word {
  
  ALSpellResult *temp = [super init];
  
  temp.strings = strings;
  temp.code = code;
  temp.column = column;
  temp.length = length;
  temp.position = position;
  temp.row = row;
  temp.word = word;
  temp.correct = NO;
  
  return temp;
}

- (void)description {
  
  NSLog(@"code = %ld;", self.code);
  NSLog(@"column = %ld;", self.column);
  NSLog(@"length = %ld;", self.length);
  NSLog(@"position = %ld;", self.position);
  NSLog(@"row = %ld;", self.row);
  NSLog(@"word = %@;", self.word);
  NSLog(@"substitutions = %@", self.strings);

}



@end
