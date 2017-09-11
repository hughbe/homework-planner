//
//  HomeworkTableViewCell.h
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Homework;

@interface HomeworkTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *accessoryImageView;

- (UIColor *)timeLabelNormalColor;
- (UIColor *)timeLabelTodayColor;
- (UIColor *)timeLabelOverdueColor;

@end
