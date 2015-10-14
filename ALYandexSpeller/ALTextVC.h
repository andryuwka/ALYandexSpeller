//
//  ALTextVC.h
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 11.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALTextVC
    : UIViewController <UITextViewDelegate, UITableViewDataSource,
                        UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UIView *contentView;
@property(weak, nonatomic) IBOutlet UITextView *textView;
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(weak, nonatomic) IBOutlet UIButton *buttonOption;
@property(weak, nonatomic) IBOutlet UIButton *buttonClear;
@property(weak, nonatomic) IBOutlet UIButton *buttonNext;
@property(weak, nonatomic) IBOutlet UIButton *buttonPrev;
@property(weak, nonatomic) IBOutlet UIButton *buttonCorrect;
@property(weak, nonatomic) IBOutlet UIButton *buttonPaste;
@property(weak, nonatomic) IBOutlet UIButton *buttonCopy;



@property(nonatomic) NSInteger current;
@property(nonatomic) NSRange currentRange;
@property(nonatomic) NSInteger correctedCount;
@property(nonatomic) BOOL ok;
@property(nonatomic, strong) NSMutableArray *substitutions;

- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text;

- (void)tableView:(UITableView *)tableView
    didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (BOOL)isOK;
- (void)setSubstitutions:(NSMutableArray *)substitutions;
@end
