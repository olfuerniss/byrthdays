//
//  NSDate+Extension.m
//  byrthdayz
//
//  Created by Oliver Fürniß on 30.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

-(BOOL) isLaterThanOrEqualTo:(NSDate *)date {
    return !([self compare:date] == NSOrderedAscending);
}

-(BOOL) isEarlierThanOrEqualTo:(NSDate *)date {
    return !([self compare:date] == NSOrderedDescending);
}

-(BOOL) isLaterThan:(NSDate *)date {
    return ([self compare:date] == NSOrderedDescending);
    
}
-(BOOL) isEarlierThan:(NSDate *)date {
    return ([self compare:date] == NSOrderedAscending);
}

- (NSDate *) dateByAddingDays:(NSInteger)days {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
   
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

@end
