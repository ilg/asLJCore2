/*********************************************************************************
 
 © Copyright 2009-2012, Isaac Greenspan
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 *********************************************************************************/

//
//  LJaccount.m
//  asLJCore
//
//  Created by Isaac Greenspan on 6/23/12.
//

#import "LJaccount.h"

@interface LJaccount ()
@property (retain) NSString *username;
@property (retain) NSString *server;
@end

@implementation LJaccount

@synthesize username = _username;
@synthesize server = _server;

- (LJaccount *)initFromString:(NSString *)accountString {
    self = [super init];
    if (self) {
        NSArray *parts = [accountString componentsSeparatedByString:@"@"];
        if ([parts count] == 2) {
            [self setUsername:[parts objectAtIndex:0]];
            [self setServer:[parts objectAtIndex:1]];
        } else {
            self = nil;
        }
    }
    return self;
}

- (LJaccount *)initWithUsername:(NSString *)username
                       atServer:(NSString *)server
{
    self = [super init];
    if (self) {
        [self setUsername:username];
        [self setServer:server];
    }
    return self;
}


+ (LJaccount *)accountFromString:(NSString *)accountString {
    return [[[self alloc] initFromString:accountString] autorelease];
}

+ (LJaccount *)accountWithUsername:(NSString *)username
                          atServer:(NSString *)server
{
    return [[[self alloc] initWithUsername:username
                                  atServer:server]
            autorelease];
}

@end
