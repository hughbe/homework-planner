//
//  CreateHomeworkWorkSetView.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Homework.h"
#import "CreateWebsiteView.h"
#import "CreatePhotoView.h"

@class SZTextView;

@protocol CreateHomeworkWorkSetViewDelegate;

@interface CreateHomeworkWorkSetView : UIView <UITextFieldDelegate, CreateWebsiteViewDelegate, CreatePhotoViewDelegate, UITextViewDelegate>

- (void)reset;
- (void)verify;

@property (weak, nonatomic) id<CreateHomeworkWorkSetViewDelegate> delegate;

@property (assign, nonatomic) HomeworkType homeworkType;
@property (strong, nonatomic) NSMutableArray *attachments;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet SZTextView *workSetTextView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (strong, nonatomic) IBOutlet UIView *attachmentsView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;

@property (weak, nonatomic) IBOutlet UIView *typeView;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@property (weak, nonatomic) IBOutlet CreateWebsiteView *createWebsiteView;
@property (weak, nonatomic) IBOutlet CreatePhotoView *createPhotoView;

@end

@protocol CreateHomeworkWorkSetViewDelegate <NSObject>

- (void)createHomeworkWorkSetViewDidGoBack:(CreateHomeworkWorkSetView *)createHomeworkWorkSetView;
- (void)createHomeworkWorkSetViewDidGoForward:(CreateHomeworkWorkSetView *)createHomeworkWorkSetView;

@end
