//
//  HomeworkTableViewController.m
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "HomeworkViewController.h"

#import "HomeworkTableViewCell.h"
#import "TickButton.h"

typedef NS_ENUM(NSInteger, HomeworkSearchType) {
    HomeworkSearchTypeAll,
    HomeworkSearchTypeSubject,
    HomeworkSearchTypeTeacher,
    HomeworkSearchTypeWorkSet
};

@interface HomeworkViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) HomeworkManager *homeworkManager;

@property (assign, nonatomic) BOOL doNotUpdateSearchBarFrame;
@property (assign, nonatomic) HomeworkSearchType searchType;
@property (assign, nonatomic) BOOL showDone;

@end

@implementation HomeworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeworkTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.quickHomeworkView = [QuickHomeworkView quickHomeworkView];
    self.createHomeworkView = [CreateHomeworkView createHomeworkView];
    
    self.createHomeworkView.delegate = self;
    self.quickHomeworkView.delegate = self;
    
    self.noHomeworkView.center = self.view.center;
    [self.view bringSubviewToFront:self.noHomeworkView];
    
    CGRect frame1 = self.tabBarController.view.bounds;
    frame1.origin.x = frame1.size.width;
    self.createHomeworkView.frame = frame1;
    [self.tabBarController.view addSubview:self.createHomeworkView];
    
    self.quickHomeworkView.frame = self.tabBarController.view.bounds;
    [self.tabBarController.view addSubview:self.quickHomeworkView];
    
    self.quickHomeworkView.alpha = 0.0;
    
    [self displayNoHomeworkMessage:NO];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchBar)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    CGRect frame = self.searchBar.frame;
    frame.origin.y = -([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height);
    self.searchBar.frame = frame;
    
    self.showDone = YES;
    SearchToolbar *searchToolbar = [[[NSBundle mainBundle] loadNibNamed:@"SearchToolbar" owner:nil options:nil] firstObject];
    searchToolbar.searchDelegate = self;
    self.searchBar.inputAccessoryView = searchToolbar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.homeworkManager reload];
    [self.createHomeworkView.subjectsView.subjectsManager reload];
    [self.createHomeworkView.subjectsView.tableView reloadData];
}

- (void)setViewingID:(NSString *)viewingID {
    _viewingID = viewingID;
    if(viewingID.length) {
        for(Homework *homework in self.homeworkManager.allHomework) {
            if([homework.ID isEqualToString:viewingID]) {
                [self createHomeworkViewDidCancel:self.createHomeworkView];
                [self showQuickHomeworkView:homework];
                break;
            }
        }
    }
}

- (void)searchToolbar:(SearchToolbar *)searchToolbar changeShowDone:(BOOL)show {
    self.showDone = show;
    [self loadSearch];
}

- (void)searchToolbar:(SearchToolbar *)searchToolbar didSelectSearchType:(NSInteger)searchType {
    self.searchType = (HomeworkSearchType) searchType;
    [self loadSearch];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideSearchBar];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.doNotUpdateSearchBarFrame) {
        return;
    }
    
    [self.searchBar resignFirstResponder];
    if(scrollView.contentOffset.y < 0) {
        CGRect frame = self.searchBar.frame;
        frame.origin.y = -frame.size.height - scrollView.contentOffset.y;
        self.searchBar.frame = frame;
    }
    if(-scrollView.contentOffset.y > self.searchBar.frame.size.height) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -self.searchBar.frame.size.height);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.doNotUpdateSearchBarFrame = YES;
    if(scrollView.contentOffset.y < -self.searchBar.frame.size.height / 2.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
            CGRect frame = self.searchBar.frame;
            frame.origin.y = 0;
            self.searchBar.frame = frame;
        } completion:^(BOOL finished) {
            [self.searchBar becomeFirstResponder];
        }];
    }
    else {
        [self hideSearchBar];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.doNotUpdateSearchBarFrame = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self loadSearch];
}

- (void)loadSearch {
    NSPredicate *predicate;
    
    NSPredicate *donePredicate;
    NSPredicate *notDonePredicate = [NSPredicate predicateWithFormat:@"done == NO"];
    if(self.showDone) {
        NSPredicate *hasDonePredicate = [NSPredicate predicateWithFormat:@"done == YES"];
        donePredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[hasDonePredicate, notDonePredicate]];
    }
    else {
        donePredicate = notDonePredicate;
    }
    
    if(self.searchBar.text.length) {
        NSPredicate *subjectPredicate = [NSPredicate predicateWithFormat:@"subject.subjectName CONTAINS[c] %@", self.searchBar.text];
        NSPredicate *teacherPredicate = [NSPredicate predicateWithFormat:@"subject.teacher CONTAINS[c] %@", self.searchBar.text];
        NSPredicate *workSetPredicate = [NSPredicate predicateWithFormat:@"summary CONTAINS[c] %@", self.searchBar.text];
        
        
        if(self.searchType == HomeworkSearchTypeAll) {
            NSPredicate *allPredicate = [NSCompoundPredicate orPredicateWithSubpredicates: @[subjectPredicate, teacherPredicate, workSetPredicate]];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[allPredicate, donePredicate]];
        }
        else if(self.searchType == HomeworkSearchTypeSubject) {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[subjectPredicate, donePredicate]];
        }
        else if(self.searchType == HomeworkSearchTypeTeacher) {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[teacherPredicate, donePredicate]];
        }
        else if(self.searchType == HomeworkSearchTypeWorkSet) {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[workSetPredicate, donePredicate]];
        }
    }
    else {
        predicate = donePredicate;
    }
    
    [self.homeworkManager searchWithPredicate:predicate informDelegate:YES];
    
}

- (void)hideSearchBar {
    self.doNotUpdateSearchBarFrame = NO;
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        CGRect frame = self.searchBar.frame;
        frame.origin.y = -frame.size.height
        ;
        self.searchBar.frame = frame;
    }];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *) otherGestureRecognizer {
    return YES;
}

- (HomeworkManager *)homeworkManager {
    if(!_homeworkManager) {
        _homeworkManager = [[HomeworkManager alloc]initWithDelegate:self];
    }
    return _homeworkManager;
}

- (void)displayNoHomeworkMessage:(BOOL)animated {
    if(self.homeworkManager.allHomework.count) {
        [UIView animateWithDuration:0.2 animations:^{
            self.noHomeworkView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.noHomeworkView.alpha = 1.0;
            self.noHomeworkView.hidden = YES;
        }];
        if(!self.navigationItem.leftBarButtonItem) {
            if(self.tableView.editing) {
                UIBarButtonItem *doneButtonItem  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)];
                doneButtonItem.tag = 1;
                [self.navigationItem setLeftBarButtonItem:doneButtonItem];
            }
            else {
                [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)] animated:animated];
            }
        }
    }
    else {
        if(self.noHomeworkView.hidden) {
            self.noHomeworkView.alpha = 0.0;
            self.noHomeworkView.hidden = NO;
            [UIView animateWithDuration:0.2 animations:^{
                self.noHomeworkView.alpha = 1.0;
            }];
        }
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
    }
}

- (void)homeworkManagerDidUpdate:(HomeworkManager *)homeworkManager {
    [self displayNoHomeworkMessage:YES];
    [UIView transitionWithView: self.tableView duration: 0.35f options: UIViewAnimationOptionTransitionCrossDissolve animations: ^(void) {
        [self.tableView reloadData];
    } completion: nil];
}

- (IBAction)createHomework:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect subjectsFrame = self.createHomeworkView.frame;
        subjectsFrame.origin.x = 0;
        self.createHomeworkView.frame = subjectsFrame;
    }];
    
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
}

- (void)createHomeworkViewDidCancel:(CreateHomeworkView *)createHomeworkView {
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = self.createHomeworkView.frame;
        frame.origin.x = frame.size.width;
        self.createHomeworkView.frame = frame;
    } completion:^(BOOL finished) {
        [self.createHomeworkView reset];
    }];
    [self.homeworkManager reload];
    [self.tableView reloadData];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createHomework:)] animated:YES];
}

- (void)createHomeworkViewDidCreate:(CreateHomeworkView *)createHomeworkView {
    Homework *homework = createHomeworkView.homework;
    [self.homeworkManager createHomework:homework];
    [self createHomeworkViewDidCancel:createHomeworkView]; //Dismiss
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.homeworkManager.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.homeworkManager numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Homework *homework = [self.homeworkManager homeworkForSection:indexPath.section row:indexPath.row];
    if(!homework) {
        return cell;
    }
    
    cell.subjectLabel.text = homework.summary;
    cell.timeLabel.text = [homework dueDateString];
    
    TickButton *accessoryButton = [TickButton buttonWithType:UIButtonTypeCustom];
    [accessoryButton setDone:homework.done];
    accessoryButton.homework = homework;
    
    accessoryButton.adjustsImageWhenHighlighted = NO;
    [accessoryButton setFrame:CGRectMake(50, 0, 40, 40)];
    [accessoryButton addTarget:self action:@selector(changeChecked:)forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryButton;
    
    //Get which ones are due today + get which are past due
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit components = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *dueDateComponents = [calendar components:components fromDate:homework.dueDate];
    NSDateComponents *currentDateComponents = [calendar components:components fromDate:[NSDate date]];
    
    NSDate *dueDate = [calendar dateFromComponents:dueDateComponents];
    NSDate *currentDate = [calendar dateFromComponents:currentDateComponents];
    
    NSComparisonResult comparison = [dueDate compare:currentDate];
    
    if(comparison == NSOrderedAscending && !homework.done) {
        cell.timeLabel.textColor = [cell timeLabelOverdueColor];
        cell.timeLabel.text = [@"Overdue - " stringByAppendingString:cell.timeLabel.text];
    }
    else if(comparison == NSOrderedSame && !homework.done) {
        cell.timeLabel.textColor = [cell timeLabelTodayColor];
        cell.timeLabel.text = NSLocalizedString(@"Today", nil);
    }
    else {
        cell.timeLabel.textColor = [cell timeLabelNormalColor];
    }
    
    return cell;
}

- (void)changeChecked:(TickButton *)tickButton {
    tickButton.homework.done = !tickButton.homework.done;
    if(tickButton.homework.done) {
        [tickButton.homework removeNotification];
    }
    else {
        [tickButton.homework addNotification];
    }
    [tickButton setDone:tickButton.homework.done];
    [self.homeworkManager save];
    [self.tableView reloadData];
}

- (void)edit:(UIBarButtonItem *)sender {
    if(!sender.tag) {
        //Start editing
        UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)];
        doneBarButtonItem.tag = 1;
        [self.navigationItem setLeftBarButtonItem:doneBarButtonItem animated:YES];
        
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        //End editing
        UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
        editBarButtonItem.tag = 0;
        [self.navigationItem setLeftBarButtonItem:editBarButtonItem animated:YES];
        
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        //Delete only the cell or the whole section if needs be
        if([self.homeworkManager numberOfRowsInSection:indexPath.section] > 1) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
        }
        Homework *homework = [self.homeworkManager homeworkForSection:indexPath.section row:indexPath.row];
        [self.homeworkManager deleteHomework:homework];
        [tableView endUpdates];
        [self displayNoHomeworkMessage:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.homeworkManager titleForSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Homework *homework = [self.homeworkManager homeworkForSection:indexPath.section row:indexPath.row];
    if(tableView.editing) {
        [tableView setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
        self.createHomeworkView.homework = [homework copy];
        [self createHomework:nil];
    }
    else {
        [self showQuickHomeworkView:homework];
    }
}

- (void)showQuickHomeworkView:(Homework *)homework {
    self.quickHomeworkView.homework = homework;
    [UIView animateWithDuration: 0.15 animations:^{
        self.quickHomeworkView.alpha = 1.0;
    }];
}

- (void)quickHomeworkViewDidClose:(QuickHomeworkView *)quickHomeworkView {
    [UIView animateWithDuration: 0.15 animations:^{
        self.quickHomeworkView.alpha = 0.0;
    }];
}

@end
