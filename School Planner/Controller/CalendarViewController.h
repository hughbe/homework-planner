//
//  CalendarViewController.h
//  School Planner
//
//  Created by Hugh Bellamy on 21/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface CalendarViewController : UIViewController<JTCalendarDataSource, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;

@property (strong, nonatomic) JTCalendar *calendar;

@end
