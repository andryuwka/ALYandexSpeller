//
//  ALOptions.m
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 14.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "ALOptions.h"

@implementation ALOptions

- (id)init {
  ALOptions *options = [super init];
  options.ignoreUppercase = 0;
  options.ignoreDigits = 0;
  options.ignoreUrls = 0;
  options.findRepeatWords = 0;
  options.ignoreLatin = 0;
  options.noSuggest = 0;
  options.flagLatin = 0;
  options.byWords = 0;
  options.ignoreCapitalization = 0;
  options.ignoreRomanNumerals = 0;
  return options;
}

- (NSInteger) saveSettings {
  
  self.summ = self.ignoreCapitalization +
  self.ignoreDigits +
  self.ignoreUrls +
  self.findRepeatWords +
  self.ignoreLatin +
  self.noSuggest +
  self.flagLatin +
  self.byWords +
  self.ignoreCapitalization +
  self.ignoreRomanNumerals;
  
  return self.summ;
}





@end
