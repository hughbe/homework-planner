//
//  IDGenerator.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "IDGenerator.h"

#define HOMEWORK_SUFFIX @"_homework"
#define ATTACHMENT_SUFFIX @"_attachment"

#define SUBJECT_SUFFIX @"_subject"
#define DAY_SUFFIX @"_day"
#define LESSON_SUFFIX @"_lesson"

@interface IDGenerator ()

+ (NSString *)previousIDForSuffix:(NSString *)suffix;
+ (NSString *)newIDForSuffix:(NSString *)suffix;

@end

@implementation IDGenerator

+ (NSString *)newHomeworkID {
    return [IDGenerator newIDForSuffix:HOMEWORK_SUFFIX];
}

+ (NSString *)newAttachmentID {
    return [IDGenerator newIDForSuffix:ATTACHMENT_SUFFIX];
}

+ (NSString *)newSubjectID {
    return [IDGenerator newIDForSuffix:LESSON_SUFFIX];
}

+ (NSString *)newDayID {
    return [IDGenerator newIDForSuffix:DAY_SUFFIX];
}

+ (NSString *)newLessonID {
    return [IDGenerator newIDForSuffix:SUBJECT_SUFFIX];
}


+ (NSString *)previousIDForSuffix:(NSString *)suffix {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSString *previousID = [standardDefaults objectForKey:[@"id" stringByAppendingString:suffix]];
    if(!previousID || ! previousID.length) {
        previousID = [@(0) stringValue];
    }
    return previousID;
}

+ (NSString *)newIDForSuffix:(NSString *)suffix {
    NSString *previousID = [self previousIDForSuffix:suffix];
    NSInteger newIDInteger = [previousID integerValue] + 1;
    NSNumber *newIDNumber = @(newIDInteger);
    NSString *newID = [newIDNumber stringValue];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:newID forKey:[@"id" stringByAppendingString:suffix]];
    [standardDefaults synchronize];
    return newID;
}

@end
