//
//  Byrthdays.m
//  byrthdayz
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "Byrthdays.h"
#import <AddressBook/AddressBook.h>

// Comparison function for sorting returned ABPeople by birthday
NSInteger CompareDates(id person1, id person2, void *context) {
    if ([person1 isMemberOfClass:[ABPerson class]] && [person2 isMemberOfClass:[ABPerson class]]) {
        NSDateComponents *birthdayPerson1 = [person1 valueForKey:kABBirthdayComponentsProperty];
        NSDateComponents *birthdayPerson2 = [person2 valueForKey:kABBirthdayComponentsProperty];
        
        // compare month
        if ([birthdayPerson1 month] < [birthdayPerson2 month]) {
            return NSOrderedAscending;
        }
        if ([birthdayPerson1 month] > [birthdayPerson2 month]) {
            return NSOrderedDescending;
        }
        
        // same month; compare the day
        if ([birthdayPerson1 day] < [birthdayPerson2 day]) {
            return NSOrderedAscending;
        }
        if ([birthdayPerson1 day] > [birthdayPerson2 day]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }
    return NSOrderedDescending;
}

// --------------------------------------------------------------------------------------------------------------

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

- (NSInteger) daysBetween:(NSDate *)fromDate andDate:(NSDate *)toDate {
    NSDateComponents *components = [self.calendar components:(NSCalendarUnitDay) fromDate:fromDate toDate:toDate options:0];
    return ABS([components day]);
}

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
    // get the persons with birthdays from the address book
    NSMutableArray *people = [NSMutableArray arrayWithCapacity:10];
    for(ABPerson *person in [[ABAddressBook sharedAddressBook] people]) {
        NSDateComponents *birthdayComponent = [person valueForProperty:kABBirthdayComponentsProperty];
        if (birthdayComponent != nil) {
            [people addObject:person];
        }
    }

    // get the current date
    NSDate *todaysDate = [NSDate date];
    NSDateComponents *todaysDateComponents = [self.calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:todaysDate];
    
    // try to get me
    ABPerson *me = [[ABAddressBook sharedAddressBook] me];
    
    // sort the given persons ascending by their birthdays
    NSArray *sortedPeople = [people sortedArrayUsingFunction:CompareDates context:NULL];
    
    // add the persons with birthdays coming next in this year, then those in the next year
    NSMutableArray *thisYearPeople = [NSMutableArray arrayWithCapacity:[sortedPeople count]];
    NSMutableArray *nextYearPeople = [NSMutableArray arrayWithCapacity:[sortedPeople count]];
    
    for(ABPerson *person in sortedPeople) {
        NSDateComponents *birthdayDateComponents = [person valueForProperty:kABBirthdayComponentsProperty];
        if(([birthdayDateComponents month] == [todaysDateComponents month] && [birthdayDateComponents day] >= [todaysDateComponents day]) || [birthdayDateComponents month] > [todaysDateComponents month]) {
            [thisYearPeople addObject:person];
        } else {
            [nextYearPeople addObject:person];
        }
    }
    
    NSMutableArray *reorderedPeople = [NSMutableArray arrayWithCapacity:[sortedPeople count]];
    [reorderedPeople addObjectsFromArray:thisYearPeople];
    [reorderedPeople addObjectsFromArray:nextYearPeople];
    
    // create the results array
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[reorderedPeople count]];
    
    for(ABPerson *person in reorderedPeople) {
        NSString *firstName = [person valueForProperty:kABFirstNameProperty];
        NSString *lastName = [person valueForProperty:kABLastNameProperty];
        NSString *nickname = [person valueForProperty:kABNicknameProperty];
        
        NSDateComponents *birthdayDateComponents = [person valueForProperty:kABBirthdayComponentsProperty];
        NSDate *birthdayDate = [self.calendar dateFromComponents:birthdayDateComponents];
        
        // computing the birthday year
        NSInteger birthdayYear = [todaysDateComponents year];
        if(([birthdayDateComponents month] == [todaysDateComponents month] && [birthdayDateComponents day] < [todaysDateComponents day]) || [birthdayDateComponents month] < [todaysDateComponents month])  {
            birthdayYear++;
        }
        
        // computing the age
        NSInteger age = 0;
        if([birthdayDateComponents year] != NSNotFound) {
            age = birthdayYear - [birthdayDateComponents year];
        }
        
        // create the next birthday date
        NSDate *nextBirthdayDate = [self comparableDateForDay:[birthdayDateComponents day]
                                                        month:[birthdayDateComponents month]
                                                         year:birthdayYear];
        
        // compute the days to next birthday
        NSInteger daysToBirthday = [self daysBetween:todaysDate
                                             andDate:nextBirthdayDate];
        
        // create the Byrthday object
        ByrthdayPerson *byrthday = [[ByrthdayPerson alloc] init];
        byrthday.me = (me != nil && me == person);
        byrthday.firstName = (firstName ? firstName : @"");
        byrthday.lastName = (lastName ? lastName : @"");
        byrthday.nickName = (nickname ? nickname : @"");
        byrthday.birthdayDate = birthdayDate;
        byrthday.nextBirthdayDate = nextBirthdayDate;
        byrthday.age = age;
        byrthday.daysToBirthday = daysToBirthday;
        byrthday.uniqueId = [person uniqueId];
        
        [results addObject:byrthday];
    }
    
    return results;
}

@end
