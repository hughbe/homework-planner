//
//  TodayViewController.m
//  today
//
//  Created by Hugh Bellamy on 21/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "TodayViewController.h"

@interface TodayViewController ()


@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(0, self.tableView.contentSize.height);
}

- (void)homeworkManagerDidUpdate:(HomeworkManager *)homeworkManager {
    self.homeworkToday = [homeworkManager homeworkForDate:[NSDate date]];
    [self.tableView reloadData];
    self.preferredContentSize = CGSizeMake(0, self.tableView.contentSize.height);
}

- (void)timetableManagerDidUpdate:(TimetableManager *)timetableManager {
    //self.lessonsToday = [self.timetableManager lessonsForDay:self.timetableManager.day];
    [self.tableView reloadData];
    self.preferredContentSize = CGSizeMake(0, self.tableView.contentSize.height);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(!section) {
        return self.homeworkToday.count;
    }
    else {
        return self.lessonsToday.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(!section) {
        return @"Homework";
    }
    else {
        return @"Timetable";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!indexPath.section) {
        HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Homework" forIndexPath:indexPath];
        Homework *homework = self.homeworkToday[indexPath.row];
        cell.subjectLabel.text = homework.subject.subjectName;
        cell.timeLabel.text = homework.subject.teacher;
        return cell;
    }
    else {
        LessonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Timetable" forIndexPath:indexPath];
        Lesson *lesson = self.lessonsToday[indexPath.row];
        cell.subjectLabel.text = lesson.subject.subjectName;
        cell.teacherLabel.text = lesson.subject.teacher;

        return cell;
    }
}

- (NSArray *)homeworkToday {
    if(!_homeworkToday) {
        _homeworkToday = [NSArray array];
    }
    return _homeworkToday;
}

- (NSArray *)lessonsToday {
    if(!_lessonsToday) {
        _lessonsToday = [NSArray array];
    }
    return _lessonsToday;
}

- (HomeworkManager *)homeworkManager {
    if(!_homeworkManager) {
        _homeworkManager = [[HomeworkManager alloc]initWithDelegate:self];
    }
    return _homeworkManager;
}

- (TimetableManager *)timetableManager {
    if(!_timetableManager) {
        _timetableManager = [[TimetableManager alloc]initWithDelegate:self];
    }
    return _timetableManager;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    self.timetableManager.day = [Day dayWithDate:[NSDate date]];
    [self.homeworkManager reload];
    [self.timetableManager reload];
    completionHandler(NCUpdateResultNoData);
}

@end
