//
//  CreateLessonTimeView.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimePickerView.h"

@protocol CreateLessonStartTimeViewDelegate;

@interface CreateLessonStartTimeView : UIView

- (void)reset;

@property (weak, nonatomic) id<CreateLessonStartTimeViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet TimePickerView *timePicker;

@end

@protocol CreateLessonStartTimeViewDelegate <NSObject>

- (void)createLessonStartTimeViewDueDateViewDidGoBack:(CreateLessonStartTimeView *)createLessonStartTimeView;
- (void)createLessonStartTimeViewDueDateViewDidGoForward:(CreateLessonStartTimeView *)createLessonStartTimeView;

@end
