//
//  CreateHomeworkView.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreateHomeworkView.h"

#import "SZTextView.h"

@implementation CreateHomeworkView

@synthesize homework = _homework;

+ (CreateHomeworkView *)createHomeworkView {
    return [[[NSBundle mainBundle]loadNibNamed:@"CreateHomeworkView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.subjectsView = [SubjectsView subjectsView];
    self.subjectsView.frame = self.bounds;
    [self.scrollView addSubview:self.subjectsView];
    
    CGSize contentSize = self.frame.size;
    contentSize.width *= 3;
    self.scrollView.contentSize = contentSize;
    
    self.subjectsView.delegate = self;
    self.workSetView.delegate = self;
    self.dueDateView.delegate = self;
    [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing:)]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification *)n {
    if(![self.workSetView.workSetTextView isFirstResponder]) {
        return;
    }
    CGSize keyboardSize = [n.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:[n.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        CGFloat keyboardOrigin = self.frame.size.height - keyboardSize.height;
        CGRect mainViewFrame = self.workSetView.mainView.frame;
        CGFloat mainViewEnd = mainViewFrame.origin.y + mainViewFrame.size.height;
        mainViewFrame.origin.y -= mainViewEnd - keyboardOrigin + 10;
        mainViewFrame.origin.y = MAX(mainViewFrame.origin.y, 64);
        self.workSetView.mainView.frame = mainViewFrame;
    }];
}

-(void)keyboardWillHide:(NSNotification *)n {
    if(![self.workSetView.workSetTextView isFirstResponder]) {
        return;
    }
    [UIView animateWithDuration:[n.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.workSetView.mainView.center = self.center;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.subjectsView.viewType = SubjectsViewTypeSelection;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [UIView performWithoutAnimation:^{
        CGRect frame1 = self.bounds;
        frame1.origin.x = -self.frame.origin.x;
        self.subjectsView.frame = frame1;
        self.workSetView.frame = frame1;
        self.dueDateView.frame = frame1;
        
        CGPoint center = self.center;
        self.subjectsView.center = center;
        
        center.x += self.frame.size.width;
        self.workSetView.center = center;
        
        center.x += self.frame.size.width;
        self.dueDateView.center = center;
    }];
}

- (void)reset {
    self.homework = nil;
    
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    [self.subjectsView reset];
    [self.workSetView reset];
    [self.dueDateView reset];
}

- (void)panToPage:(NSInteger)page {
    [self endEditing:YES];
    CGRect rect = self.bounds;
    rect.origin.x = (page - 1) * rect.size.width;
    [self.scrollView scrollRectToVisible:rect animated:YES];
}

- (void)subjectsViewDidCancel:(SubjectsView *)subjectsView {
    [self endEditing:YES];
    [self.delegate createHomeworkViewDidCancel:self];
}

- (void)subjectsView:(SubjectsView *)subjectsView didSelectSubject:(Subject *)subject {
    self.homework.subject = subject;
    [self panToPage:2];
}

- (void)createHomeworkWorkSetViewDidGoBack:(CreateHomeworkWorkSetView *)createHomeworkWorkSetView {
    [self panToPage:1];
}

- (void)createHomeworkWorkSetViewDidGoForward:(CreateHomeworkWorkSetView *)createHomeworkWorkSetView {
    self.homework.summary = createHomeworkWorkSetView.workSetTextView.text;
    self.homework.type = createHomeworkWorkSetView.homeworkType;
    self.homework.attachments = [createHomeworkWorkSetView.attachments copy];
    [self panToPage:3];
}

- (void)createHomeworkDueDateViewDidGoBack:(CreateHomeworkDueDateView *)createHomeworkDueDateView {
    [self panToPage:2];
}

- (void)createHomeworkDueDateViewDidCreate:(CreateHomeworkDueDateView *)createHomeworkDueDateView {
    [self endEditing:YES];
    self.homework.dueDate = createHomeworkDueDateView.dueDatePicker.date;
    [self.delegate createHomeworkViewDidCreate:self];
}

- (Homework *)homework {
    if(!_homework) {
        _homework = [[Homework alloc]init];
    }
    return _homework;
}


- (void)setHomework:(Homework *)homework {
    _homework = homework;
    if(!_homework) {
        return;
    }
    
    self.subjectsView.selectedSubject = homework.subject;
    
    self.workSetView.workSetTextView.text = homework.summary;
    self.workSetView.attachments = [homework.attachments mutableCopy];
    self.workSetView.homeworkType = homework.type;
    [self.workSetView.typeButton setTitle:[homework typeString] forState:UIControlStateNormal];
    [self.workSetView verify];
    
    self.dueDateView.dueDatePicker.date = homework.dueDate;
}

@end
