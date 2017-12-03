//
//  NSDate+Extension.h
//  byrthdayz
//
//  Created by Oliver Fürniß on 30.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

- (BOOL) isLaterThanOrEqualTo:(NSDate *)date;
- (BOOL) isEarlierThanOrEqualTo:(NSDate *)date;
- (BOOL) isLaterThan:(NSDate *)date;
- (BOOL) isEarlierThan:(NSDate *)date;
- (NSDate *) dateByAddingDays:(NSInteger)days;

@end
