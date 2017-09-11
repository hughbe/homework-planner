//
//  Homework.m
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "Homework.h"

#import "Subject.h"

#define ID_KEY @"homework_id"
#define SUBJECT_KEY @"homework_subject"

#define SUMMARY_KEY @"homework_summary"
#define DUE_DATE_KEY @"homework_due_date"

#define DONE_KEY @"homework_done"

#define TYPE_KEY @"homework_type"
#define ATTACHMENTS_KEY @"homework_attachments"

#define CREATION_DATE_KEY @"homework_creation_date"

#define NOTIFICATION_KEY @"homework_notification"

@implementation Homework

- (BOOL)isEqual:(id)object {
    return object == self || ([object isKindOfClass:[Homework class]] && [[object ID] isEqualToString:[self ID]] && [object ID].length);

}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ Homework - %@ - set for %@ - done %@- ID %@", self.subject, self.summary, self.dueDate, @(self.done), self.ID];
}

- (NSString *)dueDateString {
    NSDateFormatter *prefixDateFormatter = [[NSDateFormatter alloc] init];
    [prefixDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [prefixDateFormatter setDateFormat:@"EEEE dd"];
    NSString *prefixDateString = [prefixDateFormatter stringFromDate:self.dueDate];
    
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setDateFormat:@"d"];
    NSInteger date_day = [[monthDayFormatter stringFromDate:self.dueDate] integerValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = suffixes[(NSUInteger)date_day];
    
    NSDateFormatter *monthFormatter =[[NSDateFormatter alloc]init];
    [monthFormatter setDateFormat:@" MMMM"];
    
    NSString *dateString = [[prefixDateString stringByAppendingString:suffix]stringByAppendingString:[monthFormatter stringFromDate:self.dueDate]];
    return dateString;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.ID = [aDecoder decodeObjectForKey:ID_KEY];
        
        self.subject = [aDecoder decodeObjectForKey:SUBJECT_KEY];
        self.summary = [aDecoder decodeObjectForKey:SUMMARY_KEY];
        
        self.dueDate = [aDecoder decodeObjectForKey:DUE_DATE_KEY];
        
        self.type = (HomeworkType) [aDecoder decodeIntegerForKey:TYPE_KEY];
        self.attachments = [aDecoder decodeObjectForKey:ATTACHMENTS_KEY];
        self.done = [aDecoder decodeBoolForKey:DONE_KEY];
        
        self.creationDate = [aDecoder decodeObjectForKey:CREATION_DATE_KEY];
        self.notification = [aDecoder decodeObjectForKey:NOTIFICATION_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:ID_KEY];
    
    [aCoder encodeObject:self.subject forKey:SUBJECT_KEY];
    [aCoder encodeObject:self.summary forKey:SUMMARY_KEY];
    
    [aCoder encodeObject:self.dueDate forKey:DUE_DATE_KEY];
    
    [aCoder encodeInteger:self.type forKey:TYPE_KEY];
    [aCoder encodeObject:self.attachments forKey:ATTACHMENTS_KEY];
    [aCoder encodeBool:self.done forKey:DONE_KEY];
    
    [aCoder encodeObject:self.creationDate forKey:CREATION_DATE_KEY];
    [aCoder encodeObject:self.notification forKey:NOTIFICATION_KEY];
}

- (Subject *)subject {
    if(!_subject) {
        _subject = [[Subject alloc]init];
    }
    return _subject;
}

- (NSString *)summary {
    if(!_summary) {
        _summary = @"";
    }
    return _summary;
}

- (NSDate *)dueDate {
    if(!_dueDate) {
        _dueDate = [NSDate date];
    }
    return _dueDate;
}

- (NSDate *)creationDate {
    if(!_creationDate) {
        _creationDate = [NSDate date];
    }
    return _creationDate;
}

- (NSArray *)attachments {
    if(!_attachments) {
        _attachments = [NSArray array];
    }
    return _attachments;
}

- (NSString *)typeString {
    NSString *type;
    if(self.type == HomeworkTypeNone) {
        type = @"No Type";
    }
    else if(self.type == HomeworkTypeEssay) {
        type = @"Essay";
    }
    else if(self.type == HomeworkTypeExercise) {
        type = @"Exercise";
    }
    else if(self.type == HomeworkTypeRevision) {
        type = @"Revision";
    }
    else if(self.type == HomeworkTypeNotes) {
        type = @"Notes";
    }
    else if(self.type == HomeworkTypeOther) {
        type = @"Other";
    }
    return type;
}

- (id)copyWithZone:(NSZone *)zone {
    Homework *homework = (Homework *)[[self class] allocWithZone:zone];
    homework.ID = [self.ID copyWithZone:zone];
    homework.subject = [self.subject copyWithZone:zone];
    homework.summary = [self.summary copyWithZone:zone];
    homework.dueDate = [self.dueDate copyWithZone:zone];
    homework.creationDate = [self.creationDate copyWithZone:zone];
    homework.type = self.type;
    homework.done = self.done;
    homework.attachments = [self.attachments copyWithZone:zone];
    homework.notification = [self.notification copyWithZone:zone];
    return homework;
}

- (void)addNotification {
    #ifndef TARGET_IS_EXTENSION
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
    [self removeNotification];
    
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    NSDateComponents *dueComponents = [[NSCalendar currentCalendar] components:units fromDate:self.dueDate];

    NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
    NSDate *due = [[NSCalendar currentCalendar] dateFromComponents:dueComponents];
    
    if([today compare:due] == NSOrderedAscending) {
        self.notification = [[UILocalNotification alloc] init];
        
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = -1;
        NSDate *fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:self.dueDate options:0];
        
        self.notification.fireDate = fireDate;
        self.notification.alertBody = [NSString stringWithFormat:@"%@ homework is due tomorrow", self.subject.subjectName];
        self.notification.soundName = UILocalNotificationDefaultSoundName;
        self.notification.userInfo = @{@"homework" : self.ID};
        [[UIApplication sharedApplication] scheduleLocalNotification:self.notification];
    }
    #endif
}

- (void)removeNotification {
    #ifndef TARGET_IS_EXTENSION
    if([[UIApplication sharedApplication].scheduledLocalNotifications containsObject:self.notification]) {
        [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
    }
    #endif
}
@end
