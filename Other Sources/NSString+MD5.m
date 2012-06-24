//
//  NSString+MD5.m
//  Web Services XML-RPC Test
//
//  Created by Isaac Greenspan on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    if (!cStr) {
        return @"";
    } else {
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( cStr, (unsigned int)strlen(cStr), result );
        return [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
                ];
    }
}

+ (NSString *)md5WithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSString *result = [formattedString md5];
    [formattedString release];
    return result;
}

@end
