//
//  ALTextVC.m
//  ALYandexSpeller
//
//  Created by Andrew Lebedev on 11.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "ALTextVC.h"
#import "ALStyleKit.h"
#import "ALServerManager.h"
#import "ALSpellResult.h"
#import "TSMessage.h"

@interface ALTextVC ()

@end

@implementation ALTextVC

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = @"Спеллер";
  self.correctedCount = 0;
  self.ok = NO;
  self.current = -1;

  UIColor *gray = [UIColor lightGrayColor];

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.tableFooterView = [[UIView alloc] init];

  self.buttonCorrect.clipsToBounds = YES;
  self.buttonCorrect.layer.cornerRadius = 3;
  self.buttonCorrect.layer.borderWidth = 1.0f;
  self.buttonCorrect.layer.borderColor = [gray CGColor];

  self.buttonCopy.clipsToBounds = YES;
  self.buttonCopy.layer.cornerRadius = 3;
  self.buttonCopy.layer.borderWidth = 1.0f;
  self.buttonCopy.layer.borderColor = [gray CGColor];

  self.buttonPaste.clipsToBounds = YES;
  self.buttonPaste.layer.cornerRadius = 3;
  self.buttonPaste.layer.borderWidth = 1.0f;
  self.buttonPaste.layer.borderColor = [gray CGColor];

  self.buttonClear.clipsToBounds = YES;
  self.buttonClear.layer.cornerRadius = 3;
  self.buttonClear.layer.borderWidth = 1.0f;
  self.buttonClear.layer.borderColor = [gray CGColor];

  self.contentView.clipsToBounds = YES;
  self.contentView.layer.borderWidth = 1.0f;
  self.contentView.layer.borderColor =
      [[gray colorWithAlphaComponent:0.4] CGColor];

  UIImage *img = [self imageOfCanvas1WithColor:[ALStyleKit yandexColor]];
  [self.navigationController.navigationBar
      setBackgroundImage:img
           forBarMetrics:UIBarMetricsDefault];

  UIImage *nextImage = [UIImage imageNamed:@"forward.png"];
  UIImage *prevImage = [UIImage imageNamed:@"back.png"];
  UIImage *optionImage = [UIImage imageNamed:@"settings.png"];

  [self.buttonPrev setImage:prevImage forState:UIControlStateNormal];
  [self.buttonNext setImage:nextImage forState:UIControlStateNormal];
  [self.buttonOption setImage:optionImage forState:UIControlStateNormal];

  self.buttonNext.tintColor = gray;
  self.buttonPrev.tintColor = gray;
  self.buttonOption.tintColor = [UIColor blackColor];

  [self.buttonNext setTitle:@"" forState:UIControlStateNormal];
  [self.buttonPrev setTitle:@"" forState:UIControlStateNormal];
  [self.buttonOption setTitle:@"" forState:UIControlStateNormal];

  self.textView.text = @"";

  [[ALServerManager sharedManager]
      checkInternetConnectionWithHandler:^(BOOL check) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (!check) {
            [self messageErrorInternetConnection:YES];
          }
        });
      }];
}

- (UIImage *)imageOfCanvas1WithColor:(UIColor *)color {
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(3, 3), NO, 0.0f);
  UIBezierPath *rectanglePath =
      [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 3, 3)];
  [color setFill];
  [rectanglePath fill];

  UIImage *im = [UIGraphicsGetImageFromCurrentImageContext()
      resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)
                     resizingMode:UIImageResizingModeTile];
  UIGraphicsEndImageContext();

  return im;
}

#pragma mark - TSMessages

- (void)messageErrorInternetConnection:(BOOL)animated {
  [TSMessage
      showNotificationWithTitle:@"Что-то не так"
                       subtitle:
                           @"Пропало соединение с интернет. "
                           @"Проверьте!"
                           type:TSMessageNotificationTypeError];
}

- (void)messageSuccess:(BOOL)animated {
  [TSMessage
      showNotificationWithTitle:@"Исправление завершено"
                       subtitle:
                           @"Исправленные слова подсвечены цветом "
                           @"#FFCC00"
                           type:TSMessageNotificationTypeSuccess];
}

- (void)messageCoppied:(BOOL)animated {
  [TSMessage
      showNotificationWithTitle:@"Скопировано"
                       subtitle:
                           @"Текст скопирован в буфер"
   
                           type:TSMessageNotificationTypeSuccess];
}

#pragma mark - getResponse

- (void)checkText:(NSString *)text {
  [[ALServerManager sharedManager] checkText:text
      lang:@"ru,en"
      options:@"0"
      ie:@"utf-8"
      onSuccess:^(NSArray *result) {
        self.substitutions = [NSMutableArray arrayWithArray:result];
      }
      onFailure:^(NSError *error, NSInteger code) {
        NSLog(@"Error at - (void)checkText: in "
              @"ALTextVC: error = %@, code = %ld",
              [error localizedDescription], (long)code);
      }];
}

#pragma mark - IBAction Methods

- (IBAction)pasteButton:(id)sender {
  UIPasteboard *pb = [UIPasteboard generalPasteboard];
  self.textView.text = [pb string];
  [self check];
}

- (IBAction)copyButton:(id)sender {
  UIPasteboard *pb = [UIPasteboard generalPasteboard];
  [pb setString:self.textView.text];
  [self messageCoppied:YES];
  [self clearAttributes];
  [self clearTable];
}

- (IBAction)clearButton:(id)sender {
  [self clearAttributes];
  self.textView.text = @"";
  [self clearTable];
}

- (void)clearTable {

  [self.substitutions removeAllObjects];
  self.current = -1;
  self.correctedCount = 0;
  self.ok = YES;
  [self.tableView reloadData];
}

- (IBAction)optionsButton:(id)sender {
  /*
  dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:@"IdentifierOptionsTVC" sender:self];
  });
  */
}

- (IBAction)correctButton:(id)sender {
  if ([self isOK]) {
    // NSLog(@"returned");
    return;
  }

  for (NSInteger i = 0; i < [self.substitutions count]; ++i) {
    ALSpellResult *currentResult = self.substitutions[i];
    NSRange selectedRange =
        NSMakeRange(currentResult.position, currentResult.length);
    UITextPosition *begin = self.textView.beginningOfDocument;
    UITextPosition *start =
        [self.textView positionFromPosition:begin
                                     offset:selectedRange.location];
    UITextPosition *end =
        [self.textView positionFromPosition:start offset:selectedRange.length];
    UITextRange *sameRange =
        [self.textView textRangeFromPosition:start toPosition:end];
    if ([currentResult.strings count] != 0) {
      NSString *word = currentResult.strings[0];
      NSInteger difference = word.length - selectedRange.length;
      if (difference != 0) {
        for (NSInteger j = i + 1; j < [self.substitutions count]; ++j) {
          ALSpellResult *sub = self.substitutions[j];
          sub.position += difference;
        }
      }

      [self.textView replaceRange:sameRange withText:currentResult.strings[0]];

      currentResult.length = word.length;
      NSUInteger oldLocation = selectedRange.location;
      selectedRange = NSMakeRange(oldLocation, word.length);

      NSMutableAttributedString *attributedString =
          [[NSMutableAttributedString alloc]
              initWithAttributedString:self.textView.attributedText];
      [attributedString addAttribute:NSForegroundColorAttributeName
                               value:[ALStyleKit yandexColor]
                               range:selectedRange];
      self.textView.attributedText = attributedString;
    }
  }
  self.ok = YES;
  [self messageSuccess:YES];
}

- (IBAction)nextWord {

  if ([self isOK]) {
    [self clearAttributes];
    [self clearTable];
    return;
  }
  [self increaseCurrent];
  [self.tableView reloadData];
  [self clearAttributes];
  ALSpellResult *result = self.substitutions[self.current];
  NSRange selectedRange = NSMakeRange(result.position, result.length);
  if ([result.strings count] != 0) {
    UIColor *color;
    if (result.correct == NO) {
      color = [UIColor redColor];
    } else {
      color = [ALStyleKit yandexColor];
    }

    NSMutableAttributedString *attributedString =
        [[NSMutableAttributedString alloc]
            initWithAttributedString:self.textView.attributedText];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:color
                             range:selectedRange];
    self.textView.attributedText = attributedString;
  }
  self.currentRange = selectedRange;
}

- (IBAction)previousWord {
  if ([self isOK]) {
    [self clearAttributes];
    [self clearTable];
    return;
  }
  [self decreaseCurrent];
  [self.tableView reloadData];
  [self clearAttributes];
  ALSpellResult *result = self.substitutions[self.current];
  NSRange selectedRange = NSMakeRange(result.position, result.length);
  if ([result.strings count] != 0) {
    UIColor *color;
    if (result.correct == NO) {
      color = [UIColor redColor];
    } else {
      color = [ALStyleKit yandexColor];
    }
    NSMutableAttributedString *attributedString =
        [[NSMutableAttributedString alloc]
            initWithAttributedString:self.textView.attributedText];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:color
                             range:selectedRange];
    self.textView.attributedText = attributedString;
  }

  self.currentRange = selectedRange;
}

#pragma mark - textView Methods

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {

  if ([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  [self clearAttributes];
  self.buttonNext.enabled = NO;
  self.buttonPrev.enabled = NO;
  self.tableView.hidden = YES;
  
  UITextPosition *beginning = [textView beginningOfDocument];
  [textView setSelectedTextRange:[textView textRangeFromPosition:beginning
                                                      toPosition:beginning]];

  UIColor *color = [ALStyleKit yandexColor];
  self.contentView.layer.borderColor = color.CGColor;
  self.contentView.layer.borderWidth = 2.0f;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  self.buttonNext.enabled = YES;
  self.buttonPrev.enabled = YES;
    
  self.tableView.hidden = NO;
  UIColor *color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
  self.contentView.layer.borderColor = color.CGColor;
  self.contentView.layer.borderWidth = 1.0f;
  self.current = -1;

  [self clearAttributes];
  [self clearTable];
  [self check];
}

#pragma mark - tableView Methods

- (void)tableView:(UITableView *)tableView
    didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *temp = [self.tableView cellForRowAtIndexPath:indexPath];
  [UIView animateWithDuration:0.1
                   animations:^{
                     temp.accessoryView.tintColor = [UIColor lightGrayColor];
                   }];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *temp = [self.tableView cellForRowAtIndexPath:indexPath];
  [UIView animateWithDuration:0.1
                   animations:^{
                     temp.accessoryView.tintColor = [ALStyleKit yandexColor];
                   }];

  UITextPosition *begin = self.textView.beginningOfDocument;
  UITextPosition *start =
      [self.textView positionFromPosition:begin
                                   offset:self.currentRange.location];
  UITextPosition *end =
      [self.textView positionFromPosition:start
                                   offset:self.currentRange.length];
  UITextRange *sameRange =
      [self.textView textRangeFromPosition:start toPosition:end];

  NSInteger difference = temp.textLabel.text.length - self.currentRange.length;
  if (difference != 0) {
    for (NSInteger i = self.current + 1; i < [self.substitutions count]; ++i) {
      ALSpellResult *sub = self.substitutions[i];
      sub.position += difference;
    }
  }

  [self.textView replaceRange:sameRange withText:temp.textLabel.text];

  ALSpellResult *tempSub = self.substitutions[self.current];
  tempSub.length = temp.textLabel.text.length;

  NSUInteger oldLocation = self.currentRange.location;
  self.currentRange = NSMakeRange(oldLocation, temp.textLabel.text.length);

  NSMutableAttributedString *attributedString =
      [[NSMutableAttributedString alloc]
          initWithAttributedString:self.textView.attributedText];
  [attributedString addAttribute:NSForegroundColorAttributeName
                           value:[ALStyleKit yandexColor]
                           range:self.currentRange];
  self.textView.attributedText = attributedString;
  if (tempSub.correct != YES) {
    self.correctedCount++;
    if (self.correctedCount == [self.substitutions count]) {
      self.ok = YES;
    }
  }
  tempSub.correct = YES;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  if (![self isOK]) {
    ALSpellResult *temp = self.substitutions[self.current];
    // NSLog(@"numberOfRowsInSection: %ld", [temp.strings count]);
    return [temp.strings count];
  }
  return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

  static NSString *identifier = @"Cell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:identifier];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:identifier];
  }
  UIImage *mark = [UIImage imageNamed:@"checkmark.png"];
  UIImage *tempImg =
      [mark imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  UIImageView *checkmark = [[UIImageView alloc] initWithImage:tempImg];
  NSString *name;
  if (self.current != -1) {
    ALSpellResult *temp = self.substitutions[self.current];
    name = temp.strings[indexPath.row];
  }

  checkmark.tintColor = [UIColor lightGrayColor];
  cell.textLabel.text = name;
  cell.accessoryView = checkmark;

  return cell;
}

#pragma mark - Other Methods

- (void)clearAttributes {

  UIColor *blackColor = [UIColor blackColor];
  UIFont *font = [UIFont systemFontOfSize:14.0];
  NSDictionary *attributes = [NSDictionary
      dictionaryWithObjectsAndKeys:blackColor, NSForegroundColorAttributeName,
                                   font, NSFontAttributeName, nil];
  NSAttributedString *str =
      [[NSAttributedString alloc] initWithString:self.textView.text
                                      attributes:attributes];
  self.textView.attributedText = str;
}

- (BOOL)isOK {
  return self.ok;
}

- (void)check {
  [self checkText:self.textView.text];
  if ([self isOK]) {
    [self clearAttributes];
  }
}

- (void)increaseCurrent {
  if (self.current != -1) {
    if (self.current != [self.substitutions count] - 1) {
      self.current++;
    } else {
      self.current = 0;
      if (self.correctedCount == [self.substitutions count]) {
        [self clearAttributes];
        [self clearTable];
      }
    }
  } else {
    self.current = 0;
  }
}

- (void)decreaseCurrent {
  if (self.current != -1) {
    if (self.current != 0) {
      self.current--;
    } else {
      self.current = [self.substitutions count] - 1;
      if (self.correctedCount == [self.substitutions count]) {
        [self clearAttributes];
        [self clearTable];
      }
    }
  } else {
    self.current = [self.substitutions count] - 1;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)setSubstitutions:(NSMutableArray *)substitutions {
  if ([substitutions count] == 0) {
    self.ok = YES;
    [self.tableView reloadData];
  } else {
    _substitutions = substitutions;
    self.ok = NO;
  }
}

@end
