//
//  QMultilineInlineElement.m
//  QuickDialog
//
//  Created by Christopher Eagleston on 6/22/13.
//
//

#import "QMultilineInlineElement.h"
#import "QMultilineEntryTableViewCell.h"

@implementation QMultilineInlineElement

- (QEntryElement *)init {
    self = [super init];
    if (self) {
        self.presentationMode = QPresentationModePopover;
    }
	
    return self;
}

- (QMultilineInlineElement *)initWithTitle:(NSString *)title value:(NSString *)text
{
    if ((self = [super initWithTitle:title Value:nil])) {
        self.textValue = text;
        self.presentationMode = QPresentationModePopover;
    }
    return self;
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
	
	QMultilineEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuickformMultilineEntryElement"];
    if (cell==nil){
        cell = [[QMultilineEntryTableViewCell alloc] init];
    }
	
    [cell applyAppearanceForElement:self];
//    _controller = controller;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textView.userInteractionEnabled = self.enabled;
    [cell prepareForElement:self inTableView:tableView];
	
    return cell;
}


- (void)selected:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller indexPath:(NSIndexPath *)indexPath
{
    [super selected:tableView controller:controller indexPath:indexPath];
}


- (void)fetchValueIntoObject:(id)obj
{
	if (_key == nil) {
		return;
	}
	[obj setValue:self.textValue forKey:_key];
}

- (BOOL)canTakeFocus
{
    return [super canTakeFocus];
}

@end
