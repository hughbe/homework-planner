//
//  Day.h
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Day : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) NSString *ID;

@property (assign, nonatomic) NSInteger day;
@property (assign, nonatomic) NSInteger week;

- (NSString *)dayString;
- (NSString *)weekString;

- (NSString *)keyString;

+ (Day *)dayWithDate:(NSDate *)date;

@end
