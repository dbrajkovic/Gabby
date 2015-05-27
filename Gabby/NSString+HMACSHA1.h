//
//  NSString+HMACSHA1.h
//  Gabby
//
//  Created by Dan Brajkovic on 5/25/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HMACSHA1)

- (NSString *)signatureUsingHmacSHA1WithKey:(NSString *)key;

@end
