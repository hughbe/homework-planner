//
//  DayManager.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "DaysManager.h"

#import "Day.h"
#import "IDGenerator.h"

#define DAYS_KEY @"days"
#define DAYS_LOADED_KEY @"days_loaded"
#define DAYS_START_WEEK @"days_start_week"

@implementation DaysManager

- (instancetype)init {
    self = [super init];
    if(self) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        BOOL daysLoaded = [standardUserDefaults boolForKey:DAYS_LOADED_KEY];
        if(!daysLoaded) {
            for (NSInteger day = 1; day <= 5; day++) {
                Day *dayObject = [[Day alloc]init];
                dayObject.day = day;
                dayObject.week = 1;
                self.allDays = [self.allDays arrayByAddingObject:dayObject];
            }
            [standardUserDefaults setBool:YES forKey:DAYS_LOADED_KEY];
            [standardUserDefaults synchronize];
            [self save];
        }
        [self reload];
    }
    return self;
}

- (void)reload {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSData *daysData = [standardDefaults objectForKey:DAYS_KEY];
    if(daysData) {
        self.allDays = [NSKeyedUnarchiver unarchiveObjectWithData:daysData];
        [self order];
    }
}

- (void)save {
    NSData *daysData = [NSKeyedArchiver archivedDataWithRootObject:self.allDays];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:daysData forKey:DAYS_KEY];
    [standardDefaults synchronize];
}

- (void)createDay:(Day *)day {
    if(![self.allDays containsObject:day]) {
        day.ID = [IDGenerator newDayID];
        self.allDays = [self.allDays arrayByAddingObject:day];
    }
    [self order];
    [self save];
}

- (void)deleteDay:(Day *)day {
    if(![self.allDays containsObject:day]) {
        return;
    }
    
    NSMutableArray *mutableDays = [self.allDays mutableCopy];
    [mutableDays removeObject:day];
    self.allDays = [mutableDays copy];
    [self save];
}

- (void)order {
    self.allDays = [self.allDays sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Day *day1 = obj1;
        Day *day2 = obj2;
        
        if(day1.week < day2.week) {
            return NSOrderedAscending;
        }
        else if(day1.week == day2.week) {
            if(day1.day < day2.day) {
                return NSOrderedAscending;
            }
            else if(day1.day == day2.day) {
                return NSOrderedSame;
            }
            else {
                return NSOrderedDescending;
            }
        }
        else {
            return NSOrderedDescending;
        }
    }];
}

- (NSArray *)allDays {
    if(!_allDays) {
        _allDays = [NSArray array];
    }
    return _allDays;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.allDays[idx];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    NSMutableArray *mutableDays = [self.allDays mutableCopy];
    mutableDays[idx] = obj;
    self.allDays = [mutableDays copy];
}

- (NSInteger)count {
    return self.allDays.count;
}

+ (NSInteger)currentWeek {
    NSDateComponents *weeksStartDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:[DaysManager weeksStartDate] toDate:[NSDate date] options:0];
    NSInteger startWeek = [weeksStartDateComponents weekOfYear];
    NSInteger limitedWeek = 0;
    if(startWeek % 2 == 0 || ![DaysManager isTwoWeekTimetable]) {
        limitedWeek = 1;
    }
    else {
        limitedWeek = 2;
    }
    return limitedWeek;
}

+ (BOOL)isTwoWeekTimetable {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSData *daysData = [standardDefaults objectForKey:DAYS_KEY];
    if(daysData) {
        NSArray *allDays = [NSKeyedUnarchiver unarchiveObjectWithData:daysData];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"week == 2"];
        NSArray *filteredDays = [allDays filteredArrayUsingPredicate:predicate];
        return filteredDays.count != 0;
    }
    return NO;
}

+ (NSDate *)weeksStartDate {
    NSDate *date = [[NSUserDefaults standardUserDefaults]objectForKey:DAYS_START_WEEK];
    if(!date) {
        date = [NSDate date];
        [DaysManager setWeeksStartDate:date];
    }
    return date;
}

+ (void)setWeeksStartDate:(NSDate *)weeksStartDate {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:weeksStartDate forKey:DAYS_START_WEEK];
    [standardDefaults synchronize];
    
}
@end
