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

- (void) appendJsonField:(NSString *)name stringValue:(NSString *)value {
    [self appendFormat:@"\"%@\": \"%@\"", name, [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
}

- (void) appendJsonField:(NSString *)name booleanValue:(Boolean)value {
    [self appendFormat:@"\"%@\": %@", name, value ? @"true" : @"false"];
}

- (void) appendJsonField:(NSString *)name integerValue:(NSInteger)value {
    [self appendFormat:@"\"%@\": %ld", name, value];
}

#pragma mark - XML

- (void) appendXmlElement:(NSString *)name stringValue:(NSString *)value {
    NSString *encodedValue = [[[[[value stringByReplacingOccurrencesOfString:@"&" withString: @"&amp;"]
                                 stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"]
                                stringByReplacingOccurrencesOfString: @"'" withString: @"&apos;"]
                               stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"]
                              stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
    
    [self appendFormat:@"<%@>%@</%@>", name, encodedValue, name];
}

- (void) appendXmlElement:(NSString *)name booleanValue:(Boolean)value {
    [self appendFormat:@"<%@>%@</%@>", name, value ? @"true" : @"false", name];
}

- (void) appendXmlElement:(NSString *)name integerValue:(NSInteger)value {
    [self appendFormat:@"<%@>%ld</%@>", name, value, name];
}

@end
