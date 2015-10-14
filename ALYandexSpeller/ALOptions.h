//
//  ALOptions.h
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 14.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALOptions : NSObject

@property(nonatomic) NSInteger ignoreUppercase;
@property(nonatomic) NSInteger ignoreDigits;
@property(nonatomic) NSInteger ignoreUrls;
@property(nonatomic) NSInteger findRepeatWords;
@property(nonatomic) NSInteger ignoreLatin;
@property(nonatomic) NSInteger noSuggest;
@property(nonatomic) NSInteger flagLatin;
@property(nonatomic) NSInteger byWords;
@property(nonatomic) NSInteger ignoreCapitalization;
@property(nonatomic) NSInteger ignoreRomanNumerals;

@property(nonatomic) NSInteger summ;


- (id)init;
- (NSInteger)saveSettings;



@end
