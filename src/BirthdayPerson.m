//
//  BirthdayPerson.m
//  byrthdays
//
//  Created by Oliver Fürniß on 29.11.17.
//  Copyright © 2017 Oliver Fürniß. All rights reserved.
//

#import "BirthdayPerson.h"
#import <AddressBook/AddressBook.h>

@implementation BirthdayPerson

- (NSImage *) image {
    ABRecord *abRecord = [[ABAddressBook sharedAddressBook] recordForUniqueId:[self uniqueId]];
    if([abRecord isMemberOfClass:[ABPerson class]]) {
        NSData *imageData = [(ABPerson *)abRecord imageData];
        if(imageData != nil) {
            return [[NSImage alloc] initWithData:imageData];
        }
    }
    return nil;
}

- (NSString *) base64EncodedThumbnailImageWithMaximumWidthOrHeight:(CGFloat)maxWidthOrHeight grayscale:(bool)grayscale {
    NSImage *originalImage = [self image];
    if(originalImage != nil) {
        // compute the thumbnail size
        NSSize imageSize = [originalImage size];
        CGFloat imageAspectRatio = imageSize.width / imageSize.height;
        NSSize thumbnailSize;
        if(imageSize.width > imageSize.height) {
            thumbnailSize = NSMakeSize(maxWidthOrHeight, maxWidthOrHeight * imageAspectRatio);
        } else {
            thumbnailSize = NSMakeSize(maxWidthOrHeight * imageAspectRatio, maxWidthOrHeight);
        }
        
        // create the thumbnail
        NSBitmapImageRep *thumbnailRep;
        if(grayscale) {
            thumbnailRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                   pixelsWide:thumbnailSize.width
                                                                   pixelsHigh:thumbnailSize.height
                                                                bitsPerSample:8
                                                              samplesPerPixel:1
                                                                     hasAlpha:NO
                                                                     isPlanar:NO
                                                               colorSpaceName:NSCalibratedWhiteColorSpace
                                                                  bytesPerRow:0
                                                                 bitsPerPixel:8];
        } else {
            thumbnailRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                   pixelsWide:thumbnailSize.width
                                                                   pixelsHigh:thumbnailSize.height
                                                                bitsPerSample:8
                                                              samplesPerPixel:4
                                                                     hasAlpha:YES
                                                                     isPlanar:NO
                                                               colorSpaceName:NSCalibratedRGBColorSpace
                                                                  bytesPerRow:0
                                                                 bitsPerPixel:0];
        }
        
        
        [thumbnailRep setSize:thumbnailSize];
        
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:thumbnailRep]];
        
        [originalImage drawInRect:NSMakeRect(0, 0, thumbnailSize.width, thumbnailSize.height)
                         fromRect:NSZeroRect
                        operation:NSCompositeCopy /* NSCompositeSourceOver */
                         fraction:1.0];
        
        [NSGraphicsContext restoreGraphicsState];
        
        // get the png data
        NSData *thumbnailPngData = [thumbnailRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        
        // return the thumbnail png data as a base64 encoded string
        return [thumbnailPngData base64EncodedStringWithOptions:0];
    }
    return nil;
}

@end
