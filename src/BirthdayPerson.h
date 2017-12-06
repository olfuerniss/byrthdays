//
//  BirthdayPerson.h
//  byrthdays
//
//  Created by Oliver Fürniß on 29.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BirthdayPerson : NSObject

@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, assign) Boolean me;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSDate *birthdayDate;
@property (nonatomic, strong) NSDate *nextBirthdayDate;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger daysToBirthday;

- (NSImage *) image;
- (NSString *) base64EncodedThumbnailImageWithMaximumWidthOrHeight:(CGFloat)maxWidthOrHeight;

@end
