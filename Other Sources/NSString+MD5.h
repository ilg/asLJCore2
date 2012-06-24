//
//  NSString+MD5.h
//  Web Services XML-RPC Test
//
//  Created by Isaac Greenspan on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

- (NSString *)md5;
+ (NSString *)md5WithFormat:(NSString *)format, ...;

@end
