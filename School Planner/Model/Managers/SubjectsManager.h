//
//  SubjectsManager.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Subject;

@interface SubjectsManager : NSObject

- (void)reload;
- (void)save;

- (void)createSubject:(Subject *)subject;
- (void)deleteSubject:(Subject *)subject;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (NSInteger)count;

- (NSInteger)indexOfSubject:(Subject *)subject;
- (Subject *)subjectForID:(NSString *)ID;

@end
