//
//  NSMutableString+Extension.m
//  byrthdays
//
//  Created by Oliver Fürniß on 02.12.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "NSMutableString+Extension.h"

@implementation NSMutableString (Extension)

#pragma mark - JSON

- (void) appendPrefix:(NSString *)prefix jsonField:(NSString *)name stringValue:(NSString *)value postfix:(NSString *)postfix {
    if(value != nil) {
        [self _appendPrefix:prefix value:[NSString stringWithFormat:@"\"%@\": \"%@\"", name, [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]] postfix:postfix];
    }
}

- (void) appendPrefix:(NSString *)prefix jsonField:(NSString *)name booleanValue:(Boolean)value postfix:(NSString *)postfix {
    [self _appendPrefix:prefix value:[NSString stringWithFormat:@"\"%@\": %@", name, value ? @"true" : @"false"] postfix:postfix];
}

- (void) appendPrefix:(NSString *)prefix jsonField:(NSString *)name integerValue:(NSInteger)value postfix:(NSString *)postfix {
    [self _appendPrefix:prefix value:[NSString stringWithFormat:@"\"%@\": %ld", name, value] postfix:postfix];
}

#pragma mark - XML

- (void) appendPrefix:(NSString *)prefix xmlElement:(NSString *)name stringValue:(NSString *)value {
    if(value != nil) {
        NSString *encodedValue = [[[[[value stringByReplacingOccurrencesOfString:@"&" withString: @"&amp;"]
                                     stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"]
                                    stringByReplacingOccurrencesOfString: @"'" withString: @"&apos;"]
                                   stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
        
        [self _appendPrefix:prefix value:[NSString stringWithFormat:@"<%@>%@</%@>", name, encodedValue, name] postfix:nil];
    }
}

- (void) appendPrefix:(NSString *)prefix xmlElement:(NSString *)name booleanValue:(Boolean)value {
    [self _appendPrefix:prefix value:[NSString stringWithFormat:@"<%@>%@</%@>", name, value ? @"true" : @"false", name] postfix:nil];
}

- (void) appendPrefix:(NSString *)prefix xmlElement:(NSString *)name integerValue:(NSInteger)value {
    [self _appendPrefix:prefix value:[NSString stringWithFormat:@"<%@>%ld</%@>", name, value, name] postfix:nil];
}

#pragma mark - CSV

- (void) appendCsvStringValue:(NSString *)value postfix:(NSString *)postfix {
    if(value != nil) {
        [self _appendPrefix:nil value:[NSString stringWithFormat:@"\"%@\"", [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]] postfix:postfix];
    }
}

- (void) appendCsvBooleanValue:(Boolean)value postfix:(NSString *)postfix {
    [self _appendPrefix:nil value:[NSString stringWithFormat:@"%@", value ? @"true" : @"false"] postfix:postfix];
}

- (void) appendCsvIntegerValue:(NSInteger)value postfix:(NSString *)postfix {
    [self _appendPrefix:nil value:[NSString stringWithFormat:@"%ld", value] postfix:postfix];
}

#pragma mark - helper methods

- (void) _appendPrefix:(NSString *)prefix value:(NSString *)value postfix:(NSString *)postfix {
    if(prefix != nil) {
        [self appendString:prefix];
    }
    
    [self appendString:value];
    
    if(postfix != nil) {
        [self appendString:postfix];
    }
}

@end
