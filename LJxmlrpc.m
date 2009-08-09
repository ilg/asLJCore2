//
//  LJxmlrpc.m
//  asLJFramework
//
//  Created by Isaac Greenspan on 4/24/09.
//

/*** BEGIN LICENSE TEXT ***
 
 Copyright (c) 2009, Isaac Greenspan
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 *** END LICENSE TEXT ***/

#import "LJxmlrpc.h"
#import "asLJFrameworkKeychain.h"
#import <CommonCrypto/CommonDigest.h>
#import <XMLRPC.h>
#import "LJErrors.h"


@implementation LJxmlrpcRaw

static NSString *keychainItemName;
static NSString *clientVersion;

+ (void)setKeychainItemName:(NSString *)theName
{
	[keychainItemName release];
	keychainItemName = [[theName copy] retain];
}

+ (void)setClientVersion:(NSString *)theVersion
{
	[clientVersion release];
	clientVersion = [[theVersion copy] retain];
}

- (BOOL)rawCall:(NSString *)methodName
	 withParams:(NSDictionary *)paramDict
		  atURL:(NSString *)serverURL
		  error:(NSError **)anError
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	[innerError release];
	innerError = nil;
	
	// [serverURL] is something like http://www.livejournal.com/interface/xmlrpc
	NSURL *URL = [NSURL URLWithString:serverURL];
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
	XMLRPCRequest *request;
	
	// the actual XML-RPC method we want is LJ.XMLRPC.[methodName]
	// make the XML-RPC call happen
	request = [[XMLRPCRequest alloc] initWithURL:URL];
	[request setMethod:[NSString stringWithFormat:@"LJ.XMLRPC.%@",methodName] 
		 withParameter:paramDict];
	waitingForResponse = TRUE;
	[manager spawnConnectionWithXMLRPCRequest:request
									 delegate:self];
	[request release];
    while (waitingForResponse && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	if (errorHappened) {
		// something happened in the XML-RPC call--deal with it and jump out.
        if (anError != NULL) {
			if (innerError) {
				*anError = [[innerError copy] autorelease];
			} else {
				// Make and return custom domain error
				NSMutableDictionary *eDict = [NSMutableDictionary dictionaryWithCapacity:1];
				[eDict setObject:NSLocalizedString(faultString,@"") forKey:NSLocalizedDescriptionKey];
				if (innerError) {
					[eDict setObject:[[innerError copy] autorelease] forKey:NSUnderlyingErrorKey];
					[innerError release];
					innerError = nil;
				}
				*anError = [NSError errorWithDomain:asLJFramework_ErrorDomain
											   code:[faultCode integerValue]
										   userInfo:[NSDictionary dictionaryWithDictionary:eDict]];
			}
		}
		return NO;
	} else {
		//	NSLog(@"%@",self);
		//	NSLog(@"Done with call(raw), returning...");
		return YES;
	}
}

- (void)rawCall:(NSString *)methodName
	 withParams:(NSDictionary *)paramDict
		  atURL:(NSString *)serverURL
{
	[self rawCall:methodName withParams:paramDict atURL:serverURL error:NULL];
}


#pragma mark -
#pragma mark deep iterating functions

// this is a HORRIBLE kludge that sends an extra retain to everything in the whole massive datastructure
// this is also where we take the NSData objects with the UTF8 bytes and turn them into NSStrings
+ (void)loopThroughDictionary: (NSMutableDictionary *)theDictionary
{
	NSDictionary *fixedDictionary = [NSDictionary dictionaryWithDictionary:theDictionary];
	id key;
	
	for (key in fixedDictionary) {
		id theObject = [theDictionary objectForKey:key];
		[theObject retain];
		if ([theObject isKindOfClass:[NSDictionary class]]) {
			[LJxmlrpc loopThroughDictionary:theObject];
		} else if ([theObject isKindOfClass:[NSArray class]]) {
			[LJxmlrpc loopThroughArray:theObject];
		} else if ([theObject isKindOfClass:[NSData class]]) {
			[theDictionary setObject:[[[NSString alloc] initWithData:theObject encoding:NSUTF8StringEncoding] retain] forKey:key];
		}
	}
}
+ (void)loopThroughArray: (NSMutableArray *)theArray
{
	NSUInteger index;
	for (index = 0; index < [theArray count]; index++) {
		id theObject = [theArray objectAtIndex:index];
		[theObject retain];
		if ([theObject isKindOfClass:[NSDictionary class]]) {
			[LJxmlrpc loopThroughDictionary:theObject];
		} else if ([theObject isKindOfClass:[NSArray class]]) {
			[LJxmlrpc loopThroughArray:theObject];
		} else if ([theObject isKindOfClass:[NSData class]]) {
			[theArray replaceObjectAtIndex:index withObject:[[[NSString alloc] initWithData:theObject encoding:NSUTF8StringEncoding] retain]];
		}
	}
}


#pragma mark -
#pragma mark for XMLRPCConnectionDelegate Protocol

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	waitingForResponse = FALSE;
	errorHappened = FALSE;
	if ([response isFault]) {
		isFault = TRUE;
		faultCode = [response faultCode];
		faultString = [response faultString];
		
		VLOG(@"Error returned by XMLRPC call (%@): %@",faultCode,faultString);
		
		[self setObject:[NSNumber numberWithBool:TRUE] forKey:@"isFault"];
		[self setObject:faultCode forKey:@"faultCode"];
		[self setObject:faultString forKey:@"faultString"];
		
		errorHappened = TRUE;
	} else {
		//NSLog(@"Parsed response: %@", [response object]);
		
		[self setDictionary:[response object]];
		[self setObject:[NSNumber numberWithBool:FALSE] forKey:@"isFault"];
		[LJxmlrpcRaw loopThroughDictionary: self];
		
		errorHappened = FALSE;
	}
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	waitingForResponse = FALSE;
	errorHappened = TRUE;
	isError = TRUE;
	faultCode = [[NSNumber numberWithInteger:[error code]] retain];
	faultString = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
	innerError = [error retain];
	VLOG(@"Error with XMLRPC request (%@): %@",faultCode,faultString);
	
	[self setObject:[NSNumber numberWithBool:TRUE] forKey:@"isFault"];
	[self setObject:faultCode forKey:@"faultCode"];
	[self setObject:faultString forKey:@"faultString"];
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
}


#pragma mark -
#pragma mark primitive methods for NSDictionary/NSMutableDictionary subclassing

- (id)init
{
    self = [super init];
    if (self) {
        embeddedObject = [[NSMutableDictionary allocWithZone:[self zone]] init];
    }
	return self;
}

- (NSUInteger)count
{
	return [embeddedObject count];
}

- (id)objectForKey:(id)aKey
{
	return [embeddedObject objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
	return [embeddedObject keyEnumerator];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	[embeddedObject setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
	[embeddedObject removeObjectForKey:aKey];
}


#pragma mark -
#pragma mark for wrapper functions

- (NSDictionary *)getResultDictionary
{
	return embeddedObject;
}

@end

#pragma mark -

@implementation LJxmlrpc

+ (NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	if (!cStr) {
		return @"";
	} else {
		unsigned char result[CC_MD5_DIGEST_LENGTH];
		CC_MD5( cStr, strlen(cStr), result );
		return [NSString stringWithFormat:
				@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
				result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
				];
	}
} 

- (BOOL)call:(NSString *)methodName
  withParams:(NSDictionary *)paramDict
	   atURL:(NSString *)serverURL
	 forUser:(NSString *)username
	   error:(NSError **)anError
{
	VLOG(@"Calling method %@ for %@@%@...",methodName,username,serverURL);
	// [serverURL] is something like http://www.livejournal.com/interface/xmlrpc
	
	// set challenge to the 'challenge' element of the result of calling 'getchallenge', no params needed
	LJxmlrpcRaw *challengeRawCall = [[LJxmlrpcRaw alloc] init];
	if ([challengeRawCall rawCall:@"getchallenge"
					   withParams:nil
							atURL:serverURL
							error:anError]) {
		// getchallenge call succeeded
		NSString *authChallenge = [NSString stringWithString:[challengeRawCall objectForKey:@"challenge"]];
		[challengeRawCall release];
		
		// set response to md5( challenge + md5([password]) )   where md5() returns the hex digest
		NSString *serverFQDN = [[serverURL componentsSeparatedByString:@"/"] objectAtIndex:2];
		NSString *pwdMD5 = [LJxmlrpc 
							md5:[asLJFrameworkKeychain getPasswordByLabel:keychainItemName
															  withAccount:username
															   withServer:serverFQDN]];
		NSString *authResponse = [LJxmlrpc
								  md5:[NSString
									   stringWithFormat:@"%@%@",
									   authChallenge,
									   pwdMD5
									   ]
								  ];
		
		/*
		 to [paramDict], we need to add the things that every request should include:
		 'auth_method': 'challenge'
		 'auth_challenge': [challenge]
		 'auth_response': [response]
		 'username': [username]
		 'ver': 1  -- protocol version
		 'clientversion': [pull 'LJversionString' from user defaults]
		 */
		NSMutableDictionary *theParameters = [NSMutableDictionary
											  dictionaryWithObjectsAndKeys:
											  @"challenge",@"auth_method",
											  authChallenge,@"auth_challenge",
											  authResponse,@"auth_response",
											  username,@"username",
											  @"1",@"ver",
											  clientVersion,@"clientversion",
											  nil
											  ];
		[theParameters addEntriesFromDictionary:paramDict];
		
		// make the XML-RPC call happen
		if ([self rawCall:methodName
			   withParams:theParameters
					atURL:serverURL
					error:anError]) {
			// main call succeeded
			//	NSLog(@"%@",self);
			//	NSLog(@"Done with call, returning...");
			return YES;
		} else {
			// main call failed
			return NO;
		}
	} else {
		// getchallenge call failed
		[challengeRawCall release];
		return NO;
	}
}

- (void)call:(NSString *)methodName
  withParams:(NSDictionary *)paramDict
	   atURL:(NSString *)serverURL
	 forUser:(NSString *)username
{
	[self call:methodName withParams:paramDict atURL:serverURL forUser:username error:NULL];
}

@end
