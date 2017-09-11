//
//  DaysView.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CreateDayView.h"

@class Day;
@class DaysManager;

@protocol DaysViewDelegate;

typedef NS_ENUM(NSInteger, DaysViewType) {
    DaysViewTypeModal,
    DaysViewTypeSelection
};

@interface DaysView : UIView <UITableViewDataSource, UITableViewDelegate, CreateDayViewDelegate>

+ (DaysView *)daysView;

- (void)reset;

@property (weak, nonatomic) id<DaysViewDelegate> delegate;
@property (assign, nonatomic) DaysViewType viewType;

@property (strong, nonatomic) DaysManager *daysManager;

@property (strong, nonatomic) Day *selectedDay;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet CreateDayView *createDayView;

@end

@protocol DaysViewDelegate <NSObject>

- (void)daysView:(DaysView *)daysView didSelectDay:(Day *)day;
- (void)daysViewDidCancel:(DaysView *)daysView;

@end
