//
//  HomeworkManager.h
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Homework;
@protocol HomeworkManagerDelegate;

@interface HomeworkManager : NSObject

- (instancetype)initWithDelegate:(id<HomeworkManagerDelegate>)delegate;

- (void)createHomework:(Homework *)homework;
- (void)deleteHomework:(Homework *)homework;

- (void)save;
- (void)reload;

- (NSString *)titleForSection:(NSInteger)section;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSArray *)orderedSubjectKeys;

- (void)searchWithPredicate:(NSPredicate *)predicate informDelegate:(BOOL)informDelegate;

- (Homework *)homeworkForSection:(NSInteger)section row:(NSInteger)row;
- (NSArray *)homeworkForDate:(NSDate *)date;

@property (strong, nonatomic) NSMutableDictionary *sectionedHomeworkBySubject;

@property (strong, nonatomic) NSArray *allHomework;

@property (weak, nonatomic) id<HomeworkManagerDelegate> delegate;

@end

@protocol HomeworkManagerDelegate <NSObject>

- (void)homeworkManagerDidUpdate:(HomeworkManager *)homeworkManager;

@end
