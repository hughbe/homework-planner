//
//  HomeworkTableViewCell.m
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "HomeworkTableViewCell.h"

@implementation HomeworkTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(CGFloat) (0 / 255.0) green:(CGFloat) (153 / 255.0) blue:(CGFloat) (102 / 255.0) alpha:1];
    [self setSelectedBackgroundView:bgColorView];
}

- (UIColor *)timeLabelNormalColor {
    return [UIColor colorWithWhite:0.6 alpha:1.0];
}

- (UIColor *)timeLabelTodayColor {
    return [UIColor orangeColor];
}

- (UIColor *)timeLabelOverdueColor {
    return [UIColor redColor];
}

@end
