//
//  SubjectsView.m
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "SubjectsView.h"

#import "UIKitLocalizedString.h"

#import "LessonTableViewCell.h"
#import "Subject.h"

@implementation SubjectsView

+ (SubjectsView *)subjectsView {
    return [[[NSBundle mainBundle]loadNibNamed:@"SubjectsView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SubjectTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.createSubjectView.center = CGPointMake((CGFloat) (self.frame.size.width * 1.5), self.frame.size.height / 2);
    
    self.viewType = SubjectsViewTypeModal;
    
    self.createSubjectView.delegate = self;
    self.tableView.layer.cornerRadius = 2.5;
        
    [self reset];
}

- (SubjectsManager *)subjectsManager {
    if(!_subjectsManager) {
        _subjectsManager = [[SubjectsManager alloc]init];
    }
    return _subjectsManager;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.subjectsManager.count ? NSLocalizedString(@"Subjects", nil) : NSLocalizedString(@"No Subjects", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subjectsManager.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LessonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Subject *subject = self.subjectsManager[indexPath.row];
    cell.subjectLabel.text = subject.subjectName;
    cell.teacherLabel.text = subject.teacher;
    cell.subjectIndicatorView.backgroundColor = subject.color;
    if([subject isEqual:self.selectedSubject]) {
        cell.subjectLabel.textColor = [UIColor whiteColor];
        cell.teacherLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:(CGFloat) (0 / 255.0) green:(CGFloat) (153 / 255.0) blue:(CGFloat) (102 / 255.0) alpha:1];
    }
    else {
        cell.subjectLabel.textColor = [UIColor blackColor];
        cell.teacherLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self.subjectsManager deleteSubject:self.subjectsManager[indexPath.row]];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.editing) {
        self.createSubjectView.subject = self.subjectsManager[indexPath.row];
        [self createSubject:nil];
    }
    else if(self.viewType == SubjectsViewTypeSelection) {
        self.selectedSubject = self.subjectsManager[indexPath.row];
        [self.delegate subjectsView:self didSelectSubject:self.subjectsManager[indexPath.row]];
        [self.tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 8, 0, 0);
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:insets];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:insets];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGPoint centerOffset1 = self.center;
    centerOffset1.y += 15;
    self.tableView.center = centerOffset1;
    
    CGPoint centerOffset2 = self.center;
    centerOffset2.x += self.frame.size.width;
    self.createSubjectView.center = centerOffset2;
}

- (IBAction)createSubject:(id)sender {
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
    self.createSubjectView.hidden = NO;
    [self.tableView setEditing:NO animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.tableView.frame;
        frame.origin.y = self.frame.size.height;
        self.tableView.frame = frame;
    }];
    [UIView animateWithDuration:0.35 animations:^{
        self.createSubjectView.center = self.center;
    }];
}

- (void)edit:(UIBarButtonItem *)sender {
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createSubject:)];
    UIBarButtonItem *edit;
    if(!sender.tag) {
        edit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)];
        edit.tag = 1;
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        edit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
        [self.tableView setEditing:NO animated:YES];
    }
    if(!self.subjectsManager.count) {
        edit = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    [self.navigationItem setRightBarButtonItems:@[add, edit] animated:YES];
}

- (void)createSubjectViewDidCancel:(CreateSubjectView *)createSubjectView {
    [self endEditing:YES];
    [self.tableView setEditing:NO animated:YES];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createSubject:)];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    if(!self.subjectsManager.count) {
        edit = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    [self.navigationItem setRightBarButtonItems:@[add, edit] animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint centerOffset = self.center;
        centerOffset.x += self.frame.size.width;
        self.createSubjectView.center = centerOffset;
    } completion:^(BOOL finished) {
        [self.createSubjectView reset];
        self.createSubjectView.hidden = YES;
    }];
    [UIView animateWithDuration:0.35 animations:^{
        self.tableView.center = self.center;
    }];
}

- (void)createSubjectViewDidCreate:(CreateSubjectView *)createSubjectView {
    Subject *subject = createSubjectView.subject;
    [self.subjectsManager createSubject:subject];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self createSubjectViewDidCancel:createSubjectView];
}

- (void)reset {
    [self.tableView setEditing:NO animated:YES];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createSubject:)];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    if(!self.subjectsManager.count) {
        edit = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    [self.navigationItem setRightBarButtonItems:@[add, edit] animated:YES];
    self.tableView.contentOffset = CGPointMake(0, 26);
    self.selectedSubject = nil;
    [self.createSubjectView reset];
    
    [self.subjectsManager reload];
    [self.tableView reloadData];
}

- (void)setViewType:(SubjectsViewType)viewType {
    _viewType = viewType;
    if(_viewType == SubjectsViewTypeSelection) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:UIKitLocalizedString(UIKitCancelIdentifier) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    else if(_viewType == SubjectsViewTypeModal) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setSelectedSubject:(Subject *)selectedSubject {
    _selectedSubject = selectedSubject;
    NSUInteger index = [self.subjectsManager indexOfSubject:selectedSubject];
    if(index < INT_MAX) {
        if(index < self.tableView.visibleCells.count) {
            [self.tableView reloadData];
        }
        else {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
}

- (void)cancel:(UIBarButtonItem *)sender {
    [self.delegate subjectsViewDidCancel:self];
}


- (IBAction)cancelSelection:(id)sender {
    [self.delegate subjectsViewDidCancel:self];
}

@end
