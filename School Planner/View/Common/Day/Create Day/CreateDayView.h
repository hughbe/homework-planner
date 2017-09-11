//
//  CreateDayView.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Day;

@protocol CreateDayViewDelegate;

@interface CreateDayView : UIView

- (void)reset;

@property (weak, nonatomic) id<CreateDayViewDelegate> delegate;

@property (strong, nonatomic) Day *day;

@property (weak, nonatomic) IBOutlet UIButton *dayButton;
@property (weak, nonatomic) IBOutlet UIButton *weekButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end

@protocol CreateDayViewDelegate <NSObject>

- (void)createDayViewDidCancel:(CreateDayView *)createDayView;
- (void)createDayViewDidCreate:(CreateDayView *)createDayView;

@end
