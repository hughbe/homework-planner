//
//  DayManager.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Day;

@interface DaysManager : NSObject

- (void)reload;
- (void)save;

- (void)createDay:(Day *)day;
- (void)deleteDay:(Day *)day;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (NSInteger)count;

@property (strong, nonatomic) NSArray *allDays;

+ (NSInteger)currentWeek;
+ (NSDate *)weeksStartDate;
+ (void)setWeeksStartDate:(NSDate *)weeksStartDate;
+ (BOOL)isTwoWeeked;
@end
