//
//  HomeworkManager.m
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "HomeworkManager.h"

#import "Homework.h"
#import "Subject.h"
#import "IDGenerator.h"
#import "Attachment.h"
#import "SubjectsManager.h"

#define HOMEWORKS_KEY @"homeworks"
#define ID_KEY @"homework_previous_id"

@interface HomeworkManager ()

@property (strong, nonatomic) NSArray *clearHomework;

@property (strong, nonatomic) NSPredicate *searchingPredicate;

@end

@implementation HomeworkManager

@synthesize allHomework = _allHomework;

- (instancetype)initWithDelegate:(id<HomeworkManagerDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)createHomework:(Homework *)homework {
    for (Attachment *attachment in homework.attachments) {
        if(!attachment.ID.length) {
            attachment.ID = [IDGenerator newAttachmentID];
        }
    }
    if([self.allHomework containsObject:homework]) {
        NSInteger index = [self.allHomework indexOfObject:homework];
        NSMutableArray *mutableHomework = [self.allHomework mutableCopy];
        mutableHomework[index] = homework;
        self.allHomework = [mutableHomework copy];
        [homework addNotification];
    }
    else {
        homework.ID = [IDGenerator newHomeworkID];
        [homework addNotification];
        homework.creationDate = [NSDate date];
        self.allHomework = [self.allHomework arrayByAddingObject:homework];
    }
    
    [self save];
}

- (void)deleteHomework:(Homework *)homework {
    if(![self.clearHomework containsObject:homework]) {
        return;
    }
    [homework removeNotification];
    NSMutableArray *mutableHomework = [self.clearHomework mutableCopy];
    [mutableHomework removeObject:homework];
    _clearHomework = [mutableHomework copy];
    [self searchWithPredicate:self.searchingPredicate informDelegate:NO];
    [self reloadSections];
    [self save];
}

- (void)reload {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSData *homeworkData = [standardDefaults objectForKey:HOMEWORKS_KEY];
    if(homeworkData) {
        SubjectsManager *subjectsManager = [[SubjectsManager alloc]init];
        [subjectsManager reload];
        NSArray *homework = [NSKeyedUnarchiver unarchiveObjectWithData:homeworkData];
        for(Homework *aHomework in homework) {
            Subject *subject = [subjectsManager subjectForID:aHomework.subject.ID];
            if(subject && subject.ID.length && subject.subjectName.length) {
                aHomework.subject = subject;
            }
        }
        self.allHomework = homework;
    }
}

- (void)searchWithPredicate:(NSPredicate *)predicate informDelegate:(BOOL)informDelegate {
    self.searchingPredicate = predicate;
    if(informDelegate) {
        if(predicate) {
            self.allHomework = [self.clearHomework filteredArrayUsingPredicate:predicate];
        }
        else {
            self.allHomework = [self.clearHomework copy];
        }
    }
    else {
        if(predicate) {
            _allHomework = [self.clearHomework filteredArrayUsingPredicate:predicate];
        }
        else {
            _allHomework = [self.clearHomework copy];
        }
    }
}

- (NSString *)titleForSection:(NSInteger)section {
    return [self orderedSubjectKeys][section];
}

- (NSInteger)numberOfSections {
    return [self sectionedHomeworkBySubject].allValues.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSString *subjectKey = [self orderedSubjectKeys][section];
    NSArray *homeworkForSubject = self.sectionedHomeworkBySubject[subjectKey];
    return [homeworkForSubject count];
}

- (NSArray *)orderedSubjectKeys {
    return [[[self sectionedHomeworkBySubject]allKeys]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (Homework *)homeworkForSection:(NSInteger)section row:(NSInteger)row {
    NSString *subjectKey = [self orderedSubjectKeys][section];
    NSArray *homeworksForSubject = [self sectionedHomeworkBySubject][subjectKey];
    return homeworksForSubject[row];
}

- (NSArray *)homeworkForDate:(NSDate *)date {
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [[NSCalendar currentCalendar]components:calendarUnit fromDate:date];
    
    NSMutableArray *homeworkForDate = [NSMutableArray array];
    for (Homework *homework in self.allHomework) {
        NSDateComponents *dueComponents = [[NSCalendar currentCalendar]components:calendarUnit fromDate:homework.dueDate];
        if(dueComponents.day == components.day && dueComponents.month == components.month && dueComponents.year == components.year) {
            [homeworkForDate addObject:homework];
        }
    }
    return [homeworkForDate copy];
}

- (NSArray *)allHomework {
    if(!_allHomework) {
        _allHomework = [NSArray array];
    }
    return _allHomework;
}

- (void)setAllHomework:(NSArray *)allHomework {
    _allHomework = allHomework;
    if(!self.searchingPredicate) {
        _clearHomework = allHomework;
    }
    [self reloadSections];
    [self.delegate homeworkManagerDidUpdate:self];
}

- (void)reloadSections {
    NSMutableDictionary *uniqueSubjects = [NSMutableDictionary dictionary];
    for (Homework *homework in self.allHomework) {
        NSString *subjectKey = [NSString stringWithFormat:@"%@ (%@)", homework.subject.subjectName, homework.subject.teacher];
        NSMutableArray *subjectHomework = uniqueSubjects[subjectKey];
        if(!subjectHomework) {
            subjectHomework = [NSMutableArray array];
        }
        
        if(![subjectHomework containsObject:homework]) {
            [subjectHomework addObject:homework];
        }
        uniqueSubjects[subjectKey] = subjectHomework;
    }
    self.sectionedHomeworkBySubject = uniqueSubjects;
}

- (NSMutableDictionary *)sectionedHomeworkBySubject {
    if(!_sectionedHomeworkBySubject) {
        _sectionedHomeworkBySubject = [NSMutableDictionary dictionary];
    }
    return _sectionedHomeworkBySubject;
}

- (void)save {
    NSData *homeworkData = [NSKeyedArchiver archivedDataWithRootObject:self.clearHomework];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:homeworkData forKey:HOMEWORKS_KEY];
    [standardDefaults synchronize];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.allHomework];
}
@end
