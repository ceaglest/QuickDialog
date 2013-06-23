//
//  QMultilineEntryTableViewCell.m
//  QuickDialog
//
//  Created by Christopher Eagleston on 6/22/13.
//
//

#import "QMultilineEntryTableViewCell.h"

@implementation QMultilineEntryTableViewCell

- (void)createSubviews {
	
	_textView = [[UITextView alloc] init];
	_textView.delegate = self;
	_textView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
    [self.contentView addSubview:_textView];
    [self setNeedsLayout];
}

- (QMultilineEntryTableViewCell *)init {
    self = [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"QuickformMultilineEntryElement"];
    if (self!=nil){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		
        [self createSubviews];
    }
    return self;
}

// Todo: Placeholder support
- (void)prepareForElement:(QEntryElement *)element inTableView:(QuickDialogTableView *)tableView
{
    [self applyAppearanceForElement:element];
	
    self.labelingPolicy = element.labelingPolicy;
	
    _quickformTableView = tableView;
    _entryElement = element;
	
	self.accessoryType = _entryElement.accessoryType;
	
	_textView.text = _entryElement.textValue;
    _textView.autocapitalizationType = _entryElement.autocapitalizationType;
    _textView.autocorrectionType = _entryElement.autocorrectionType;
    _textView.keyboardType = _entryElement.keyboardType;
    _textView.keyboardAppearance = _entryElement.keyboardAppearance;
    _textView.secureTextEntry = _entryElement.secureTextEntry;
    _textView.textAlignment = _entryElement.appearance.entryAlignment;
	
    _textView.returnKeyType = _entryElement.returnKeyType;
    _textView.enablesReturnKeyAutomatically = _entryElement.enablesReturnKeyAutomatically;
	
	
    if (_entryElement.hiddenToolbar){
        _textView.inputAccessoryView = nil;
    } else {
        _textView.inputAccessoryView = [self createActionBar];
    }
	
    [self updatePrevNextStatus];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self recalculateEntryFieldPosition];
}

-(void)recalculateEntryFieldPosition {
    _entryElement.parentSection.entryPosition = CGRectZero;
    _textView.frame = [self calculateFrameForEntryElement];
}

- (CGRect)calculateFrameForEntryElement {
    CGFloat inset = 3;
	return CGRectInset(self.contentView.bounds, inset, inset);
	
//	int extra = 10;
//    if (_entryElement.title == NULL && _entryElement.image==NULL) {
//        return CGRectMake(10,10,self.contentView.frame.size.width-10-extra, self.frame.size.height-20);
//    }
//    if (_entryElement.title == NULL && _entryElement.image!=NULL){
//        self.imageView.image = _entryElement.image;
//        [self.imageView sizeToFit];
//        return CGRectMake( self.imageView.frame.size.width+10, 10, self.contentView.frame.size.width-10-self.imageView.frame.size.width-extra , self.frame.size.height-20);
//    }
//    CGFloat totalWidth = self.contentView.frame.size.width;
//    CGFloat titleWidth = 0;
//	
//    if (CGRectEqualToRect(CGRectZero, _entryElement.parentSection.entryPosition)) {
//        for (QElement *el in _entryElement.parentSection.elements){
//            if ([el isKindOfClass:[QEntryElement class]]){
//                QEntryElement *q = (QEntryElement*)el;
//                CGFloat imageWidth = q.image == NULL ? 0 : self.imageView.frame.size.width;
//                CGFloat fontSize = self.textLabel.font.pointSize == 0? 17 : self.textLabel.font.pointSize;
//                CGSize size = [((QEntryElement *)el).title sizeWithFont:[self.textLabel.font fontWithSize:fontSize] forWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByWordWrapping] ;
//                CGFloat width = size.width + imageWidth;
//                if (width>titleWidth)
//                    titleWidth = width;
//            }
//        }
//        _entryElement.parentSection.entryPosition = CGRectMake(titleWidth+20,10,totalWidth-titleWidth-20-extra, self.frame.size.height-20);
//    }
//	
//    return _entryElement.parentSection.entryPosition;
}


- (void)textFieldEditingChanged:(UITextField *)textFieldEditingChanged {
	_entryElement.textValue = _textField.text;
    
    [self handleEditingChanged];
}

- (void)handleEditingChanged
{
    if(_entryElement && _entryElement.delegate && [_entryElement.delegate respondsToSelector:@selector(QEntryEditingChangedForElement:andCell:)]){
        [_entryElement.delegate QEntryEditingChangedForElement:_entryElement andCell:self];
    }
    
    if(_entryElement.onValueChanged) {
        _entryElement.onValueChanged(_entryElement);
    }
}

#pragma mark - UITextView Delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 50 * USEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_quickformTableView scrollToRowAtIndexPath:[_entryElement getIndexPath] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
	
	
    if (_textField.returnKeyType == UIReturnKeyDefault) {
        UIReturnKeyType returnType = ([self findNextElementToFocusOn]!=nil) ? UIReturnKeyNext : UIReturnKeyDone;
        _textField.returnKeyType = returnType;
    }
	
    if(_entryElement && _entryElement.delegate && [_entryElement.delegate respondsToSelector:@selector(QEntryDidBeginEditingElement:andCell:)]){
        [_entryElement.delegate QEntryDidBeginEditingElement:_entryElement andCell:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _entryElement.textValue = textView.text;
    
    if(_entryElement && _entryElement.delegate && [_entryElement.delegate respondsToSelector:@selector(QEntryDidEndEditingElement:andCell:)]){
        [_entryElement.delegate QEntryDidEndEditingElement:_entryElement andCell:self];
    }
    
    [_entryElement performSelector:@selector(fieldDidEndEditing)];
}

// Todo: Detect return
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(_entryElement && _entryElement.delegate && [_entryElement.delegate respondsToSelector:@selector(QEntryShouldChangeCharactersInRange:withString:forElement:andCell:)]){
        return [_entryElement.delegate QEntryShouldChangeCharactersInRange:range withString:text forElement:_entryElement andCell:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    QEntryElement *element = [self findNextElementToFocusOn];
    if (element!=nil){
        UITableViewCell *cell = [_quickformTableView cellForElement:element];
        if (cell!=nil){
            [cell becomeFirstResponder];
        }
    }  else {
        [_textField resignFirstResponder];
    }
    
    if(_entryElement && _entryElement.delegate && [_entryElement.delegate respondsToSelector:@selector(QEntryShouldReturnForElement:andCell:)]){
        return [_entryElement.delegate QEntryShouldReturnForElement:_entryElement andCell:self];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _entryElement.textValue = textView.text;
	
    if(_entryElement && _entryElement.delegate && [_entryElement.delegate respondsToSelector:@selector(QEntryEditingChangedForElement:andCell:)]){
        [_entryElement.delegate QEntryEditingChangedForElement:_entryElement andCell:self];
    }
}

- (BOOL)handleActionBarDone:(UIBarButtonItem *)doneButton {
    [_textView resignFirstResponder];
    return [super handleActionBarDone:doneButton];
}

- (BOOL)becomeFirstResponder {
    [_textView becomeFirstResponder];
	return YES;
}

- (BOOL)resignFirstResponder {
	return YES;
}

- (void)applyAppearanceForElement:(QElement *)element {
    [super applyAppearanceForElement:element];
	
    QAppearance *appearance = element.appearance;
    _textView.font = appearance.entryFont;
    _textView.textColor = element.enabled ? appearance.entryTextColorEnabled : appearance.entryTextColorDisabled;
}


@end
