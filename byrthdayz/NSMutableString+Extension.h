//
//  NSMutableString+Extension.h
//  byrthdayz
//
//  Created by Oliver Fürniß on 02.12.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Extension)

- (void) appendJsonField:(NSString *)name stringValue:(NSString *)value;
- (void) appendJsonField:(NSString *)name booleanValue:(Boolean)value;
- (void) appendJsonField:(NSString *)name integerValue:(NSInteger)value;

@end
