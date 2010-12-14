/*********************************************************************************
 
 © Copyright 2009-2010, Isaac Greenspan
 
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
//  LJxmlrpc.h
//  asLJCore
//
//  Created by Isaac Greenspan on 4/24/09.
//

#import <Cocoa/Cocoa.h>
#import <XMLRPC.h>

@interface LJxmlrpcRaw : NSMutableDictionary {
	bool isFault;
	NSString *faultString;
	NSNumber *faultCode;
	
	NSMutableDictionary *embeddedObject;
}

+ (id)cleanseUTF8:(id)theObject;

// set the name under which account keychain items are stored
+ (void)setKeychainItemName:(NSString *)theName;

+ (NSString *)keychainItemName;

// set the version string reported to the LJ-type site
+ (void)setClientVersion:(NSString *)theVersion;

+ (NSString *)clientVersion;


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

+ (LJxmlrpc *)newCall:(NSString *)methodName
		   withParams:(NSDictionary *)paramDict
				atURL:(NSString *)serverURL
			  forUser:(NSString *)username
				error:(NSError **)anError;

+ (NSString *)md5:(NSString *)str;

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
