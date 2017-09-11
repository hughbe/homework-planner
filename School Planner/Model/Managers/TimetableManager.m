//
//  TimetableManager.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "TimetableManager.h"

#import "Day.h"
#import "Lesson.h"
#import "IDGenerator.h"
#import "Subject.h"
#import "SubjectsManager.h"

#define LESSONS_KEY @"lessons"

@interface TimetableManager ()

@property (strong, nonatomic) NSArray *allLessons;

@end

@implementation TimetableManager

@synthesize allLessons = _allLessons;

- (instancetype)initWithDelegate:(id<TimetableManagerDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)reload {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSData *lessonsData = [standardDefaults objectForKey:LESSONS_KEY];
    if(lessonsData) {
        SubjectsManager *subjectsManager = [[SubjectsManager alloc]init];
        [subjectsManager reload];
        NSArray *lessons = [NSKeyedUnarchiver unarchiveObjectWithData:lessonsData];
        for(Lesson *aLesson in lessons) {
            Subject *subject = [subjectsManager subjectForID:aLesson.subject.ID];
            if(subject && subject.ID.length && subject.subjectName.length) {
                aLesson.subject = subject;
            }
        }
        self.allLessons = lessons;
    }
}

- (void)save {
    NSData *lessonsData = [NSKeyedArchiver archivedDataWithRootObject:self.allLessons];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:lessonsData forKey:LESSONS_KEY];
    [standardDefaults synchronize];
}

- (void)createLesson:(Lesson *)lesson {
    if([self.allLessons containsObject:lesson]) {
        NSInteger index = [self.allLessons indexOfObject:lesson];
        NSMutableArray *mutableHomework = [self.allLessons mutableCopy];
        mutableHomework[index] = lesson;
        self.allLessons = [mutableHomework copy];
    }
    else {
        lesson.ID = [IDGenerator newLessonID];
        lesson.creationDate = [NSDate date];
        self.allLessons = [self.allLessons arrayByAddingObject:lesson];
    }
    
    [self save];
}

- (void)deleteLesson:(Lesson *)lesson {
    if(![self.allLessons containsObject:lesson]) {
        return;
    }
    NSMutableArray *mutableLessons = [self.allLessons mutableCopy];
    [mutableLessons removeObject:lesson];
    _allLessons = [mutableLessons copy];
    [self reloadSections];
    [self save];
}

- (void)reloadSections {
    NSMutableDictionary *uniqueDays = [NSMutableDictionary dictionary];
    for (Lesson *lesson in self.allLessons) {
        NSMutableArray *dayLessons = uniqueDays[[lesson.day keyString]];
        if(!dayLessons) {
            dayLessons = [NSMutableArray array];
        }
        
        if(![dayLessons containsObject:lesson]) {
            [dayLessons addObject:lesson];
        }
        uniqueDays[[lesson.day keyString]] = dayLessons;
    }
    
    NSMutableDictionary *sortedUniqueDays = [NSMutableDictionary dictionary];
    [uniqueDays enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *lessons = obj;
        lessons = [lessons sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Lesson *lesson1 = obj1;
            Lesson *lesson2 = obj2;
            NSComparisonResult comparisonResult = [lesson1.startTime compare:lesson2.startTime];
            if(comparisonResult == NSOrderedSame) {
                return [lesson1.endTime compare:lesson2.endTime];
            }
            return comparisonResult;
        }];
        sortedUniqueDays[key] = lessons;
    }];
    self.sectionedLessonsByDay = sortedUniqueDays;
}

- (NSArray *)lessonsForDate:(NSDate *)date {
    Day *day = [Day dayWithDate:date];
    [self reloadSections];
    NSArray *lessons = self.sectionedLessonsByDay[[day keyString]];
    if(!lessons) {
        lessons = [NSArray array];
    }
    return lessons;
}

- (Lesson *)finalLesson {
    NSArray *lessonsForDay = self.sectionedLessonsByDay[[self.day keyString]];
    return [lessonsForDay lastObject];
}

- (NSInteger)numberOfRowsForDay:(Day *)day {
    NSArray *lessonsForDay = self.sectionedLessonsByDay[[day keyString]];
    return [lessonsForDay count];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    NSArray *lessonsForDay =self.sectionedLessonsByDay[[self.day keyString]];
    if(idx < lessonsForDay.count) {
        return lessonsForDay[idx];
    }
    return nil;
}

- (NSArray *)allLessons {
    if(!_allLessons) {
        _allLessons = [NSArray array];
    }
    return _allLessons;
}

- (void)setAllLessons:(NSArray *)allLessons {
    _allLessons = allLessons;
    [self reloadSections];
    [self.delegate timetableManagerDidUpdate:self];
}

- (NSMutableDictionary *)sectionedLessonsByDay {
    if(!_sectionedLessonsByDay) {
        _sectionedLessonsByDay = [NSMutableDictionary dictionary];
    }
    return _sectionedLessonsByDay;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.allLessons];
}

@end
