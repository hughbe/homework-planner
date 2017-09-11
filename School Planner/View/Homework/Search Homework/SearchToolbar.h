//
//  SearchToolbar.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SearchToolbarDelegate;

@interface SearchToolbar : UIToolbar

@property (weak, nonatomic) id<SearchToolbarDelegate> searchDelegate;

@property (weak, nonatomic) IBOutlet UISegmentedControl *searchType;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showDone;

@end

@protocol SearchToolbarDelegate <NSObject>

- (void)searchToolbar:(SearchToolbar *)searchToolbar didSelectSearchType:(NSInteger)searchType;
- (void)searchToolbar:(SearchToolbar *)searchToolbar changeShowDone:(BOOL)show;

@end
