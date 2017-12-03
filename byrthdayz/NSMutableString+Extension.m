//
//  NSMutableString+Extension.m
//  byrthdayz
//
//  Created by Oliver Fürniß on 02.12.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "NSMutableString+Extension.h"

@implementation NSMutableString (Extension)

- (void) appendJsonField:(NSString *)name stringValue:(NSString *)value {
    [self appendFormat:@"\"%@\":\"%@\"", name, value];
}

- (void) appendJsonField:(NSString *)name booleanValue:(Boolean)value {
    [self appendFormat:@"\"%@\":%@", name, value ? @"true" : @"false"];
}

- (void) appendJsonField:(NSString *)name integerValue:(NSInteger)value {
   [self appendFormat:@"\"%@\":%ld", name, value];
}

@end
