//
//  Byrthdays.m
//  byrthdayz
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "Byrthdays.h"
#import <AddressBook/AddressBook.h>

@implementation Byrthdays

- (id) initWithCalendar:(NSCalendar *)calendar {
    if (self = [super init]) {
        _calendar = calendar;
    }
    return self;
}

#pragma mark - Birthday logic

- (NSArray *) byrthdayPeopleWithinTheNextDays:(NSInteger)days {
    NSArray *byrthdayPeople = [self allByrthdayPeople];
    
    if(days < 0) {
        return byrthdayPeople;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    for(ByrthdayPerson *byrthdayPerson in byrthdayPeople) {
        if([byrthdayPerson daysToBirthday] <= days) {
            [results addObject:byrthdayPerson];
        } else {
            break;
        }
    }
    
    return results;
}

#pragma mark - Utility methods

- (NSDate *) comparableDateForDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year {
    return [self.calendar dateWithEra:1
                                 year:year
                                month:month
                                  day:day
                                 hour:23
                               minute:59
                               second:59
                           nanosecond:0];
}

- (NSArray *) allByrthdayPeople {
    // get the current date
    NSDate *todaysDate = [NSDate date];
    NSDateComponents *todaysDateComponents = [self.calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:todaysDate];
    
    // try to get me
    ABPerson *me = [[ABAddressBook sharedAddressBook] me];
    
    // get the persons with birthdays from the address book
    NSMutableArray *people = [NSMutableArray arrayWithCapacity:10];
    for(ABPerson *person in [[ABAddressBook sharedAddressBook] people]) {
        NSDateComponents *birthdayDateComponents = [person valueForProperty:kABBirthdayComponentsProperty];
        if (birthdayDateComponents != nil) {
            NSString *firstName = [person valueForProperty:kABFirstNameProperty];
            NSString *lastName = [person valueForProperty:kABLastNameProperty];
            NSString *nickname = [person valueForProperty:kABNicknameProperty];
            
            NSDate *birthdayDate = [self comparableDateForDay:[birthdayDateComponents day]
                                                        month:[birthdayDateComponents month]
                                                         year:[birthdayDateComponents day]];
            
            // next birthday date
            NSInteger birthdayYear = [todaysDateComponents year];
            if(([birthdayDateComponents month] == [todaysDateComponents month] && [birthdayDateComponents day] < [todaysDateComponents day]) || [birthdayDateComponents month] < [todaysDateComponents month])  {
                birthdayYear++;
            }
            NSDate *nextBirthdayDate = [self comparableDateForDay:[birthdayDateComponents day]
                                                            month:[birthdayDateComponents month]
                                                             year:birthdayYear];

            // compute the age
            NSInteger age = 0;
            if([birthdayDateComponents year] != NSNotFound) {
                age = birthdayYear - [birthdayDateComponents year];
            }
            
            // compute the days to birthday
            NSDateComponents *components = [self.calendar components:(NSCalendarUnitDay)
                                                            fromDate:todaysDate
                                                              toDate:nextBirthdayDate
                                                             options:0];
            NSInteger daysToBirthday = ABS([components day]);

            // create the byrthday person object
            ByrthdayPerson *byrthdayPerson = [[ByrthdayPerson alloc] init];
            byrthdayPerson.uniqueId = [person uniqueId];
            byrthdayPerson.me = (me != nil && me == person);
            byrthdayPerson.firstName = (firstName ? firstName : @"");
            byrthdayPerson.lastName = (lastName ? lastName : @"");
            byrthdayPerson.nickName = (nickname ? nickname : @"");
            byrthdayPerson.birthdayDate = birthdayDate;
            byrthdayPerson.nextBirthdayDate = nextBirthdayDate;
            byrthdayPerson.age = age;
            byrthdayPerson.daysToBirthday = daysToBirthday;
            
            [people addObject:byrthdayPerson];
        }
    }
    
    [people sortUsingComparator:^NSComparisonResult(id person1, id person2) {
        NSDate *first = [(ByrthdayPerson *)person1 nextBirthdayDate];
        NSDate *second = [(ByrthdayPerson *)person2 nextBirthdayDate];
        return [first compare:second];
    }];
    
    return people;
}

@end
