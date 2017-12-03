//
//  main.m
//  byrthdayz
//
//  Created by Oliver Fürniß on 28.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Byrthdays.h"
#import "NSMutableString+Extension.h"

void nsprintf(NSString *format, ...);
void printJSON(NSArray *byrthdays, NSDateFormatter *dateFormatter);
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
        Byrthdays *byrthdayz = [[Byrthdays alloc] initWithCalendar:calendar];

        NSArray *byrthdays;
        if(withinDays > 0) {
            byrthdays = [byrthdayz byrthdaysWithinTheNextDays:withinDays];
        } else {
            byrthdays = [byrthdayz allByrthdays];
        }

        // create the response
        if([output isEqualToString:@"json"]) {
            printJSON(byrthdays, dateFormatter);
        } else {
            printPretty(byrthdays, dateFormatter);
        }
    }
    return EXIT_SUCCESS;
}

void printJSON(NSArray *byrthdays, NSDateFormatter *dateFormatter) {
    NSMutableString *resp = [[NSMutableString alloc] init];
    [resp appendString:@"["];
    [byrthdays enumerateObjectsUsingBlock:^(Byrthday *byrthday, NSUInteger idx, BOOL *stop) {
        [resp appendString:@"{"];
        [resp appendJsonField:@"uid" stringValue:[byrthday uniqueId]];
        [resp appendString:@","];
        [resp appendJsonField:@"me" booleanValue:[byrthday me]];
        [resp appendString:@","];
        [resp appendJsonField:@"firstName" stringValue:[byrthday firstName]];
        [resp appendString:@","];
        [resp appendJsonField:@"lastName" stringValue:[byrthday lastName]];
        [resp appendString:@","];
        [resp appendJsonField:@"nickName" stringValue:[byrthday nickName]];
        [resp appendString:@","];
        [resp appendJsonField:@"birthdayDate" stringValue:[dateFormatter stringFromDate:[byrthday birthdayDate]]];
        [resp appendString:@","];
        [resp appendJsonField:@"nextBirthdayDate" stringValue:[dateFormatter stringFromDate:[byrthday nextBirthdayDate]]];
        [resp appendString:@","];
        [resp appendJsonField:@"age" integerValue:[byrthday age]];
        [resp appendString:@","];
        [resp appendJsonField:@"daysToBirthday" integerValue:[byrthday daysToBirthday]];
        [resp appendString:@"}"];
        
        if(idx+1 < [byrthdays count]) {
            [resp appendString:@","];
        }
        [resp appendString:@"\n"];
    }];
    [resp appendString:@"]"];
    nsprintf(@"%@", resp);
}

void printPretty(NSArray *byrthdays, NSDateFormatter *dateFormatter) {
    for(Byrthday *byrthday in byrthdays) {
        nsprintf(@"%@: %@ %@ will be %ld in %ld days\n", [dateFormatter stringFromDate:byrthday.nextBirthdayDate], byrthday.firstName, byrthday.lastName, byrthday.age, byrthday.daysToBirthday);
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
    "Byrthdays is a tool to extract persons with birthdays from your contacts. \n\n"
    "Usage: \n"
    "  byrthdays [-d days] [-o format] \n\n"
    "Options: \n"
    "  -d  extract only birthdays within the given number of days (default 14) \n"
    "  -o  to set the output format. Can be either 'pretty' or 'json' (default 'pretty') \n"
    "  -h  prints this help \n"
    "\n"
    "byrthdays v1.0\n"
    "Oliver Fürniß, 03/12/2017\n"
    "Website: https://github.com/olfuerniss/byrthdays\n";
    
    nsprintf(help);
}
