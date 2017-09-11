//
//  CreateLessonView.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateLessonView.h"
#import "Lesson.h"

@implementation CreateLessonView

@synthesize lesson = _lesson;

+ (CreateLessonView *)createLessonView {
    return [[[NSBundle mainBundle]loadNibNamed:@"CreateLessonView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.subjectsView = [SubjectsView subjectsView];
    self.daysView = [DaysView daysView];
    
    CGRect frame = self.bounds;
    self.subjectsView.frame = frame;
    frame.origin.x = frame.size.width;
    self.daysView.frame = frame;
    
    [self.scrollView addSubview:self.subjectsView];
    [self.scrollView addSubview:self.daysView];
    
    CGSize contentSize = self.frame.size;
    contentSize.width *= 4;
    self.scrollView.contentSize = contentSize;
    
    self.subjectsView.delegate = self;
    self.daysView.delegate = self;
    self.timeStartView.delegate = self;
    self.timeEndView.delegate = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.subjectsView.viewType = SubjectsViewTypeSelection;
    self.daysView.viewType = DaysViewTypeSelection;
}

- (void)reset {
    self.lesson = nil;
    
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    [self.subjectsView reset];
    [self.daysView reset];
    [self.timeStartView reset];
    [self.timeEndView reset];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [UIView performWithoutAnimation:^{
        CGRect frame1 = self.bounds;
        frame1.origin.x = -self.frame.origin.x;
        self.subjectsView.frame = frame1;
        self.timeStartView.frame = frame1;
        self.timeEndView.frame = frame1;
        
        CGPoint center = self.center;
        self.subjectsView.center = center;
        
        center.x += self.frame.size.width;
        self.daysView.center = center;
        
        center.x += self.frame.size.width;
        self.timeStartView.center = center;
        
        center.x += self.frame.size.width;
        self.timeEndView.center = center;
    }];
}

- (void)panToPage:(NSInteger)page {
    [self endEditing:YES];
    CGRect rect = self.bounds;
    rect.origin.x = (page - 1) * rect.size.width;
    [self.scrollView scrollRectToVisible:rect animated:YES];
}

- (void)subjectsViewDidCancel:(SubjectsView *)subjectsView {
    [self endEditing:YES];
    [self.delegate createLessonViewDidCancel:self];
}

- (void)subjectsView:(SubjectsView *)subjectsView didSelectSubject:(Subject *)subject {
    self.lesson.subject = subject;
    [self panToPage:2];
}

- (void)daysViewDidCancel:(DaysView *)daysView {
    [self endEditing:YES];
    [self panToPage:1];
}

- (void)daysView:(DaysView *)daysView didSelectDay:(Day *)day {
    self.lesson.day = day;
    [self panToPage:3];
}

- (void)createLessonStartTimeViewDueDateViewDidGoBack:(CreateLessonStartTimeView *)createLessonStartTimeView {
    [self panToPage:2];
}

- (void)createLessonStartTimeViewDueDateViewDidGoForward:(CreateLessonStartTimeView *)createLessonStartTimeView {
    self.lesson.startTime = createLessonStartTimeView.timePicker.time;
    self.timeEndView.timePicker.minimumTime = createLessonStartTimeView.timePicker.time;
    [self panToPage:4];
}

- (void)createLessonEndTimeViewDueDateViewDidGoBack:(CreateLessonEndTimeView *)createLessonEndTimeView {
    [self panToPage:3];
}

- (void)createLessonEndTimeViewDueDateViewDidCreate:(CreateLessonEndTimeView *)createLessonEndTimeView {
    self.lesson.endTime = createLessonEndTimeView.timePicker.time;
    [self.delegate createLessonViewDidCreate:self];
}

- (Lesson *)lesson {
    if(!_lesson) {
        _lesson = [[Lesson alloc]init];
    }
    return _lesson;
}

- (void)setLesson:(Lesson *)lesson {
    _lesson = lesson;
    if(!lesson) {
        return;
    }
    
    self.subjectsView.selectedSubject = lesson.subject;
    self.daysView.selectedDay = lesson.day;
    self.timeStartView.timePicker.time = lesson.startTime;
    self.timeEndView.timePicker.time = lesson.endTime;
}

@end
