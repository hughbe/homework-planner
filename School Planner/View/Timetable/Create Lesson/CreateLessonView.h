//
//  CreateLessonView.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SubjectsView.h"
#import "DaysView.h"
#import "CreateLessonStartTimeView.h"
#import "CreateLessonEndTimeView.h"

@class Lesson;

@protocol CreateLessonViewDelegate;

@interface CreateLessonView : UIView <SubjectsViewDelegate, DaysViewDelegate, CreateLessonStartTimeViewDelegate, CreateLessonEndTimeViewDelegate>

+ (CreateLessonView *)createLessonView;

- (void)reset;

@property (strong, nonatomic) Lesson *lesson;
@property (weak, nonatomic) id<CreateLessonViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *backgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) SubjectsView *subjectsView;
@property (strong, nonatomic) DaysView *daysView;

@property (weak, nonatomic) IBOutlet CreateLessonStartTimeView *timeStartView;
@property (weak, nonatomic) IBOutlet CreateLessonEndTimeView *timeEndView;

@end

@protocol CreateLessonViewDelegate <NSObject>

- (void)createLessonViewDidCancel:(CreateLessonView *)createLessonView;
- (void)createLessonViewDidCreate:(CreateLessonView *)createLessonView;

@end
