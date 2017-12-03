//
//  Byrthdays.h
//  byrthdayz
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ByrthdayPerson.h"

@interface Byrthdays : NSObject

@property (nonatomic, readonly, strong) NSCalendar *calendar;

- (id) initWithCalendar:(NSCalendar *)calendar;
- (NSArray *) byrthdayPeopleWithinTheNextDays:(NSInteger)days;

@end
