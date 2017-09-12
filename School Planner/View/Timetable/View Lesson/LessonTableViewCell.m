//
//  LessonTableViewCell.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "LessonTableViewCell.h"

@interface LessonTableViewCell ()

@property (strong, nonatomic) NSDateFormatter *timeDateFormatter;

@end

@implementation LessonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(CGFloat) (0 / 255.0) green:(CGFloat) (153 / 255.0) blue:(CGFloat) (102 / 255.0) alpha:1];
    [self setSelectedBackgroundView:bgColorView];
    
    CGRect frame = self.startTimeLabel.frame;
    frame.origin.y = 8;
    frame.origin.x = self.contentView.frame.size.width - frame.size.width - 4;
    self.startTimeLabel.frame = frame;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setStartTime:(NSDate *)startTime endTime:(NSDate *)endTime {
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.timeDateFormatter stringFromDate:startTime], [self.timeDateFormatter stringFromDate:endTime]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if(self.editing) {
        [UIView animateWithDuration:0.2 animations:^{
            if(highlighted) {
                self.subjectLabel.textColor = [UIColor whiteColor];
                self.teacherLabel.textColor = [UIColor whiteColor];
                self.startTimeLabel.textColor = [UIColor whiteColor];
            }
            else {
                self.subjectLabel.textColor = [UIColor blackColor];
                self.teacherLabel.textColor = [UIColor lightGrayColor];
                self.startTimeLabel.textColor = [UIColor blackColor];
            }
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if(self.editing) {
        [UIView animateWithDuration:0.2 animations:^{
            if(selected) {
                self.subjectLabel.textColor = [UIColor whiteColor];
                self.teacherLabel.textColor = [UIColor whiteColor];
                self.startTimeLabel.textColor = [UIColor whiteColor];
            }
            else {
                self.subjectLabel.textColor = [UIColor blackColor];
                self.teacherLabel.textColor = [UIColor lightGrayColor];
                self.startTimeLabel.textColor = [UIColor blackColor];
            }
        }];
    }
}

- (NSDateFormatter *)timeDateFormatter {
    if(!_timeDateFormatter) {
        _timeDateFormatter = [[NSDateFormatter alloc]init];
        _timeDateFormatter.dateFormat = @"HH:mm";
    }
    return _timeDateFormatter;
}

@end
