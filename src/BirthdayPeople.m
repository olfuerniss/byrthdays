//
//  BirthdayPeople.m
//  byrthdays
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "BirthdayPeople.h"
#import <AddressBook/AddressBook.h>

@implementation BirthdayPeople

- (id) initWithCalendar:(NSCalendar *)calendar {
    if (self = [super init]) {
        _calendar = calendar;
    }
    return self;
}

#pragma mark - instance methods

- (NSArray *) withinTheNextDays:(NSInteger)days {
    NSMutableArray *result = [NSMutableArray array];
    for(BirthdayPerson *birthdayPerson in [self all]) {
        if([birthdayPerson daysToBirthday] <= days) {
            [result addObject:birthdayPerson];
        } else {
            break;
        }
    }
    return result;
}

- (NSArray *) all {
    NSMutableArray *result = [NSMutableArray array];
    
    // get the current date
    NSDate *todaysDate = [NSDate date];
    NSDateComponents *todaysDateComponents = [self.calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                              fromDate:todaysDate];
    
    // try to get me
    ABPerson *me = [[ABAddressBook sharedAddressBook] me];
    
    // get the persons with birthdays from the address book
    for(ABPerson *abPerson in [[ABAddressBook sharedAddressBook] people]) {
        NSDateComponents *birthdayDateComponents = [abPerson valueForProperty:kABBirthdayComponentsProperty];
        
        // only people with a birthday set
        if(birthdayDateComponents == nil) {
            continue;
        }
        
        NSString *firstName = [abPerson valueForProperty:kABFirstNameProperty];
        NSString *lastName = [abPerson valueForProperty:kABLastNameProperty];
        NSString *nickname = [abPerson valueForProperty:kABNicknameProperty];
        
        NSDate *birthdayDate = [self comparableDateForDay:[birthdayDateComponents day]
                                                    month:[birthdayDateComponents month]
                                                     year:[birthdayDateComponents day]];
        
        // compute the next birthday date
        NSInteger birthdayYear = [todaysDateComponents year];
        if([birthdayDateComponents month] < [todaysDateComponents month]) {
            birthdayYear++;
        } else if([birthdayDateComponents month] == [todaysDateComponents month] && [birthdayDateComponents day] < [todaysDateComponents day])  {
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
        
        // create the birthday person
        BirthdayPerson *birthdayPerson = [[BirthdayPerson alloc] init];
        birthdayPerson.uniqueId = [abPerson uniqueId];
        birthdayPerson.me = (me != nil && me == abPerson);
        birthdayPerson.firstName = (firstName ? firstName : @"");
        birthdayPerson.lastName = (lastName ? lastName : @"");
        birthdayPerson.nickName = (nickname ? nickname : @"");
        birthdayPerson.birthdayDate = birthdayDate;
        birthdayPerson.nextBirthdayDate = nextBirthdayDate;
        birthdayPerson.age = age;
        birthdayPerson.daysToBirthday = daysToBirthday;
        
        [result addObject:birthdayPerson];
    }
    
    // sort by next birthday ascending
    [result sortUsingComparator:^NSComparisonResult(id person1, id person2) {
        NSDate *first = [(BirthdayPerson *)person1 nextBirthdayDate];
        NSDate *second = [(BirthdayPerson *)person2 nextBirthdayDate];
        return [first compare:second];
    }];
    
    return result;
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

@end
