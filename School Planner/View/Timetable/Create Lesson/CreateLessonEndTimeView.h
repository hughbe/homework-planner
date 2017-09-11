//
//  CreateLessonTimeView.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimePickerView.h"

@protocol CreateLessonEndTimeViewDelegate;

@interface CreateLessonEndTimeView : UIView

- (void)reset;

@property (weak, nonatomic) id<CreateLessonEndTimeViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet TimePickerView *timePicker;

@end

@protocol CreateLessonEndTimeViewDelegate <NSObject>

- (void)createLessonEndTimeViewDueDateViewDidGoBack:(CreateLessonEndTimeView *)createLessonEndTimeView;
- (void)createLessonEndTimeViewDueDateViewDidCreate:(CreateLessonEndTimeView *)createLessonEndTimeView;

@end
