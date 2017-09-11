//
//  Day.m
//  School Planner
//
//  Created by Hugh Bellamy on 18/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "Day.h"
#import "DaysManager.h"
#define ID_KEY @"day_id"
#define DAY_KEY @"day_day"
#define WEEK_KEY @"day_week"

@implementation Day

+ (Day *)dayWithDate:(NSDate *)date {
    Day *day = [[Day alloc]init];
    if(day && date) {
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:date];
        day.day = todayComponents.weekday - 1;
        day.week = [DaysManager currentWeek];
    }
    return day;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.ID = [aDecoder decodeObjectForKey:ID_KEY];
        
        self.day = [aDecoder decodeIntegerForKey:DAY_KEY];
        self.week = [aDecoder decodeIntegerForKey:WEEK_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:ID_KEY];
    [aCoder encodeInteger:self.day forKey:DAY_KEY];
    [aCoder encodeInteger:self.week forKey:WEEK_KEY];
}

- (id)copyWithZone:(NSZone *)zone {
    Day *day = (Day*)[[self class]allocWithZone:zone];
    day.ID = [self.ID copy];
    day.day = self.day;
    day.week = self.week;
    return day;
}

- (BOOL)isEqual:(id)object {
    return object == self || ([object isKindOfClass:[self class]] && [object day] == [self day] && [object week] == [self week]);

}

- (NSString *)ID {
    if(!_ID) {
        _ID = @"";
    }
    return _ID;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Date: (day: %@; week: %@)", @(self.day), @(self.week)];
}

- (NSString *)dayString {
    NSString *day = @"";
    if(self.day == 1) {
        day = @"Monday";
    }
    else if(self.day == 2) {
        day = @"Tuesday";
    }
    else if(self.day == 3) {
        day = @"Wednesday";
    }
    else if(self.day == 4) {
        day = @"Thursday";
    }
    else if(self.day == 5) {
        day = @"Friday";
    }
    else if(self.day == 6) {
        day = @"Saturday";
    }
    else if(self.day == 7) {
        day = @"Sunday";
    }
    return day;
}

- (NSString *)weekString {
    return [NSString stringWithFormat: @"Week %@", @(self.week)];
}

- (NSString *)titleString {
    if([DaysManager isTwoWeeked]) {
        return [self keyString];
    }
    else {
        return self.dayString;
    }
}

- (NSString *)keyString {
    return [NSString stringWithFormat:@"%@ - %@", [self dayString], [self weekString]];
}

@end
