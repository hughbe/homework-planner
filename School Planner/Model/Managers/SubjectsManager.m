//
//  SubjectsManager.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "SubjectsManager.h"
#import "Subject.h"
#import "IDGenerator.h"

#define SUBJECTS_KEY @"subjects"

@interface SubjectsManager ()

@property (strong, nonatomic) NSArray *allSubjects;

@end

@implementation SubjectsManager

- (instancetype)init {
    self = [super init];
    if(self) {
        [self reload];
    }
    return self;
}

- (void)reload {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSData *subjectData = [standardDefaults objectForKey:SUBJECTS_KEY];
    if(subjectData) {
        self.allSubjects = [NSKeyedUnarchiver unarchiveObjectWithData:subjectData];
    }
}

- (void)save {
    NSData *subjectData = [NSKeyedArchiver archivedDataWithRootObject:self.allSubjects];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:subjectData forKey:SUBJECTS_KEY];
    [standardDefaults synchronize];
}

- (void)createSubject:(Subject *)subject {
    if([self.allSubjects containsObject:subject]) {
        NSInteger index = [self.allSubjects indexOfObject:subject];
        NSMutableArray *mutableSubjects = [self.allSubjects mutableCopy];
        mutableSubjects[index] = subject;
        self.allSubjects = [mutableSubjects copy];
    }
    else {
        subject.ID = [IDGenerator newSubjectID];
        self.allSubjects = [self.allSubjects arrayByAddingObject:subject];
    }
    [self save];
}

- (void)deleteSubject:(Subject *)subject {
    if(![self.allSubjects containsObject:subject]) {
        return;
    }
    
    NSMutableArray *mutableSubjects = [self.allSubjects mutableCopy];
    [mutableSubjects removeObject:subject];
    self.allSubjects = [mutableSubjects copy];
    [self save];
}
- (NSArray *)allSubjects {
    if(!_allSubjects) {
        _allSubjects = [NSArray array];
    }
    return _allSubjects;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.allSubjects[idx];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    NSMutableArray *mutableSubjects = [self.allSubjects mutableCopy];
    mutableSubjects[idx] = obj;
    self.allSubjects = [mutableSubjects copy];
}

- (NSInteger)count {
    return self.allSubjects.count;
}

- (NSInteger)indexOfSubject:(Subject *)subject {
    return [self.allSubjects indexOfObject:subject];
}

- (Subject *)subjectForID:(NSString *)ID {
    for (Subject *subject in self.allSubjects) {
        if([subject.ID isEqualToString:ID]) {
            return subject;
        }
    }
    return nil;
}

@end
