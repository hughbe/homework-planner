//
//  CreateHomeworkView.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SubjectsView.h"
#import "CreateHomeworkWorkSetView.h"
#import "CreateHomeworkDueDateView.h"

@class Homework;

@protocol CreateHomeworkViewDelegate;

@interface CreateHomeworkView : UIView <SubjectsViewDelegate, CreateHomeworkWorkSetViewDelegate, CreateHomeworkDueDateViewDelegate>

+ (CreateHomeworkView *)createHomeworkView;

- (void)reset;

@property (weak, nonatomic) id<CreateHomeworkViewDelegate> delegate;
@property (strong, nonatomic) Homework *homework;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *backgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) SubjectsView *subjectsView;
@property (weak, nonatomic) IBOutlet CreateHomeworkWorkSetView *workSetView;
@property (weak, nonatomic) IBOutlet CreateHomeworkDueDateView *dueDateView;

@end

@protocol CreateHomeworkViewDelegate <NSObject>

- (void)createHomeworkViewDidCancel:(CreateHomeworkView *)createHomeworkView;
- (void)createHomeworkViewDidCreate:(CreateHomeworkView *)createHomeworkView;

@end
