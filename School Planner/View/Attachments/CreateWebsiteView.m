//
//  CreateWebsiteView.m
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateWebsiteView.h"

#import "UIView+Borders.h"

#import "Attachment.h"

@implementation CreateWebsiteView

@synthesize attachment = _attachment;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.cancelButton.layer.cornerRadius = 0;
    self.createButton.layer.cornerRadius = 0;
    
    UIColor *buttonBorderColour = [UIColor colorWithWhite:0.8 alpha:1.0];
    CGFloat buttonBorderWidth = 1.75;
    
    [self.cancelButton addTopBorderWithHeight:buttonBorderWidth andColor:buttonBorderColour];
    [self.createButton addTopBorderWithHeight:buttonBorderWidth andColor:buttonBorderColour];
    
    self.layer.cornerRadius = 2.5;
    [self reset];
}

- (void)reset {
    self.attachment = nil;
    self.hidden = YES;
}

- (IBAction)verify {
    self.attachment.title = self.titleTextField.text;
    self.attachment.attachmentInfo = self.URLTextField.text;
    
    self.createButton.enabled = self.titleTextField.text.length && self.URLTextField.text.length;
}

- (IBAction)cancelCreation:(id)sender {
    [self.delegate createWebsiteViewDidCancel:self];
}

- (IBAction)completeCreation:(id)sender {
    [self.delegate createWebsiteViewDidCreate:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.titleTextField) {
        [self.URLTextField becomeFirstResponder];
        return NO;
    }
    else {
        [self completeCreation:self.createButton];
        return YES;
    }
}

- (Attachment *)attachment {
    if(!_attachment) {
        _attachment = [Attachment attachmentWithType:AttachmentTypeWebsite];
    }
    return _attachment;
}

- (void)setAttachment:(Attachment *)attachment {
    _attachment = attachment;
    self.titleTextField.text = self.attachment.title;
    self.URLTextField.text = self.attachment.attachmentInfo;
    [self verify];
}

@end
