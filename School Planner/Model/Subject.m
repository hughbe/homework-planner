//
//  Subject.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "Subject.h"

#define ID_KEY @"subject_id"

#define SUBJECT_KEY @"subject_subject"
#define TEACHER_KEY @"subject_teacher"

#define COLOR_KEY @"subject_color"

@implementation Subject

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.ID = [aDecoder decodeObjectForKey:ID_KEY];
        
        self.subjectName = [aDecoder decodeObjectForKey:SUBJECT_KEY];
        self.teacher = [aDecoder decodeObjectForKey:TEACHER_KEY];
        
        self.color = [aDecoder decodeObjectForKey:COLOR_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:ID_KEY];
    
    [aCoder encodeObject:self.subjectName forKey:SUBJECT_KEY];
    [aCoder encodeObject:self.teacher forKey:TEACHER_KEY];
    
    [aCoder encodeObject:self.color forKey:COLOR_KEY];
}

- (NSString *)ID {
    if(!_ID) {
        _ID = @"";
    }
    return _ID;
}

- (NSString *)subjectName {
    if(!_subjectName) {
        _subjectName = @"";
    }
    return _subjectName;
}

- (NSString *)teacher {
    if (!_teacher) {
        _teacher = @"";
    }
    return _teacher;
}

- (UIColor *)color {
    if(!_color) {
        _color = [UIColor whiteColor];
    }
    return _color;
}

- (BOOL)isEqual:(id)object {
    return object == self || ([object isKindOfClass:[self class]] && [[object ID] isEqualToString:[self ID]] && [object ID].length);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Subject: (Lesson: %@, Teacher: %@, ID: %@)", self.subjectName, self.teacher, self.ID];
}

- (id)copyWithZone:(NSZone *)zone {
    Subject *subject = (Subject *)[[self class] allocWithZone:zone];
    subject.ID = [self.ID copyWithZone:zone];
    subject.subjectName = [self.subjectName copyWithZone:zone];
    subject.teacher = [self.teacher copyWithZone:zone];
    subject.color = [self.color copyWithZone:zone];
    return subject;
}
@end
