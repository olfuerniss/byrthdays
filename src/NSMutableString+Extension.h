//
//  NSMutableString+Extension.h
//  byrthdays
//
//  Created by Oliver Fürniß on 02.12.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Extension)

- (void) appendPrefix:(NSString *)prefix jsonField:(NSString *)name stringValue:(NSString *)value postfix:(NSString *)postfix;
- (void) appendPrefix:(NSString *)prefix jsonField:(NSString *)name booleanValue:(Boolean)value postfix:(NSString *)postfix;
- (void) appendPrefix:(NSString *)prefix jsonField:(NSString *)name integerValue:(NSInteger)value postfix:(NSString *)postfix;

- (void) appendPrefix:(NSString *)prefix xmlElement:(NSString *)name stringValue:(NSString *)value;
- (void) appendPrefix:(NSString *)prefix xmlElement:(NSString *)name booleanValue:(Boolean)value;
- (void) appendPrefix:(NSString *)prefix xmlElement:(NSString *)name integerValue:(NSInteger)value;

- (void) appendCsvStringValue:(NSString *)value postfix:(NSString *)postfix;
- (void) appendCsvBooleanValue:(Boolean)value postfix:(NSString *)postfix;
- (void) appendCsvIntegerValue:(NSInteger)value postfix:(NSString *)postfix;

@end
