//
//  TickButton.h
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Homework;

@interface TickButton : UIButton

@property (strong, nonatomic) Homework *homework;

- (void)setDone:(BOOL)done;

@end
