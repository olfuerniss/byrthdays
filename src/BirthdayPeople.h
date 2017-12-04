//
//  BirthdayPeople.h
//  byrthdays
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BirthdayPerson.h"

@interface BirthdayPeople : NSObject

@property (nonatomic, readonly, strong) NSCalendar *calendar;

- (id) initWithCalendar:(NSCalendar *)calendar;
- (NSArray *) withinTheNextDays:(NSInteger)days;
- (NSArray *) all;

@end
