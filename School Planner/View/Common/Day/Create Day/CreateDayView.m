//
//  CreateDayView.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateDayView.h"

#import "UIView+Borders.h"

#import "Day.h"

@implementation CreateDayView

@synthesize day = _day;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.cancelButton.layer.cornerRadius = 0;
    self.createButton.layer.cornerRadius = 0;
    
    UIColor *buttonBorderColour = [UIColor colorWithWhite:0.8 alpha:1.0];
    CGFloat buttonBorderWidth = 1.75;
    [self.cancelButton addTopBorderWithHeight:buttonBorderWidth andColor:buttonBorderColour];
    [self.createButton addTopBorderWithHeight:buttonBorderWidth andColor:buttonBorderColour];
    
    self.layer.cornerRadius = 2.5;
    [self reset];
}

- (void)reset {
    self.day = nil;
    [self.dayButton setTitle:@"Select Day" forState:UIControlStateNormal];
    self.day.week = 1;
    [self.weekButton setTitle:[self.day weekString] forState:UIControlStateNormal];
    self.hidden = YES;
}

- (void)verify {
    self.createButton.enabled = self.day.day != 0 && self.day.week != 0;
}

- (void)addDayItem:(NSString *)day withDayNumber:(NSInteger)dayNumber toAlertController:(UIAlertController *)alertController {
    UIAlertAction *dayAction = [UIAlertAction actionWithTitle:day style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        self.day.day = dayNumber;
        [self.dayButton setTitle:day forState:UIControlStateNormal];
    }];
    [alertController addAction:dayAction];
}

- (IBAction)selectDay:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Day" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [self addDayItem:@"Monday" withDayNumber:1 toAlertController:actionSheet];
    [self addDayItem:@"Tuesday" withDayNumber:2 toAlertController:actionSheet];
    [self addDayItem:@"Wednesday" withDayNumber:3 toAlertController:actionSheet];
    [self addDayItem:@"Thursday" withDayNumber:4 toAlertController:actionSheet];
    [self addDayItem:@"Friday" withDayNumber:5 toAlertController:actionSheet];
    [self addDayItem:@"Saturday" withDayNumber:6 toAlertController:actionSheet];
    [self addDayItem:@"Sunday" withDayNumber:7 toAlertController:actionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [actionSheet addAction:cancel];
    
    [self.window.rootViewController presentViewController:actionSheet animated:YES completion:nil];
}

- (void)addWeekItem:(NSString *)week withWeekNumber:(NSInteger)weekNumber toAlertController:(UIAlertController *)alertController {
    UIAlertAction *weekAction = [UIAlertAction actionWithTitle:week style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        self.day.week = weekNumber;
        [self.weekButton setTitle:[self.day weekString] forState:UIControlStateNormal];
    }];
    [alertController addAction:weekAction];
}

- (IBAction)selectWeek:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Week" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [self addWeekItem:@"Week 1" withWeekNumber:1 toAlertController:alert];
    [self addWeekItem:@"Week 2" withWeekNumber:2 toAlertController:alert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)cancelCreation:(id)sender {
    [self.delegate createDayViewDidCancel:self];
}

- (IBAction)completeCreation:(id)sender {
    [self.delegate createDayViewDidCreate:self];
}

- (Day *)day {
    if(!_day) {
        _day = [[Day alloc]init];
    }
    return _day;
}

- (void)setDay:(Day *)day {
    _day = day;
    if(!day) {
        return;
    }
    [self.dayButton setTitle:[self.day dayString] forState:UIControlStateNormal];
    [self.weekButton setTitle:[self.day weekString] forState:UIControlStateNormal];
    [self verify];
}

@end