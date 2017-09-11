//
//  Lesson.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Subject;
@class Day;

@interface Lesson : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) NSString *ID;

@property (strong, nonatomic) Subject *subject;
@property (strong, nonatomic) Day *day;

@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

@property (strong, nonatomic) NSString *extraNotes;

@property (strong, nonatomic) NSDate *creationDate;

@end
