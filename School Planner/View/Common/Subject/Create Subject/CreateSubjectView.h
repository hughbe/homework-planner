//
//  CreateSubjectView.h
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Subject;
@protocol CreateSubjectViewDelegate;

@interface CreateSubjectView : UIView <UITextFieldDelegate>

- (void)reset;

@property (weak, nonatomic) id<CreateSubjectViewDelegate> delegate;

@property (strong, nonatomic) Subject *subject;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextField *teacherTextField;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (weak, nonatomic) IBOutlet UIView *colorsView;

@end

@protocol CreateSubjectViewDelegate <NSObject>

- (void)createSubjectViewDidCancel:(CreateSubjectView *)createSubjectView;
- (void)createSubjectViewDidCreate:(CreateSubjectView *)createSubjectView;

@end

