//
//  QMultilineEntryTableViewCell.h
//  QuickDialog
//
//  Created by Christopher Eagleston on 6/22/13.
//
//

#import "QEntryTableViewCell.h"

@interface QMultilineEntryTableViewCell : QEntryTableViewCell <UITextViewDelegate>

@property(nonatomic, strong) UITextView *textView;

@end
