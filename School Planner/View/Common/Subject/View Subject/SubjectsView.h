//
//  SubjectsView.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubjectsManager.h"
#import "CreateSubjectView.h"
@class Subject;

typedef NS_ENUM(NSInteger, SubjectsViewType) {
    SubjectsViewTypeModal,
    SubjectsViewTypeSelection
};

@protocol SubjectsViewDelegate;

@interface SubjectsView : UIView <UITableViewDataSource, UITableViewDelegate, CreateSubjectViewDelegate>

+ (SubjectsView *)subjectsView;

- (void)reset;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) id<SubjectsViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CreateSubjectView *createSubjectView;

@property (strong, nonatomic) Subject *selectedSubject;

@property (strong, nonatomic) SubjectsManager *subjectsManager;

@property (assign, nonatomic) SubjectsViewType viewType;

@end

@protocol SubjectsViewDelegate <NSObject>

- (void)subjectsView:(SubjectsView *)subjectsView didSelectSubject:(Subject *)subject;
- (void)subjectsViewDidCancel:(SubjectsView *)subjectsView;

@end
