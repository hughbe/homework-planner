//
//  Subject.h
//  School Planner
//
//  Created by Hugh Bellamy on 15/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Subject : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) NSString *ID;

@property (strong, nonatomic) NSString *subjectName;
@property (strong, nonatomic) NSString *teacher;

@property (strong, nonatomic) UIColor *color;

@end
