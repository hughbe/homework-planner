//
//  LessonTableViewCell.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Lesson;

@interface LessonTableViewCell : UITableViewCell

- (void)setStartTime:(NSDate *)startTime endTime:(NSDate *)endTime;

@property (strong, nonatomic) IBOutlet UILabel *startTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *teacherLabel;

@property (weak, nonatomic) IBOutlet UIView *subjectIndicatorView;

@end
