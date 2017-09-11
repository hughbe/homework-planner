//
//  CreateHomeworkWorkSetView.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateHomeworkWorkSetView.h"

#import "SZTextView.h"
#import "Attachment.h"

@implementation CreateHomeworkWorkSetView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing:)]];
    self.mainView.layer.cornerRadius = 2.5;
    
    self.workSetTextView.font = [UIFont systemFontOfSize:17.5];
    self.workSetTextView.placeholder = @"Work Set";
    self.workSetTextView.placeholderTextColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    CAShapeLayer *typeViewBorder = [CAShapeLayer layer];
    typeViewBorder.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    typeViewBorder.fillColor = nil;
    typeViewBorder.lineDashPattern = @[@4, @2];
    typeViewBorder.path = [UIBezierPath bezierPathWithRect:self.typeView.bounds].CGPath;
    [self.typeView.layer addSublayer:typeViewBorder];
    
    CAShapeLayer *attachmentsViewBorder = [CAShapeLayer layer];
    attachmentsViewBorder.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    attachmentsViewBorder.fillColor = nil;
    attachmentsViewBorder.lineDashPattern = @[@4, @2];
    attachmentsViewBorder.path = [UIBezierPath bezierPathWithRect:self.attachmentsView.bounds].CGPath;
    [self.attachmentsView.layer addSublayer:attachmentsViewBorder];
    
    self.createWebsiteView.delegate = self;
    self.createPhotoView.delegate = self;
    self.mainView.center = self.center;
    [self reset];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self verify];
}

- (void)verify {
    self.navigationItem.rightBarButtonItem.enabled = self.workSetTextView.text.length > 0;
}

- (void)reset {
    self.workSetTextView.text = @"";
    [self verify];
    
    self.homeworkType = HomeworkTypeNone;
    [self.typeButton setTitle:@"No Type" forState:UIControlStateNormal];
    
    self.attachments = [NSMutableArray array];
    
    self.createWebsiteView.center = CGPointMake(self.center.x + self.frame.size.width, self.center.y);
    [self.createWebsiteView reset];
    
    self.createPhotoView.center = self.createWebsiteView.center;
    [self.createPhotoView reset];
}

- (IBAction)next:(id)sender {
    [self.delegate createHomeworkWorkSetViewDidGoForward:self];
}

- (IBAction)back:(id)sender {
    [self.delegate createHomeworkWorkSetViewDidGoBack:self];
}

- (IBAction)addWebsite:(id)sender {
    [self endEditing:YES];
    void(^ShowCreateWebsiteBlock)() = ^() {
        self.createWebsiteView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.mainView.frame;
            frame.origin.y = self.frame.size.height;
            self.mainView.frame = frame;
        }];
        [UIView animateWithDuration:0.35 animations:^{
            self.createWebsiteView.center = CGPointMake(self.center.x - self.frame.size.width, self.center.y);
        }];
    };
    BOOL noWebsites = YES;
    NSMutableArray *titles = [NSMutableArray array];
    for (Attachment *attachment in [self.attachments copy]) {
        if(attachment.type == AttachmentTypeWebsite) {
            noWebsites = NO;
            [titles addObject:attachment.title];
        }
    }

    // Show the website creator page if there are no websites.
    if(noWebsites) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        ShowCreateWebsiteBlock();
    }
    else {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Websites" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *create = [UIAlertAction actionWithTitle:@"Add Website" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
            ShowCreateWebsiteBlock();
        }];

        [actionSheet addAction:create];
        
        NSInteger i = 0;
        for (NSString *websiteTitle in titles) {
            i++;

            [UIAlertAction actionWithTitle:websiteTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                Attachment *attachment = [self filteredAttachmentsArrayForType:AttachmentTypeWebsite][i];
                UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAttachment:)];
                deleteButton.tag = i;
                [self.navigationItem setRightBarButtonItem:deleteButton animated:YES];
                self.createWebsiteView.attachment = attachment;

                ShowCreateWebsiteBlock();
            }];
        }
        
        [self.window.rootViewController presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (IBAction)addPhoto:(id)sender {
    [self endEditing:YES];
    void(^ShowCreatePhotoBlock)() = ^() {
        self.createPhotoView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.mainView.frame;
            frame.origin.y = self.frame.size.height;
            self.mainView.frame = frame;
        }];
        [UIView animateWithDuration:0.35 animations:^{
            self.createPhotoView.center = CGPointMake(self.center.x - self.frame.size.width, self.center.y);
        }];
    };
    
    BOOL noPhotos = YES;
    NSMutableArray *titles = [NSMutableArray array];
    for (Attachment *attachment in [self.attachments copy]) {
        if(attachment.type == AttachmentTypePhoto) {
            noPhotos = NO;
            [titles addObject:attachment.title];
        }
    }
    
    // Show the photo creator page if there are no photos.
    if(noPhotos) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        ShowCreatePhotoBlock();
    }
    else {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Photos" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *create = [UIAlertAction actionWithTitle:@"Add Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
            ShowCreatePhotoBlock();
        }];
        
        [actionSheet addAction:create];
        
        NSInteger i = 0;
        for (NSString *photoTitle in titles) {
            i++;
            
            [UIAlertAction actionWithTitle:photoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                Attachment *attachment = [self filteredAttachmentsArrayForType:AttachmentTypePhoto][i];
                UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAttachment:)];
                deleteButton.tag = i;
                [self.navigationItem setRightBarButtonItem:deleteButton animated:YES];
                self.createPhotoView.attachment = attachment;
                
                ShowCreatePhotoBlock();
            }];
        }
        
        [self.window.rootViewController presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (void)deleteAttachment:(UIBarButtonItem *)sender {
    if((NSUInteger)sender.tag < self.attachments.count) {
        [self.attachments removeObjectAtIndex:sender.tag];
        [self createPhotoViewDidCancel:self.createPhotoView];
        [self createWebsiteViewDidCancel:self.createWebsiteView];
    }
}

- (NSArray *)filteredAttachmentsArrayForType:(AttachmentType)type {
    NSMutableArray *filteredAttachments = [NSMutableArray array];
    for (Attachment *attachment in [self.attachments copy]) {
        if(attachment.type == type) {
            [filteredAttachments addObject:attachment];
        }
    }
    return [filteredAttachments copy];
}

- (void)addHomeworkType:(NSString *)typeString withType:(HomeworkType)type toAlertController:(UIAlertController *)alertController {
    UIAlertAction *typeAction = [UIAlertAction actionWithTitle:typeString style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        self.homeworkType = type;
        [self.typeButton setTitle:typeString forState:UIControlStateNormal];
    }];
    [alertController addAction:typeAction];
}

- (IBAction)changeType:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Homework Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [self addHomeworkType:@"Essay" withType:HomeworkTypeEssay toAlertController:actionSheet];
    [self addHomeworkType:@"Exercise" withType:HomeworkTypeExercise toAlertController:actionSheet];
    [self addHomeworkType:@"Revision" withType:HomeworkTypeRevision toAlertController:actionSheet];
    [self addHomeworkType:@"Notes" withType:HomeworkTypeNotes toAlertController:actionSheet];
    [self addHomeworkType:@"Other" withType:HomeworkTypeOther toAlertController:actionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [actionSheet addAction:cancel];
    
    [self.window.rootViewController presentViewController:actionSheet animated:YES completion:nil];
}

- (void)createPhotoViewDidCancel:(CreatePhotoView *)createPhotoView {
    [self endEditing:YES];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next:)] animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint centerOffset = self.center;
        centerOffset.x += self.frame.size.width;
        self.createPhotoView.center = centerOffset;
    } completion:^(BOOL finished) {
        [self.createPhotoView reset];
    }];
    [UIView animateWithDuration:0.35 animations:^{
        self.mainView.center = CGPointMake(self.center.x - self.frame.size.width, self.center.y);
    }];
}

- (void)createPhotoViewDidCreate:(CreatePhotoView *)createPhotoView {
    if(![self.attachments containsObject:createPhotoView.attachment]) {
        [self.attachments addObject:createPhotoView.attachment];
    }
    [self createPhotoViewDidCancel:createPhotoView];
}

- (void)createWebsiteViewDidCancel:(CreateWebsiteView *)createWebsiteView {
    [self endEditing:YES];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next:)] animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint centerOffset = self.center;
        centerOffset.x += self.frame.size.width;
        self.createWebsiteView.center = centerOffset;
    } completion:^(BOOL finished) {
        [self.createWebsiteView reset];
    }];
    [UIView animateWithDuration:0.35 animations:^{
        self.mainView.center = CGPointMake(self.center.x - self.frame.size.width, self.center.y);
    }];
}

- (void)createWebsiteViewDidCreate:(CreateWebsiteView *)createWebsiteView {
    if(![self.attachments containsObject:createWebsiteView.attachment]) {
        [self.attachments addObject:createWebsiteView.attachment];
    }
    [self createWebsiteViewDidCancel:createWebsiteView];
}

- (NSMutableArray *)attachments {
    if(!_attachments) {
        _attachments = [NSMutableArray array];
    }
    return _attachments;
}

@end
