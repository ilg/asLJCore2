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
//  LJxmlrpc2.m
//  asLJCore
//
//  Created by Isaac Greenspan on 6/23/12.
//

#import "LJxmlrpc2.h"
#import "asLJCoreKeychain.h"
#import "NSString+MD5.h"

@interface LJxmlrpc2 () {
@private
    BOOL cancelled;
}
@property BOOL cancelled;
@end

@implementation LJxmlrpc2

@synthesize cancelled;

static NSString *keychainItemName;
static NSString *clientVersion;

+ (void)setKeychainItemName:(NSString *)theName
{
	[keychainItemName release];
	keychainItemName = [[theName copy] retain];
}

+ (NSString *)keychainItemName
{
	return [[keychainItemName copy] autorelease];
}

+ (void)setClientVersion:(NSString *)theVersion
{
	[clientVersion release];
	clientVersion = [[theVersion copy] retain];
}

+ (NSString *)clientVersion
{
	return [[clientVersion copy] autorelease];
}

+ (NSDictionary *)rawSynchronousCallMethod:(NSString *)methodName
                            withParameters:(NSDictionary *)parameters
                                     atUrl:(NSString *)serverURL
                                   forUser:(NSString *)username
                                     error:(NSError **)error
{
	VLOG(@"Calling method %@ for %@@%@...", methodName, username, serverURL);
	// [serverURL] is something like http://www.livejournal.com/interface/xmlrpc
    
    NSString *method = [NSString stringWithFormat:@"LJ.XMLRPC.%@", methodName];
    
    WSMethodInvocationRef invocation = WSMethodInvocationCreate((CFURLRef)[NSURL URLWithString:serverURL], (CFStringRef)method, kWSXMLRPCProtocol);
    WSMethodInvocationSetParameters(invocation, (CFDictionaryRef)parameters, nil);
    
    CFDictionaryRef result = WSMethodInvocationInvoke(invocation);
    CFRelease(invocation);

    if (WSMethodResultIsFault(result)) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"asLJCore2 Error"
                                         code:[(NSNumber *)CFDictionaryGetValue(result, kWSFaultCode) integerValue]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               CFDictionaryGetValue(result, kWSFaultString), NSLocalizedDescriptionKey,
                                               nil]];
        }
        return nil;
    } else {
        return (NSDictionary *)CFDictionaryGetValue(result, kWSMethodInvocationResult);
    }
}

+ (NSDictionary *)synchronousCallMethod:(NSString *)methodName
                         withParameters:(NSDictionary *)parameters
                                  atUrl:(NSString *)serverURL
                                forUser:(NSString *)username
                                  error:(NSError **)error
{
    NSError *myError;
    DLOG(@"getting challenge...");
    
#ifdef DEBUG
    NSDate *methodStart = [NSDate date];
#endif
    
    NSDictionary *challengeResult = [self rawSynchronousCallMethod:@"getchallenge"
                                                    withParameters:nil
                                                             atUrl:serverURL
                                                           forUser:username
                                                             error:&myError];
    if (!challengeResult) {
        DLOG(@"getting challenge failed (%@).", myError);
        if (error != NULL) {
            *error = [[myError copy] autorelease];
        }
        return nil;
    }
    DLOG(@"getting challenge succeeded; calling %@...", methodName);
    NSString *authChallenge = [challengeResult objectForKey:@"challenge"];
    // set response to md5( challenge + md5([password]) )   where md5() returns the hex digest
    NSString *serverFQDN = [[serverURL componentsSeparatedByString:@"/"] objectAtIndex:2];
    NSString *pwdMD5 = [[asLJCoreKeychain getPasswordByLabel:keychainItemName
                                                 withAccount:username
                                                  withServer:serverFQDN] md5];
    NSString *authResponse = [NSString md5WithFormat:@"%@%@",
                              authChallenge, pwdMD5];
    /*
     to [parameters], we need to add the things that every request should include:
     'auth_method': 'challenge'
     'auth_challenge': [challenge]
     'auth_response': [response]
     'username': [username]
     'ver': 1  -- protocol version
     'clientversion': whatever our clientVersion has been set to
     */
    NSMutableDictionary *theParameters = [NSMutableDictionary
                                          dictionaryWithObjectsAndKeys:
                                          @"challenge", @"auth_method",
                                          authChallenge, @"auth_challenge",
                                          authResponse, @"auth_response",
                                          username, @"username",
                                          @"1", @"ver",
                                          clientVersion, @"clientversion",
                                          nil
                                          ];
    [theParameters addEntriesFromDictionary:parameters];
    NSDictionary *result = [self rawSynchronousCallMethod:methodName
                                           withParameters:[NSDictionary dictionaryWithObject:theParameters forKey:@"param"]
                                                    atUrl:serverURL
                                                  forUser:username
                                                    error:&myError];

#ifdef DEBUG
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    DLOG(@"LJxmlrpc2 calling %@ took %.2f seconds.", methodName, executionTime);
#endif

    if (!result) {
        if (error != NULL) {
            *error = [[myError copy] autorelease];
        }
        return nil;
    }
    return result;
}

- (LJxmlrpc2 *)initAsynchronousCallMethod:(NSString *)methodName
                           withParameters:(NSDictionary *)parameters
                                    atUrl:(NSString *)serverURL
                                  forUser:(NSString *)username
                                  success:(void(^)(NSDictionary *result))successBlock_
                                  failure:(void(^)(NSError *error))failureBlock_
{
    self = [super init];
    if (self) {
        [self setCancelled:NO];
        // Use GCD to run the synchronous call on a background thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *myError;
            NSDictionary *result = [[self class] synchronousCallMethod:methodName
                                                        withParameters:parameters
                                                                 atUrl:serverURL
                                                               forUser:username
                                                                 error:&myError];
            if (![self cancelled]) {
                if (result) {
                    // Use GCD to run the success block on the main thread.
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        successBlock_(result);
                    });
                } else {
                    // Use GCD to run the failure block on the main thread.
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        failureBlock_(myError);
                    });
                }
            }
        });
    }
    return self;
}

+ (LJxmlrpc2 *)asynchronousCallMethod:(NSString *)methodName
                       withParameters:(NSDictionary *)parameters
                                atUrl:(NSString *)serverURL
                              forUser:(NSString *)username
                              success:(void(^)(NSDictionary *result))successBlock_
                              failure:(void(^)(NSError *error))failureBlock_
{
    return [[[LJxmlrpc2 alloc] initAsynchronousCallMethod:methodName
                                           withParameters:parameters
                                                    atUrl:serverURL
                                                  forUser:username
                                                  success:successBlock_
                                                  failure:failureBlock_]
            autorelease];
}

- (void)cancel {
    [self setCancelled:YES];
}

@end
