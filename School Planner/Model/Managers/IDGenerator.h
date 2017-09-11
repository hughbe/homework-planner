//
//  IDGenerator.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDGenerator : NSObject

+ (NSString *)newHomeworkID;
+ (NSString *)newAttachmentID;

+ (NSString *)newSubjectID;
+ (NSString *)newDayID;
+ (NSString *)newLessonID;

@end
