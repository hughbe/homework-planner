//
//  DaysView.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "DaysView.h"

#import "Day.h"
#import "DaysManager.h"
#import "HomeworkTableViewCell.h"

@implementation DaysView

+ (DaysView *)daysView {
    return [[[NSBundle mainBundle]loadNibNamed:@"DaysView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DayTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.viewType = DaysViewTypeModal;
    
    self.createDayView.delegate = self;
    self.tableView.layer.cornerRadius = 2.5;
    [self reset];

}

- (void)reset {
    self.tableView.contentOffset = CGPointMake(0, 26);
    self.selectedDay = nil;
    [self.createDayView reset];
    [self.tableView reloadData];
}

- (DaysManager *)daysManager {
    if(!_daysManager) {
        _daysManager = [[DaysManager alloc]init];
    }
    return _daysManager;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.daysManager.count ? NSLocalizedString(@"Days", nil) : NSLocalizedString(@"No Days", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.daysManager.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Day *day = self.daysManager[indexPath.row];
    cell.subjectLabel.text = [day dayString];
    cell.timeLabel.text = [day weekString];
    
    if([day isEqual:self.selectedDay]) {
        cell.subjectLabel.textColor = [UIColor whiteColor];
        cell.timeLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:(CGFloat) (0 / 255.0) green:(CGFloat) (153 / 255.0) blue:(CGFloat) (102 / 255.0) alpha:1];
    }
    else {
        cell.subjectLabel.textColor = [UIColor blackColor];
        cell.timeLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self.daysManager deleteDay:self.daysManager[indexPath.row]];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.viewType == DaysViewTypeSelection) {
        self.selectedDay = self.daysManager[indexPath.row];
        [self.delegate daysView:self didSelectDay:self.daysManager[indexPath.row]];
        [self.tableView reloadData];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.tableView.center = CGPointMake((CGFloat) (self.frame.size.width * 0.5), (CGFloat) (self.frame.size.height * 0.5 + 15));
    self.createDayView.center = CGPointMake((CGFloat) (self.frame.size.width * 1.5), (CGFloat) (self.frame.size.height * 0.5));
}

- (IBAction)createDay:(id)sender {
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.createDayView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.tableView.frame;
        frame.origin.y = self.frame.size.height;
        self.tableView.frame = frame;
    }];
    [UIView animateWithDuration:0.35 animations:^{
        self.createDayView.center = CGPointMake((CGFloat) (self.frame.size.width * 0.5), (CGFloat) (self.frame.size.height * 0.5));
    }];
}

- (void)createDayViewDidCancel:(CreateDayView *)createDayView {
    [self endEditing:YES];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createDay:)] animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.createDayView.center = CGPointMake((CGFloat) (self.frame.size.width * 1.5), self.frame.size.height / 2);
    } completion:^(BOOL finished) {
        [self.createDayView reset];
        self.createDayView.hidden = YES;
    }];
    [UIView animateWithDuration:0.35 animations:^{
        self.tableView.center = CGPointMake((CGFloat) (self.frame.size.width * 0.5), self.frame.size.height / 2);
    }];
}

- (void)createDayViewDidCreate:(CreateDayView *)createDayView {
    [self.daysManager createDay:createDayView.day];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self createDayViewDidCancel:createDayView];
}

- (void)setViewType:(DaysViewType)viewType {
    _viewType = viewType;
    if(_viewType == DaysViewTypeSelection) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    else if(_viewType == DaysViewTypeModal) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setSelectedDay:(Day *)selectedDay {
    _selectedDay = selectedDay;
    NSUInteger index = [self.daysManager.allDays indexOfObject:selectedDay];
    if(index < UINT_MAX) {
        if(index < self.tableView.visibleCells.count) {
            [self.tableView reloadData];
        }
        else {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
}

- (IBAction)cancel:(id)sender {
    [self.delegate daysViewDidCancel:self];
}

@end
