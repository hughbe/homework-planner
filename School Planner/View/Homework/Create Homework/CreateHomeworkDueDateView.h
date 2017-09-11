//
//  CreateHomeworkDueDateView.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

@import UIKit;

#import "DayDatePickerView.h"

@protocol CreateHomeworkDueDateViewDelegate;

@interface CreateHomeworkDueDateView : UIView <DayDatePickerViewDelegate>

- (void)reset;

@property (weak, nonatomic) id<CreateHomeworkDueDateViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet DayDatePickerView *dueDatePicker;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end

@protocol CreateHomeworkDueDateViewDelegate <NSObject>

- (void)createHomeworkDueDateViewDidGoBack:(CreateHomeworkDueDateView *)createHomeworkDueDateView;
- (void)createHomeworkDueDateViewDidCreate:(CreateHomeworkDueDateView *)createHomeworkDueDateView;

@end
