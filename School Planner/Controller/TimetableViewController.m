//
//  TimetableViewController.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "TimetableViewController.h"

#import "UINavigationBar+Addition.h"

#import "Day.h"
#import "Lesson.h"
#import "Subject.h"
#import "LessonTableViewCell.h"
#import "DaysManager.h"

@interface TimetableViewController ()

@property (strong, nonatomic) Day *day;
@property (strong, nonatomic) DaysManager *daysManagers;

@property (assign, nonatomic) UITableViewRowAnimation reloadAnimation;

@end

@implementation TimetableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LessonTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.createLessonView = [CreateLessonView createLessonView];
    self.createLessonView.delegate = self;
    
    self.reloadAnimation = UITableViewRowAnimationNone;
    NSDate *today = [NSDate date];
    self.day = [Day dayWithDate:today];
    
    [self.timetableManager reload];
    self.noLessonsView.center = self.view.center;
    [self.view bringSubviewToFront:self.noLessonsView];
    
    CGRect frame1 = self.tabBarController.view.bounds;
    frame1.origin.x = frame1.size.width;
    self.createLessonView.frame = frame1;
    [self.tabBarController.view addSubview:self.createLessonView];
    
    CGRect frame2 = self.toolbar.frame;
    frame2.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.toolbar.frame = frame2;
    self.toolbar.clipsToBounds = YES;
    [self.navigationController.view addSubview:self.toolbar];
    [self.navigationController.navigationBar hideBottomHairline];
    
    [self displayNoLessonsView:NO];
    
    [self.daysManagers reload];
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiped:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiped:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.tableView addGestureRecognizer:rightSwipeGestureRecognizer];
    [self.tableView addGestureRecognizer:leftSwipeGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.daysManagers reload];
    
    [self.createLessonView.subjectsView.subjectsManager reload];
    [self.createLessonView.subjectsView.tableView reloadData];
    
    [self.createLessonView.daysView.daysManager reload];
    [self.createLessonView.daysView.tableView reloadData];
}

- (void)swiped:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]init];
    if(swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        buttonItem.tag = -1;
    }
    else {
        buttonItem.tag = 1;
    }
    [self changeDate:buttonItem];
}

- (IBAction)createLesson:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect createLessonFrame = self.createLessonView.frame;
        createLessonFrame.origin.x = 0;
        self.createLessonView.frame = createLessonFrame;
        NSDate *latestTime = [self.timetableManager finalLesson].endTime;
        if(latestTime && !self.createLessonView.lesson.subject.subjectName.length) {
            self.createLessonView.timeStartView.timePicker.time = latestTime;
            
            NSDateComponents *components = [[NSDateComponents alloc]init];
            components.minute = 30;
            
            NSDate *nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:latestTime options:0];
            self.createLessonView.timeEndView.timePicker.time = nextDate;
        }
    }];
}

- (void)createLessonViewDidCancel:(CreateLessonView *)createLessonView {
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = self.createLessonView.frame;
        frame.origin.x = frame.size.width;
        self.createLessonView.frame = frame;
    } completion:^(BOOL finished) {
        [self.createLessonView reset];
    }];
    [self.daysManagers reload];
    [self.timetableManager reload];
    [self.tableView reloadData];
}

- (void)createLessonViewDidCreate:(CreateLessonView *)createLessonView {
    [self.timetableManager createLesson:createLessonView.lesson];
    [self createLessonViewDidCancel:createLessonView]; //Dismiss
}

- (void)displayNoLessonsView:(BOOL)animated {
    if([self.timetableManager numberOfRowsForDay:self.day]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.noLessonsView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.noLessonsView.alpha = 1.0;
            self.noLessonsView.hidden = YES;
        }];
        if(self.tableView.editing) {
            UIBarButtonItem *doneButtonItem  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)];
            doneButtonItem.tag = 1;
            self.editBarButtonItem.tag = 1;
            self.editBarButtonItem.title = @"Done";
        }
        else {
            self.editBarButtonItem.tag = 0;
            self.editBarButtonItem.title = @"Edit";
        }
    }
    else {
        if(self.noLessonsView.hidden) {
            self.noLessonsView.alpha = 0.0;
            self.noLessonsView.hidden = NO;
            [UIView animateWithDuration:0.2 animations:^{
                self.noLessonsView.alpha = 1.0;
            }];
        }
        self.editBarButtonItem.title = @"";
    }
}

- (IBAction)edit:(UIBarButtonItem *)sender {
    if(!sender.tag) {
        sender.tag = 1;
        sender.title = @"Done";
        
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        sender.tag = 0;
        sender.title = @"Edit";
        
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void)timetableManagerDidUpdate:(TimetableManager *)timetableManager {
    [self displayNoLessonsView:YES];
    [UIView transitionWithView: self.tableView duration: 0.35f options: UIViewAnimationOptionTransitionCrossDissolve animations: ^(void) {
        [self.tableView reloadData];
    } completion: nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.timetableManager numberOfRowsForDay:self.day];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LessonTableViewCell *cell = (LessonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Lesson *lesson = self.timetableManager[indexPath.row];
    cell.subjectLabel.text = lesson.subject.subjectName;
    cell.teacherLabel.text = lesson.subject.teacher;
    
    [cell setStartTime:lesson.startTime endTime:lesson.endTime];
    cell.subjectIndicatorView.backgroundColor = lesson.subject.color;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        Lesson *lesson = self.timetableManager[indexPath.row];
        [self.timetableManager deleteLesson:lesson];
        [tableView endUpdates];
        [self displayNoLessonsView:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Lesson *lesson = self.timetableManager[indexPath.row];
    if(tableView.editing) {
        [tableView setEditing:NO animated:YES];
        self.editBarButtonItem.title = @"Edit";
        self.editBarButtonItem.tag = 0;
        self.createLessonView.lesson = [lesson copy];
        [self createLesson:nil];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 8, 0, 0);
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:insets];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:insets];
    }
}

- (TimetableManager *)timetableManager {
    if(!_timetableManager) {
        _timetableManager = [[TimetableManager alloc]initWithDelegate:self];
    }
    return _timetableManager;
}

- (IBAction)changeDate:(UIBarButtonItem *)sender {
    if(!sender.tag) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *goToToday = [UIAlertAction actionWithTitle:@"Go To Today" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            self.day = [Day dayWithDate:[NSDate date]];
        }];
        
        [actionSheet addAction:goToToday];
        
        if ([DaysManager isTwoWeeked]) {
            UIAlertAction *selectWeek = [UIAlertAction actionWithTitle:@"Set Week" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                
                UIAlertController *selectWeekActionSheet = [UIAlertController alertControllerWithTitle:@"Select Current Week" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction *week1 = [UIAlertAction actionWithTitle:@"Week 1" style:UIAlertActionStyleDefault handler:^(UIAlertAction* currentAction) {
                    self.day.week = 1;
                    [DaysManager setWeeksStartDate:[NSDate date]];
                }];
                UIAlertAction *week2 = [UIAlertAction actionWithTitle:@"Week 2" style:UIAlertActionStyleDefault handler:^(UIAlertAction* currentAction) {
                    self.day.week = 2;
                    
                    NSDateComponents *components = [[NSDateComponents alloc]init];
                    components.weekOfYear = -1;
                    
                    NSDate *nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
                    [DaysManager setWeeksStartDate:nextDate];
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                
                [selectWeekActionSheet addAction:week1];
                [selectWeekActionSheet addAction:week2];
                [selectWeekActionSheet addAction:cancel];
                
                [self presentViewController:selectWeekActionSheet animated:YES completion:nil];
            }];
            
            [actionSheet addAction:selectWeek];
        }
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [actionSheet addAction:cancel];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        NSInteger index = [self.daysManagers.allDays indexOfObject:self.day];
        Day *day;
        if(sender.tag > 0) {
            self.reloadAnimation = UITableViewRowAnimationLeft;
        }
        else {
            self.reloadAnimation = UITableViewRowAnimationRight;
        }
        if(index < INT_MAX) {
            index += sender.tag;
            if(index < 0) {
                index = self.daysManagers.count - 1;
            }
            else if(index > self.daysManagers.count -1 ) {
                index = 0;
            }
            day = self.daysManagers[index];
        }
        else {
            day = [[Day alloc]init];
            day.week = self.day.week;
            if(!day.week) {
                day.week = 1;
            }
            day.day = self.day.day + sender.tag;
            if(day.day > 7) {
                day.day = 1;
                if([DaysManager isTwoWeeked]) {
                    day.week++;
                    if(day.week > 2) {
                        day.week = 1;
                    }
                }
            }
            else if(day.day < 1) {
                day.day = 7;
                if([DaysManager isTwoWeeked]) {
                    day.week--;
                    if(day.week < 1) {
                        day.week = 2;
                    }
                }
            }
        }
        self.day = day;
    }
}

- (void)setDay:(Day *)day {
    [self.tableView setEditing:NO animated:YES];
    self.editBarButtonItem.title = @"Edit";
    self.editBarButtonItem.tag = 0;
    _day = day;
    self.timetableManager.day = day;
    
    if(self.reloadAnimation != UITableViewRowAnimationNone) {
        [self.tableView beginUpdates];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:self.reloadAnimation];
    if(self.reloadAnimation != UITableViewRowAnimationNone) {
        [self.tableView endUpdates];
    }
    
    self.reloadAnimation = UITableViewRowAnimationNone;
    
    [self displayNoLessonsView:YES];
    
    NSDateComponents *components = [[NSCalendar currentCalendar]components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    NSString *dayString;
    if(components.weekday - 1 == day.day && day.week == [DaysManager currentWeek]) {
        dayString = @"Today";
    }
    else if(components.weekday + 1 - day.day == 1 && day.week == [DaysManager currentWeek]) {
        dayString = @"Tomorrow";
    }
    else {
        dayString = [day dayString];
    }
    if([DaysManager isTwoWeeked]) {
        dayString = [dayString stringByAppendingFormat:@" - %@", day.weekString];
    }
    self.dayBarButtonItem.title = dayString;
}

- (DaysManager *)daysManagers {
    if(!_daysManagers) {
        _daysManagers = [[DaysManager alloc]init];
    }
    return _daysManagers;
}

@end
