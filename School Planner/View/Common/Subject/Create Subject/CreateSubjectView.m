//
//  CreateSubjectView.m
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateSubjectView.h"

#import "UIView+Borders.h"
#import "UIKitLocalizedString.h"

#import "Subject.h"

@interface CreateSubjectView ()

@property (strong, nonatomic) UIButton *selectedButton;

@end

@implementation CreateSubjectView

@synthesize subject = _subject;

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
    [self.cancelButton setTitle:UIKitLocalizedString(UIKitCancelIdentifier) forState:UIControlStateNormal];
    [self.createButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    self.selectedButton = nil;
    for (UIButton *button in self.colorsView.subviews) {
        button.layer.borderWidth = 0.0;
    }

    CGRect frame = self.colorsView.frame;
    frame.origin.x = self.frame.size.width;
    self.colorsView.frame = frame;
    self.subject = nil;
    self.hidden = YES;
    [self verify];
}

- (IBAction)selectedColor:(UIButton *)sender {
    for (UIButton *button in self.colorsView.subviews) {
        button.layer.borderWidth = 0.0;
    }
    sender.layer.borderWidth = 1.0;
    self.selectedButton = sender;
    [self verify];
}

- (IBAction)verify {
    if(self.colorsView.frame.origin.x) {
        self.subject.subjectName = self.subjectTextField.text;
        self.subject.teacher = self.teacherTextField.text;
        self.createButton.enabled = self.subjectTextField.text.length && self.teacherTextField.text.length;
    }
    else {
        self.createButton.enabled = self.selectedButton != nil;
    }
}

- (IBAction)cancelCreation:(id)sender {
    [self endEditing:YES];
    if(!self.colorsView.frame.origin.x) {
        [self.cancelButton setTitle:UIKitLocalizedString(UIKitCancelIdentifier) forState:UIControlStateNormal];
        [self.createButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.colorsView.frame;
            frame.origin.x = self.frame.size.width;
            self.colorsView.frame = frame;
        } completion:^(BOOL finished) {
            [self verify];
        }];
    }
    else {
        [self.delegate createSubjectViewDidCancel:self];
    }
}

- (IBAction)completeCreation:(id)sender {
    [self endEditing:YES];
    if(self.colorsView.frame.origin.x) {
        [self.cancelButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
        [self.createButton setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.colorsView.frame;
            frame.origin.x = 0;
            self.colorsView.frame = frame;
        } completion:^(BOOL finished) {
            [self verify];
        }];
    }
    else {
        self.subject.color = self.selectedButton.backgroundColor;
        [self.delegate createSubjectViewDidCreate:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.subjectTextField) {
        [self.teacherTextField becomeFirstResponder];
        return NO;
    }
    else {
        [self completeCreation:self.createButton];
        return YES;
    }
}

- (Subject *)subject {
    if(!_subject) {
        _subject = [[Subject alloc]init];
    }
    return _subject;
}

- (void)setSubject:(Subject *)subject {
    _subject = subject;
    
    for (UIButton *button in self.colorsView.subviews) {
        if([button.backgroundColor isEqual:self.subject.color]) {
            self.selectedButton = button;
            self.selectedButton.layer.borderWidth = 1.0;
        }
        else {
            button.layer.borderWidth = 0.0;
        }
    }
    self.subjectTextField.text = subject.subjectName;
    self.teacherTextField.text = subject.teacher;
    
    [self verify];
}

@end
