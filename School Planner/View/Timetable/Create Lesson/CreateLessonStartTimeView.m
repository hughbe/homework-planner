//
//  CreateLessonTimeView.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateLessonStartTimeView.h"

@implementation CreateLessonStartTimeView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.mainView.layer.cornerRadius = 2.5;
    self.mainView.center = self.center;
    
    [self.timePicker setup];
    [self reset];
}

- (void)reset {
    self.timePicker.time = [NSDate date];
}

- (IBAction)back:(id)sender {
    [self.delegate createLessonStartTimeViewDueDateViewDidGoBack:self];
}

- (IBAction)forward:(id)sender {
    [self.delegate createLessonStartTimeViewDueDateViewDidGoForward:self];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.mainView.center = self.center;
    self.timePicker.frame = self.mainView.bounds;
}

@end
