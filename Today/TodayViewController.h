//
//  TodayViewController.h
//  today
//
//  Created by Hugh Bellamy on 21/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Homework.h"
#import "Day.h"
#import "Lesson.h"
#import "Subject.h"
#import "TimetableManager.h"
#import "HomeworkManager.h"
#import "HomeworkTableViewCell.h"
#import "LessonTableViewCell.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController : UIViewController <NCWidgetProviding, HomeworkManagerDelegate, TimetableManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) HomeworkManager *homeworkManager;
@property  (strong, nonatomic) TimetableManager *timetableManager;

@property (strong, nonatomic) NSArray *homeworkToday;
@property (strong, nonatomic) NSArray *lessonsToday;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
