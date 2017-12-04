//
//  main.m
//  byrthdays
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BirthdayPeople.h"
#import "NSMutableString+Extension.h"

void nsprintf(NSString *format, ...);
void printJSON(NSArray *byrthdays, NSDateFormatter *dateFormatter);
void printXML(NSArray *birthdayPeople, NSDateFormatter *dateFormatter);
void printPretty(NSArray *byrthdays, NSDateFormatter *dateFormatter);
void help(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // command line args processing
        int withinDays = 14;
        NSString *output = @"pretty";
        
        unsigned int optchar;
        while ((optchar = getopt(argc, (char * const *)argv, "h?d:o:")) != -1) {
            switch (optchar) {
                case '?':
                case 'h':
                    help();
                    return EXIT_SUCCESS;
                    
                case 'd':
                    withinDays = atoi(optarg);
                    break;
                    
                case 'o':
                    output = [[NSString alloc] initWithCString:optarg encoding:NSUTF8StringEncoding];
                    break;
                    
                default:
                    help();
                    return EXIT_FAILURE;
            }
        }
        
        // using the gregorian calendar
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        // date formatter to use
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        // extract the byrthdays from the contacts
        NSArray *byrthdayPeople;
        if(withinDays < 0) {
            byrthdayPeople = [[[BirthdayPeople alloc] initWithCalendar:calendar] all];
        } else {
            byrthdayPeople = [[[BirthdayPeople alloc] initWithCalendar:calendar] withinTheNextDays:withinDays];
        }
        
        // print the response in the requested output format
        if([output isEqualToString:@"json"]) {
            printJSON(byrthdayPeople, dateFormatter);
        } else if([output isEqualToString:@"xml"]) {
            printXML(byrthdayPeople, dateFormatter);
        } else {
            printPretty(byrthdayPeople, dateFormatter);
        }
    }
    return EXIT_SUCCESS;
}

void printJSON(NSArray *birthdayPeople, NSDateFormatter *dateFormatter) {
    NSMutableString *resp = [[NSMutableString alloc] init];
    [resp appendString:@"["];
    [birthdayPeople enumerateObjectsUsingBlock:^(BirthdayPerson *person, NSUInteger idx, BOOL *stop) {
        [resp appendString:@"\n\t{"];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"uid" stringValue:[person uniqueId]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"me" booleanValue:[person me]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"firstName" stringValue:[person firstName]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"lastName" stringValue:[person lastName]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"nickName" stringValue:[person nickName]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"birthdayDate" stringValue:[dateFormatter stringFromDate:[person birthdayDate]]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"nextBirthdayDate" stringValue:[dateFormatter stringFromDate:[person nextBirthdayDate]]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"age" integerValue:[person age]];
        [resp appendString:@","];
        [resp appendString:@"\n\t\t"];
        [resp appendJsonField:@"daysToBirthday" integerValue:[person daysToBirthday]];
        [resp appendString:@"\n\t}"];
        
        if(idx+1 < [birthdayPeople count]) {
            [resp appendString:@","];
        }
    }];
    [resp appendString:@"\n]"];
    nsprintf(@"%@", resp);
}

void printXML(NSArray *birthdayPeople, NSDateFormatter *dateFormatter) {
    NSMutableString *resp = [[NSMutableString alloc] init];
    [resp appendString:@"<?xml version=\"1.0\"?>"];
    [resp appendString:@"\n<people>"];
    
    [birthdayPeople enumerateObjectsUsingBlock:^(BirthdayPerson *person, NSUInteger idx, BOOL *stop) {
        [resp appendString:@"\n\t<person>"];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"uid" stringValue:[person uniqueId]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"me" booleanValue:[person me]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"first_name" stringValue:[person firstName]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"last_name" stringValue:[person lastName]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"nick_name" stringValue:[person nickName]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"birthday_date" stringValue:[dateFormatter stringFromDate:[person birthdayDate]]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"next_birthday_date" stringValue:[dateFormatter stringFromDate:[person nextBirthdayDate]]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"age" integerValue:[person age]];
        [resp appendString:@"\n\t\t"];
        [resp appendXmlElement:@"days_to_birthday" integerValue:[person daysToBirthday]];
        [resp appendString:@"\n\t</person>"];
    }];
    
    [resp appendString:@"\n</people>"];
    nsprintf(@"%@", resp);
}

void printPretty(NSArray *birthdayPeople, NSDateFormatter *dateFormatter) {
    for(BirthdayPerson *person in birthdayPeople) {
        if(person.daysToBirthday == 0) {
            nsprintf(@"%@: %@ %@ will be %ld today \n", [dateFormatter stringFromDate:person.nextBirthdayDate], person.firstName, person.lastName, person.age);
        } else if(person.daysToBirthday == 1) {
            nsprintf(@"%@: %@ %@ will be %ld tomorrow \n", [dateFormatter stringFromDate:person.nextBirthdayDate], person.firstName, person.lastName, person.age);
        } else {
            nsprintf(@"%@: %@ %@ will be %ld in %ld days \n", [dateFormatter stringFromDate:person.nextBirthdayDate], person.firstName, person.lastName, person.age, person.daysToBirthday);
        }
    }
}

void nsprintf(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [[NSFileHandle fileHandleWithStandardOutput] writeData:[formattedString dataUsingEncoding:NSUTF8StringEncoding]];
}

void help() {
    NSString *help = @"\n"
    "Byrthdays is a tool to list people with birthdays from your macOS contacts. \n\n"
    "Usage: \n"
    "  byrthdays [-d <days>] [-o <pretty|json|xml>] \n\n"
    "Options: \n"
    "  -d  extract only birthdays within the given number of days (default 14; -1 for all) \n"
    "  -o  to set the output format. Can be either 'pretty', 'json' or 'xml' (default 'pretty') \n"
    "  -h  prints this help \n"
    "\n"
    "byrthdays v1.0.2 \n"
    "Oliver Fürniß, 04/12/2017 \n"
    "Website: https://github.com/olfuerniss/byrthdays \n";
    
    nsprintf(help);
}
