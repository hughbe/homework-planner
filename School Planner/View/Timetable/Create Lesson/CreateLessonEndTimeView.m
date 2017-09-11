//
//  CreateLessonTimeView.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateLessonEndTimeView.h"

@implementation CreateLessonEndTimeView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.mainView.layer.cornerRadius = 2.5;
    self.mainView.center = self.center;
    
    [self.timePicker setup];
    
    [self reset];
}

- (void)reset {
    
}

- (IBAction)back:(id)sender {
    [self.delegate createLessonEndTimeViewDueDateViewDidGoBack:self];
}

- (IBAction)create:(id)sender {
    [self.delegate createLessonEndTimeViewDueDateViewDidCreate:self];
}


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.mainView.center = CGPointMake((CGFloat) (self.frame.size.width * 0.5), (CGFloat) (self.frame.size.height * 0.5));
    self.timePicker.frame = self.mainView.bounds;
}
@end
