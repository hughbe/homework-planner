//
//  TickButton.m
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "TickButton.h"

@implementation TickButton

- (void)setDone:(BOOL)done {
    if(done) {
        [self setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        self.tag=1;
    }
    else {
        
        [self setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
        self.tag=0;
    }
}

@end
