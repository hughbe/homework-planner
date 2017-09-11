//
//  QuickHomeworkView.h
//  School Planner
//
//  Created by Hugh Bellamy on 14/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentPreviewView.h"

@protocol QuickHomeworkViewDelegate;
@class Homework;

@interface QuickHomeworkView : UIView <UITableViewDelegate, UITableViewDataSource, AttachmentPreviewViewDelegate>

+ (QuickHomeworkView *)quickHomeworkView;

@property (weak, nonatomic) id<QuickHomeworkViewDelegate> delegate;

@property (strong, nonatomic) Homework *homework;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UITableView *attachmentsTableView;
@property (weak, nonatomic) IBOutlet AttachmentPreviewView *attachmentPreviewView;

@property (weak, nonatomic) IBOutlet UIView *homeworkTimeContainerView;
@property (weak, nonatomic) IBOutlet UIView *homeworkDateEndContainerView;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (weak, nonatomic) IBOutlet UIView *homeworkDateContainerView;
@property (weak, nonatomic) IBOutlet UILabel *homeworkDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;

@property (weak, nonatomic) IBOutlet UIView *homeworkSubjectContainerView;
@property (weak, nonatomic) IBOutlet UILabel *homeworkSubjectLabel;

@property (weak, nonatomic) IBOutlet UIView *homeworkSummaryContainerView;
@property (weak, nonatomic) IBOutlet UITextView *homeworkSummaryLabel;

@property (weak, nonatomic) IBOutlet UIButton *attachmentsButton;
@property (weak, nonatomic) IBOutlet UILabel *attachmentsNumberLabel;

@end

@protocol QuickHomeworkViewDelegate <NSObject>

- (void)quickHomeworkViewDidClose:(QuickHomeworkView *)quickHomeworkView;

@end
