//
//  NSMutableString+Extension.h
//  byrthdays
//
//  Created by Oliver Fürniß on 02.12.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Extension)

- (void) appendJsonField:(NSString *)name stringValue:(NSString *)value;
- (void) appendJsonField:(NSString *)name booleanValue:(Boolean)value;
- (void) appendJsonField:(NSString *)name integerValue:(NSInteger)value;

- (void) appendXmlElement:(NSString *)name stringValue:(NSString *)value;
- (void) appendXmlElement:(NSString *)name booleanValue:(Boolean)value;
- (void) appendXmlElement:(NSString *)name integerValue:(NSInteger)value;

- (void) appendCsvStringValue:(NSString *)value;
- (void) appendCsvBooleanValue:(Boolean)value;
- (void) appendCsvIntegerValue:(NSInteger)value;

@end
