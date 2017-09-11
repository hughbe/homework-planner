//
//  Homework.h
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Subject;
@import UIKit;

typedef NS_ENUM(NSInteger, HomeworkType) {
    HomeworkTypeNone,
    HomeworkTypeEssay,
    HomeworkTypeExercise,
    HomeworkTypeRevision,
    HomeworkTypeNotes,
    HomeworkTypeOther
};

@interface Homework : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) NSString *ID;

@property (strong, nonatomic) Subject *subject;
@property (strong, nonatomic) NSString *summary;

@property (strong, nonatomic) NSDate *dueDate;

@property (strong, nonatomic) NSDate *creationDate;

@property (assign, nonatomic) HomeworkType type;
@property (strong, nonatomic) NSArray *attachments;

@property (assign, nonatomic) BOOL done;

@property (strong, nonatomic) UILocalNotification *notification;

- (NSString *)dueDateString;

- (NSString *)typeString;

- (void)addNotification;
- (void)removeNotification;
@end
