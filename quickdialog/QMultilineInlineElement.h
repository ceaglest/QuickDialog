//
//  QMultilineInlineElement.h
//  QuickDialog
//
//  Created by Christopher Eagleston on 6/22/13.
//
//

#import "QEntryElement.h"

@class QMultilineInlineElement;
@protocol QuickDialogEntryElementDelegate;

@interface QMultilineInlineElement : QEntryElement

@property (nonatomic, assign) id<QuickDialogEntryElementDelegate> delegate;

- (QMultilineInlineElement *)initWithTitle:(NSString *)title value:(NSString *)text;

@end
