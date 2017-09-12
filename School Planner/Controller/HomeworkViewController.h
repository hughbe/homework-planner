//
//  HomeworkTableViewController.h
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Homework;

#import "HomeworkManager.h"
#import "CreateHomeworkView.h"
#import "QuickHomeworkView.h"
#import "SearchToolbar.h"

@interface HomeworkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CreateHomeworkViewDelegate, HomeworkManagerDelegate, QuickHomeworkViewDelegate, SearchToolbarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIImageView *noHomeworkView;

@property (strong, nonatomic) CreateHomeworkView *createHomeworkView;

@property (strong, nonatomic) QuickHomeworkView *quickHomeworkView;

@property (strong, nonatomic) NSString *viewingID;

@end
