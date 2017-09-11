//
//  TimetableViewController.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimetableManager.h"
#import "CreateLessonView.h"

@class Lesson;

@interface TimetableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TimetableManagerDelegate, CreateLessonViewDelegate>

@property (strong, nonatomic) TimetableManager *timetableManager;

@property (strong, nonatomic) CreateLessonView *createLessonView;

@property (weak, nonatomic) IBOutlet UIImageView *noLessonsView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@end
