//
//  Lesson.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "Lesson.h"

#import "Subject.h"
#import "Day.h"

#define ID_KEY @"lesson_id"

#define SUBJECT_KEY @"lesson_subject"
#define DAY_KEY @"lesson_day"

#define START_TIME_KEY @"lesson_start_time"
#define END_TIME_KEY @"lesson_end_time"

#define EXTRA_NOTES_KEY @"lesson_extra_notes"

#define CREATION_DATE_KEY @"lesson_creation_date"

@implementation Lesson

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.ID = [aDecoder decodeObjectForKey:ID_KEY];
        
        self.subject = [aDecoder decodeObjectForKey:SUBJECT_KEY];
        self.day = [aDecoder decodeObjectForKey:DAY_KEY];
        
        self.startTime = [aDecoder decodeObjectForKey:START_TIME_KEY];
        self.endTime = [aDecoder decodeObjectForKey:END_TIME_KEY];
        
        self.extraNotes = [aDecoder decodeObjectForKey:EXTRA_NOTES_KEY];
        
        self.creationDate = [aDecoder decodeObjectForKey:CREATION_DATE_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:ID_KEY];
    
    [aCoder encodeObject:self.subject forKey:SUBJECT_KEY];
    [aCoder encodeObject:self.day forKey:DAY_KEY];
    
    [aCoder encodeObject:self.startTime forKey:START_TIME_KEY];
    [aCoder encodeObject:self.endTime forKey:END_TIME_KEY];
    
    [aCoder encodeObject:self.extraNotes forKey:EXTRA_NOTES_KEY];
    
    [aCoder encodeObject:self.creationDate forKey:CREATION_DATE_KEY];
}

- (id)copyWithZone:(NSZone *)zone {
    Lesson *lesson = (Lesson *)[[self class]allocWithZone:zone];
    lesson.ID = [self.ID copyWithZone:zone];
    lesson.subject = [self.subject copyWithZone:zone];
    lesson.day = [self.day copyWithZone:zone];
    lesson.startTime = [self.startTime copyWithZone:zone];
    lesson.endTime = [self.endTime copyWithZone:zone];
    lesson.extraNotes = [self.extraNotes copyWithZone:zone];
    lesson.creationDate = [self.creationDate copyWithZone:zone];
    return lesson;
}

- (BOOL)isEqual:(id)object {
    return object == self || ([object isKindOfClass:[self class]] && [[object ID] isEqualToString:[self ID]] && [object ID].length);

}

- (NSString *)description {
    return [NSString stringWithFormat:@"Lesson: (%@ day: %@;start: %@; end: %@; ID: %@)", self.subject, self.day, self.startTime, self.endTime, self.ID];
}

- (NSString *)ID {
    if(!_ID) {
        _ID = @"";
    }
    return _ID;
}

- (Subject *)subject {
    if(!_subject) {
        _subject = [[Subject alloc]init];
    }
    return _subject;
}

- (Day *)day {
    if(!_day) {
        _day = [[Day alloc]init];
    }
    return _day;
}

- (NSDate *)startTime {
    if(!_startTime) {
        _startTime = [NSDate date];
    }
    return _startTime;
}

- (NSDate *)endTime {
    if(!_endTime) {
        _endTime = [NSDate date];
    }
    return _endTime;
}

- (NSString *)extraNotes {
    if(!_extraNotes) {
        _extraNotes = @"";
    }
    return _extraNotes;
}

- (NSDate *)creationDate {
    if(!_creationDate) {
        _creationDate = [NSDate date];
    }
    return _creationDate;
}

@end
