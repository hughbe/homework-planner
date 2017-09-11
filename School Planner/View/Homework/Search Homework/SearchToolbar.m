//
//  SearchToolbar.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "SearchToolbar.h"

@implementation SearchToolbar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.barTintColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.tintColor = [UIColor blackColor];
    self.searchType.tintColor = [UIColor blackColor];
}

- (IBAction)showDone:(UIBarButtonItem *)sender {
    if(sender.tag == 1) {
        sender.tag = 0;
        self.tintColor = [UIColor lightGrayColor];
    }
    else {
        sender.tag = 1;;
        self.tintColor = [UIColor blackColor];
    }
    [self.searchDelegate searchToolbar:self changeShowDone:(BOOL) sender.tag];
}

- (IBAction)changeSelectedSearchType:(UISegmentedControl *)sender {
    [self.searchDelegate searchToolbar:self didSelectSearchType:sender.selectedSegmentIndex];
}

@end
