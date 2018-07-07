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
void printJSON(NSArray *byrthdays, int thumbnailSize, bool grayscaleThumbnail, NSDateFormatter *dateFormatter);
void printXML(NSArray *birthdayPeople, int thumbnailSize, bool grayscaleThumbnail, NSDateFormatter *dateFormatter);
void printCSV(NSArray *birthdayPeople, int thumbnailSize, bool grayscaleThumbnail, NSDateFormatter *dateFormatter);
void printPretty(NSArray *byrthdays, NSDateFormatter *dateFormatter);
void help(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // command line args processing
        int withinDays = 14;
        NSString *output = @"pretty";
        int thumbnailSize = 0;
        bool grayscaleThumbnail = false;
        
        unsigned int optchar;
        while ((optchar = getopt(argc, (char * const *)argv, "h?d:o:t:g")) != -1) {
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
                    
                case 'g':
                    grayscaleThumbnail = true;
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
            printJSON(byrthdayPeople, thumbnailSize, grayscaleThumbnail, dateFormatter);
        } else if([output isEqualToString:@"xml"]) {
            printXML(byrthdayPeople, thumbnailSize, grayscaleThumbnail, dateFormatter);
        } else if([output isEqualToString:@"csv"]) {
            printCSV(byrthdayPeople, thumbnailSize, grayscaleThumbnail, dateFormatter);
        } else {
            printPretty(byrthdayPeople, dateFormatter);
        }
    }
    return EXIT_SUCCESS;
}

void printJSON(NSArray *birthdayPeople, int thumbnailSize, bool grayscaleThumbnail, NSDateFormatter *dateFormatter) {
    NSMutableString *resp = [[NSMutableString alloc] init];
    [resp appendString:@"["];
    [birthdayPeople enumerateObjectsUsingBlock:^(BirthdayPerson *person, NSUInteger idx, BOOL *stop) {
        NSString *base64EncodedThumbnailImage = (thumbnailSize <= 0) ? nil : [person base64EncodedThumbnailImageWithMaximumWidthOrHeight:thumbnailSize grayscale:grayscaleThumbnail];
        
        [resp appendString:@"\n\t{"];
        [resp appendPrefix:@"\n\t\t" jsonField:@"uid" stringValue:[person uniqueId] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"me" booleanValue:[person me] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"firstName" stringValue:[person firstName] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"lastName" stringValue:[person lastName] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"nickName" stringValue:[person nickName] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"birthdayDate" stringValue:[dateFormatter stringFromDate:[person birthdayDate]] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"nextBirthdayDate" stringValue:[dateFormatter stringFromDate:[person nextBirthdayDate]] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"age" integerValue:[person age] postfix:@","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"daysToBirthday" integerValue:[person daysToBirthday] postfix:(thumbnailSize <= 0) ? nil : @","];
        [resp appendPrefix:@"\n\t\t" jsonField:@"image" stringValue:((thumbnailSize <= 0) ? nil : (base64EncodedThumbnailImage == nil) ? @"" : base64EncodedThumbnailImage) postfix:nil];
        [resp appendString:@"\n\t}"];
        
        if(idx+1 < [birthdayPeople count]) {
            [resp appendString:@","];
        }
    }];
    [resp appendString:@"\n]"];
    nsprintf(@"%@", resp);
}

void printXML(NSArray *birthdayPeople, int thumbnailSize, bool grayscaleThumbnail, NSDateFormatter *dateFormatter) {
    NSMutableString *resp = [[NSMutableString alloc] init];
    [resp appendString:@"<?xml version=\"1.0\"?>"];
    [resp appendString:@"\n<people>"];
    
    [birthdayPeople enumerateObjectsUsingBlock:^(BirthdayPerson *person, NSUInteger idx, BOOL *stop) {
        NSString *base64EncodedThumbnailImage = (thumbnailSize <= 0) ? nil : [person base64EncodedThumbnailImageWithMaximumWidthOrHeight:thumbnailSize grayscale:grayscaleThumbnail];

        [resp appendString:@"\n\t<person>"];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"uid" stringValue:[person uniqueId]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"me" booleanValue:[person me]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"first_name" stringValue:[person firstName]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"last_name" stringValue:[person lastName]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"nick_name" stringValue:[person nickName]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"birthday_date" stringValue:[dateFormatter stringFromDate:[person birthdayDate]]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"next_birthday_date" stringValue:[dateFormatter stringFromDate:[person nextBirthdayDate]]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"age" integerValue:[person age]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"days_to_birthday" integerValue:[person daysToBirthday]];
        [resp appendPrefix:@"\n\t\t" xmlElement:@"image" stringValue:base64EncodedThumbnailImage];
        [resp appendString:@"\n\t</person>"];
    }];
    
    [resp appendString:@"\n</people>"];
    nsprintf(@"%@", resp);
}

void printCSV(NSArray *birthdayPeople, int thumbnailSize, bool grayscaleThumbnail, NSDateFormatter *dateFormatter) {
    NSMutableString *resp = [[NSMutableString alloc] init];
    
    // header
    [resp appendCsvStringValue:@"uid" postfix:@", "];
    [resp appendCsvStringValue:@"me" postfix:@", "];
    [resp appendCsvStringValue:@"first_name" postfix:@", "];
    [resp appendCsvStringValue:@"last_name" postfix:@", "];
    [resp appendCsvStringValue:@"nick_name" postfix:@", "];
    [resp appendCsvStringValue:@"birthday_date" postfix:@", "];
    [resp appendCsvStringValue:@"next_birthday_date" postfix:@", "];
    [resp appendCsvStringValue:@"age" postfix:@", "];
    [resp appendCsvStringValue:@"days_to_birthday" postfix:(thumbnailSize <= 0) ? @"\n" : @", "];
    [resp appendCsvStringValue:(thumbnailSize <= 0) ? nil : @"image" postfix:@"\n"];
    
    // content
    [birthdayPeople enumerateObjectsUsingBlock:^(BirthdayPerson *person, NSUInteger idx, BOOL *stop) {
        NSString *base64EncodedThumbnailImage = (thumbnailSize <= 0) ? nil : [person base64EncodedThumbnailImageWithMaximumWidthOrHeight:thumbnailSize grayscale:grayscaleThumbnail];

        [resp appendCsvStringValue:[person uniqueId] postfix:@", "];
        [resp appendCsvBooleanValue:[person me] postfix:@", "];
        [resp appendCsvStringValue:[person firstName] postfix:@", "];
        [resp appendCsvStringValue:[person lastName] postfix:@", "];
        [resp appendCsvStringValue:[person nickName] postfix:@", "];
        [resp appendCsvStringValue:[dateFormatter stringFromDate:[person birthdayDate]] postfix:@", "];
        [resp appendCsvStringValue:[dateFormatter stringFromDate:[person nextBirthdayDate]] postfix:@", "];
        [resp appendCsvIntegerValue:[person age] postfix:@", "];
        [resp appendCsvIntegerValue:[person daysToBirthday] postfix:(thumbnailSize <= 0) ? @"\n" : @", "];
        [resp appendCsvStringValue:((thumbnailSize <= 0) ? nil : (base64EncodedThumbnailImage == nil) ? @"" : base64EncodedThumbnailImage) postfix:@"\n"];
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
    "  byrthdays [-d <days>] [-o <pretty|json|xml|csv>] [-t <size>] [-g] \n\n"
    "Options: \n"
    "  -d  extract only birthdays within the given number of days (default 14; -1 for all) \n"
    "  -o  to set the output format. Can be either 'pretty', 'json', 'xml' or 'csv' (default 'pretty') \n"
    "  -t  to set the maximum thumbnail width/height of the contact images. It only prints the base64 encoded thumbnail data (PNG) when this option is used \n"
    "  -g  to create grayscale thumbnails. Only in combination with '-t' \n"
    "  -h  prints this help \n"
    "\n"
    "byrthdays v1.0.8 \n"
    "Oliver Fürniß, 07/07/2018 \n"
    "Website: https://github.com/olfuerniss/byrthdays \n";
    
    nsprintf(help);
}
