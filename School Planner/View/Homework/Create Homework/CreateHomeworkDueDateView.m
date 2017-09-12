//
//  CreateHomeworkDueDateView.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateHomeworkDueDateView.h"

#import "UIColor+Additions.h"

@implementation CreateHomeworkDueDateView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.mainView.layer.cornerRadius = 2.5;
    self.dueDatePicker.delegate = self;
    [self.dueDatePicker setup];
    [self reset];
}

- (UIFont *)dayDatePickerView:(DayDatePickerView *)dayDatePickerView fontForRow:(NSInteger)row inColumn:(DayDatePickerViewColumnType)columnType disabled:(BOOL)disabled {
    UIFont *font;
    if(columnType == DayDatePickerViewColumnTypeDay) {
        font = [UIFont systemFontOfSize:20.0];
    }
    else if(columnType == DayDatePickerViewColumnTypeMonth) {
        font = [UIFont systemFontOfSize:18.0];
    }
    else if(columnType == DayDatePickerViewColumnTypeYear) {
        font = [UIFont systemFontOfSize:16.0];
    }
    return font;
}

- (UIColor *)selectionViewBackgroundColorForDayDatePickerView:(DayDatePickerView *)dayDatePickerView {
    return [[UIColor colorWithRed:(CGFloat) (0 / 255.0) green:(CGFloat) (153 / 255.0) blue:(CGFloat) (102 / 255.0) alpha:1.0] add_darkerColorWithValue: 0.4];
}

- (CGFloat)selectionViewOpacityForDayDatePickerView:(DayDatePickerView *)dayDatePickerView {
    return 0.5;
}

- (void)reset {
    self.dueDatePicker.date = [NSDate date];
    self.dueDatePicker.minimumDate = [NSDate date];
}

- (IBAction)back:(id)sender {
    [self.delegate createHomeworkDueDateViewDidGoBack:self];
}

- (IBAction)create:(id)sender {
    [self.delegate createHomeworkDueDateViewDidCreate:self];
}
@end
