//
//  TimetableManager.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Lesson;
@class Day;

@protocol TimetableManagerDelegate;

@interface TimetableManager : NSObject

- (instancetype)initWithDelegate:(id<TimetableManagerDelegate>)delegate;
@property (weak, nonatomic) id<TimetableManagerDelegate> delegate;

- (void)reload;
- (void)save;

- (void)createLesson:(Lesson *)lesson;
- (void)deleteLesson:(Lesson *)lesson;

@property (strong, nonatomic) Day *day;

@property (strong, nonatomic) NSMutableDictionary *sectionedLessonsByDay;

- (NSArray *)lessonsForDate:(NSDate *)date;
- (Lesson *)finalLesson;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (NSInteger)numberOfRowsForDay:(Day *)day;

@end

@protocol TimetableManagerDelegate <NSObject>

- (void)timetableManagerDidUpdate:(TimetableManager *)timetableManager;

@end
