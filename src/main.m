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
void printJSON(NSArray *byrthdays, int thumbnailSize, NSDateFormatter *dateFormatter);
void printXML(NSArray *birthdayPeople, int thumbnailSize, NSDateFormatter *dateFormatter);
void printCSV(NSArray *birthdayPeople, int thumbnailSize, NSDateFormatter *dateFormatter);
void printPretty(NSArray *byrthdays, NSDateFormatter *dateFormatter);
void help(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // command line args processing
        int withinDays = 14;
        NSString *output = @"pretty";
        int thumbnailSize = 0;
        
        unsigned int optchar;
        while ((optchar = getopt(argc, (char * const *)argv, "h?d:o:t:")) != -1) {
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
                    
                case 't':
                    thumbnailSize = atoi(optarg);
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
            printJSON(byrthdayPeople, thumbnailSize, dateFormatter);
        } else if([output isEqualToString:@"xml"]) {
            printXML(byrthdayPeople, thumbnailSize, dateFormatter);
        } else if([output isEqualToString:@"csv"]) {
            printCSV(byrthdayPeople, thumbnailSize, dateFormatter);
        } else {
            printPretty(byrthdayPeople, dateFormatter);
        }
    }
    return EXIT_SUCCESS;
}

void printJSON(NSArray *birthdayPeople, int thumbnailSize, NSDateFormatter *dateFormatter) {
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
        if(thumbnailSize > 0) {
            [resp appendString:@","];
            [resp appendString:@"\n\t\t"];
            [resp appendJsonField:@"image" stringValue:[person base64EncodedThumbnailImageWithMaximumWidthOrHeight:thumbnailSize]];
        }
        [resp appendString:@"\n\t}"];
        
        if(idx+1 < [birthdayPeople count]) {
            [resp appendString:@","];
        }
    }];
    [resp appendString:@"\n]"];
    nsprintf(@"%@", resp);
}

void printXML(NSArray *birthdayPeople, int thumbnailSize, NSDateFormatter *dateFormatter) {
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
        if(thumbnailSize > 0) {
            [resp appendString:@"\n\t\t"];
            [resp appendXmlElement:@"image" stringValue:[person base64EncodedThumbnailImageWithMaximumWidthOrHeight:thumbnailSize]];
        }
        [resp appendString:@"\n\t</person>"];
    }];
    
    [resp appendString:@"\n</people>"];
    nsprintf(@"%@", resp);
}

void printCSV(NSArray *birthdayPeople, int thumbnailSize, NSDateFormatter *dateFormatter) {
    NSMutableString *resp = [[NSMutableString alloc] init];
    
    // header
    NSMutableArray *headerEntries = [NSMutableArray arrayWithObjects:
                                     @"uid",
                                     @"me",
                                     @"first_name",
                                     @"last_name",
                                     @"nick_name",
                                     @"birthday_date",
                                     @"next_birthday_date",
                                     @"age",
                                     @"days_to_birthday",
                                     nil];
    if(thumbnailSize > 0) {
        [headerEntries addObject:@"image"];
    }
    [headerEntries enumerateObjectsUsingBlock:^(NSString *headerEntry, NSUInteger idx, BOOL *stop) {
        [resp appendFormat:@"\"%@\"", headerEntry];
        
        if(idx < [headerEntries count]-1) {
            [resp appendString:@", "];
        }
    }];
    [resp appendString:@"\n"];
    
    // content
    [birthdayPeople enumerateObjectsUsingBlock:^(BirthdayPerson *person, NSUInteger idx, BOOL *stop) {
        [resp appendCsvStringValue:[person uniqueId]];
        [resp appendString:@", "];
        [resp appendCsvBooleanValue:[person me]];
        [resp appendString:@", "];
        [resp appendCsvStringValue:[person firstName]];
        [resp appendString:@", "];
        [resp appendCsvStringValue:[person lastName]];
        [resp appendString:@", "];
        [resp appendCsvStringValue:[person nickName]];
        [resp appendString:@", "];
        [resp appendCsvStringValue:[dateFormatter stringFromDate:[person birthdayDate]]];
        [resp appendString:@", "];
        [resp appendCsvStringValue:[dateFormatter stringFromDate:[person nextBirthdayDate]]];
        [resp appendString:@", "];
        [resp appendCsvIntegerValue:[person age]];
        [resp appendString:@", "];
        [resp appendCsvIntegerValue:[person daysToBirthday]];
        if(thumbnailSize > 0) {
            [resp appendString:@", "];
            [resp appendCsvStringValue:[person base64EncodedThumbnailImageWithMaximumWidthOrHeight:thumbnailSize]];
        }
        [resp appendString:@"\n"];
    }];
    
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
    "  byrthdays [-d <days>] [-o <pretty|json|xml|csv>] [-t <size>]\n\n"
    "Options: \n"
    "  -d  extract only birthdays within the given number of days (default 14; -1 for all) \n"
    "  -o  to set the output format. Can be either 'pretty', 'json', 'xml' or 'csv' (default 'pretty') \n"
    "  -t  to set the maximum thumbnail width/height of the contact images. It only prints the base64 encoded thumbnail data (PNG) when this option is used \n"
    "  -h  prints this help \n"
    "\n"
    "byrthdays v1.0.4 \n"
    "Oliver Fürniß, 06/12/2017 \n"
    "Website: https://github.com/olfuerniss/byrthdays \n";
    
    nsprintf(help);
}
