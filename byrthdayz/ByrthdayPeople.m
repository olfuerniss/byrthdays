//
//  Byrthdays.m
//  byrthdayz
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "ByrthdayPeople.h"
#import <AddressBook/AddressBook.h>

@implementation ByrthdayPeople

- (id) initWithCalendar:(NSCalendar *)calendar {
    if (self = [super init]) {
        _calendar = calendar;
    }
    return self;
}

#pragma mark - instance methods

- (NSArray *) withinTheNextDays:(NSInteger)days {
    NSMutableArray *result = [NSMutableArray array];
    for(ByrthdayPerson *byrthdayPerson in [self all]) {
        if([byrthdayPerson daysToBirthday] <= days) {
            [result addObject:byrthdayPerson];
        } else {
            break;
        }
    }
    return result;
}

- (NSArray *) all {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:10];

    // get the current date
    NSDate *todaysDate = [NSDate date];
    NSDateComponents *todaysDateComponents = [self.calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                              fromDate:todaysDate];
    
    // try to get me
    ABPerson *me = [[ABAddressBook sharedAddressBook] me];
    
    // get the persons with birthdays from the address book
    for(ABPerson *person in [[ABAddressBook sharedAddressBook] people]) {
        NSDateComponents *birthdayDateComponents = [person valueForProperty:kABBirthdayComponentsProperty];

        // only people with a birthday set
        if(birthdayDateComponents == nil) {
            continue;
        }
        
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
        
        [result addObject:byrthdayPerson];
    }
    
    [result sortUsingComparator:^NSComparisonResult(id person1, id person2) {
        NSDate *first = [(ByrthdayPerson *)person1 nextBirthdayDate];
        NSDate *second = [(ByrthdayPerson *)person2 nextBirthdayDate];
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
