//
//  LJxmlrpc.h
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

#import <Cocoa/Cocoa.h>
#import <XMLRPC.h>

@interface LJxmlrpcRaw : NSMutableDictionary <XMLRPCConnectionDelegate> {
	bool waitingForResponse;
	bool errorHappened;
	bool isError;
	bool isFault;
	NSString *faultString;
	NSNumber *faultCode;
	NSError *innerError;
	
	NSMutableDictionary *embeddedObject;
}

// set the name under which account keychain items are stored
+ (void)setKeychainItemName:(NSString *)theName;

// set the version string reported to the LJ-type site
+ (void)setClientVersion:(NSString *)theVersion;


// the workhorse
- (void)rawCall:(NSString *)methodName
	 withParams:(NSDictionary *)paramDict
		  atURL:(NSString *)serverURL;

// primitive methods for NSDictionary/NSMutableDictionary subclassing
- (id)init;
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;

// to allow wrapper functions more easily
- (NSDictionary *)getResultDictionary;

@end

@interface LJxmlrpc : LJxmlrpcRaw {
}

- (BOOL)call:(NSString *)methodName
  withParams:(NSDictionary *)paramDict
	   atURL:(NSString *)serverURL
	 forUser:(NSString *)username
	   error:(NSError **)anError;
- (void)call:(NSString *)methodName
  withParams:(NSDictionary *)paramDict
	   atURL:(NSString *)serverURL
	 forUser:(NSString *)username;

@end
