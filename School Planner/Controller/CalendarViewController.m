//
//  CalendarViewController.m
//  School Planner
//
//  Created by Hugh Bellamy on 21/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CalendarViewController.h"

#import "Lesson.h"
#import "Subject.h"
#import "Homework.h"
#import "HomeworkManager.h"
#import "HomeworkTableViewCell.h"
#import "LessonTableViewCell.h"
#import "TimetableManager.h"
#import "QuickHomeworkView.h"

@interface CalendarViewController () <HomeworkManagerDelegate, TimetableManagerDelegate, QuickHomeworkViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) HomeworkManager *homeworkManager;
@property  (strong, nonatomic) TimetableManager *timetableManager;

@property (weak, nonatomic) IBOutlet UITableView *dayTableView;

@property (strong, nonatomic) NSDate *viewingDate;

@property (assign, nonatomic) NSInteger homeworkSection;
@property (assign, nonatomic) NSInteger timetableSection;

@property (strong, nonatomic) QuickHomeworkView *quickHomeworkView;
@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.quickHomeworkView = [QuickHomeworkView quickHomeworkView];
    self.quickHomeworkView.frame = self.tabBarController.view.bounds;
    self.quickHomeworkView.alpha = 0.0;
    self.quickHomeworkView.delegate = self;
    [self.tabBarController.view addSubview:self.quickHomeworkView];
    
    [self.dayTableView registerNib:[UINib nibWithNibName:@"HomeworkTableViewCell" bundle:nil] forCellReuseIdentifier:@"Homework"];
    [self.dayTableView registerNib:[UINib nibWithNibName:@"LessonTableViewCell" bundle:nil] forCellReuseIdentifier:@"Lesson"];
    
    [self.timetableManager reload];
    [self.homeworkManager reload];
    
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    navBarFrame.size.height = 10;
    self.navigationController.navigationBar.frame = navBarFrame;
    
    CGRect calendarTopFrame = self.calendarMenuView.frame;
    calendarTopFrame.size.width = self.view.frame.size.width;
    calendarTopFrame.size.height = 25;
    calendarTopFrame.origin.x = 0;
    calendarTopFrame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.calendarMenuView.frame = calendarTopFrame;
    
    CGRect calendarContentFrame = self.calendarContentView.frame;
    calendarContentFrame.origin.y = calendarTopFrame.origin.y + calendarTopFrame.size.height;
    calendarContentFrame.size.height = self.view.frame.size.height - calendarContentFrame.origin.y;
    self.calendarContentView.frame = calendarContentFrame;
    
    self.calendar = [JTCalendar new];
    [self.calendar setCurrentDate:[NSDate date]];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = (CGFloat) (9. / 10.);
        self.calendar.calendarAppearance.ratioContentMenu = (CGFloat) 2.;
        self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
        
        // Customize the text for each month
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%@", monthText];
        };
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.timetableManager reload];
    [self.homeworkManager reload];
}

- (void)timetableManagerDidUpdate:(TimetableManager *)timetableManager {
    [self.calendar reloadData];
    [self.calendar reloadAppearance];
}

- (void)homeworkManagerDidUpdate:(HomeworkManager *)homeworkManager {
    [self.calendar reloadData];
    [self.calendar reloadAppearance];
}
#pragma mark - Transition examples

- (void)transitionExample {
    CGFloat weekHeight = 75;
    if(self.calendarContentView.frame.size.height == weekHeight) {
        [UIView transitionWithView:self.dayTableView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.dayTableView reloadData];
        } completion:nil];
    }
    else {
        [UIView animateWithDuration:.25 animations:^{
            self.calendarContentView.layer.opacity = 0;
        } completion:^(BOOL finished) {
            CGRect frame = self.calendarContentView.frame;
            frame.size.height = 75;
            self.calendarContentView.frame = frame;
            
            CGRect frame2 = self.dayTableView.frame;
            frame2.origin.y = frame.origin.y + frame.size.height;
            frame2.size.width = self.view.frame.size.width;
            frame2.size.height = self.view.frame.size.height - frame2.origin.y;
            self.dayTableView.frame = frame2;
            
            [self.calendar reloadAppearance];
            [self.dayTableView reloadData];
                         
            [UIView animateWithDuration:.25 animations:^{
                self.calendarContentView.layer.opacity = 1;
            }];
        }];
    }
}

- (TimetableManager *)timetableManager {
    if(!_timetableManager) {
        _timetableManager = [[TimetableManager alloc]initWithDelegate:self];
    }
    return _timetableManager;
}

- (HomeworkManager *)homeworkManager {
    if(!_homeworkManager) {
        _homeworkManager = [[HomeworkManager alloc]initWithDelegate:self];
    }
    return _homeworkManager;
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(UIView<JTCalendarDay> *)dayView {
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    self.viewingDate = date;
    [self transitionExample];
}

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date {
    NSArray *lessons = [self.timetableManager lessonsForDate:date];
    NSArray *homework = [self.homeworkManager homeworkForDate:date];
    return homework.count || lessons.count;
}

- (UIColor *)dotColorForEvent:(JTCalendar *)calendar date:(NSDate *)date {
    NSArray *homework = [self.homeworkManager homeworkForDate:date];
    return homework.count ? [UIColor redColor] : nil;
}

- (NSArray *)homeworkArray {
    return [self.homeworkManager homeworkForDate:self.viewingDate];
}

- (NSArray *)lessonsArray {
    return [self.timetableManager lessonsForDate:self.viewingDate];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(!self.viewingDate) {
        return 0;
    }
    NSArray *lessons = [self lessonsArray];
    NSArray *homework = [self homeworkArray];
    self.homeworkSection = -1;
    self.timetableSection = -1;
    if(lessons.count && homework.count) {
        self.homeworkSection = 0;
        self.timetableSection = 0;
        return 2;
    }
    else if(lessons.count) {
        self.timetableSection = 0;
        return 1;
    }
    else if(homework.count) {
        self.homeworkSection = 0;
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == self.homeworkSection) {
        return [self homeworkArray].count;
    }
    else {
        return [self lessonsArray].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == self.homeworkSection) {
        HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Homework" forIndexPath:indexPath];
        Homework *homework = [self homeworkArray][indexPath.row];
        
        cell.subjectLabel.text = homework.subject.subjectName;
        cell.timeLabel.text = homework.summary;
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    }
    else {
        LessonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Lesson" forIndexPath:indexPath];
        Lesson *lesson = [self lessonsArray][indexPath.row];
        
        cell.subjectLabel.text = lesson.subject.subjectName;
        cell.teacherLabel.text = lesson.subject.teacher;
        
        [cell setStartTime:lesson.startTime endTime:lesson.endTime];
        cell.subjectIndicatorView.backgroundColor = lesson.subject.color;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == self.homeworkSection) {
        self.quickHomeworkView.homework = [self homeworkArray][indexPath.row];
        [UIView animateWithDuration:0.15 animations:^{
            self.quickHomeworkView.alpha = 1.0;
        }];
    }
}

- (void)quickHomeworkViewDidClose:(QuickHomeworkView *)quickHomeworkView {
    [UIView animateWithDuration: 0.15 animations:^{
        self.quickHomeworkView.alpha = 0.0;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == self.homeworkSection) {
        return 60;
    }
    else {
        return 80;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == self.homeworkSection) {
        return @"Homework";
    }
    else {
        return @"Lessons";
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}
@end
