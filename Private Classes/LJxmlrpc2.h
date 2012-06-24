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
//  LJxmlrpc2.h
//  asLJCore
//
//  Created by Isaac Greenspan on 6/23/12.
//

#import <Foundation/Foundation.h>

@interface LJxmlrpc2 : NSObject

// set the name under which account keychain items are stored
+ (void)setKeychainItemName:(NSString *)theName;

+ (NSString *)keychainItemName;

// set the version string reported to the LJ-type site
+ (void)setClientVersion:(NSString *)theVersion;

+ (NSString *)clientVersion;


// The actual methods to make the XML-RPC calls
+ (NSDictionary *)synchronousCallMethod:(NSString *)methodName
                         withParameters:(NSDictionary *)parameters
                                  atUrl:(NSString *)serverURL
                                forUser:(NSString *)username
                                  error:(NSError **)error;

+ (LJxmlrpc2 *)asynchronousCallMethod:(NSString *)methodName
                       withParameters:(NSDictionary *)parameters
                                atUrl:(NSString *)serverURL
                              forUser:(NSString *)username
                              success:(void(^)(NSDictionary *result))successBlock_
                              failure:(void(^)(NSError *error))failureBlock_;

// Cancel a call in progress
- (void)cancel;

@end
