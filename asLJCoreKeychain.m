//
//  asLJCoreKeychain.m
//  asLJCore
//
//  Created by Isaac Greenspan on 1/22/09.
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

#import "asLJCoreKeychain.h"

@implementation asLJCoreKeychain

+ (NSArray *)getKeysByLabel:(NSString *)theLabel
{
	NSMutableArray *theResults = [NSMutableArray arrayWithCapacity:1];
	
	// construct the search attribute list
 	struct SecKeychainAttribute searchAttrs[] = {
 		{
 			.tag    = kSecLabelItemAttr,
 			.length = [theLabel length],
 			.data   = (void *)[theLabel UTF8String],
 		}
 	};
 	struct SecKeychainAttributeList searchAttrList = {
 		.count = 1,
 		.attr  = searchAttrs,
 	};	
	
	OSStatus status;
	SecKeychainSearchRef searchRef = nil;
	status = SecKeychainSearchCreateFromAttributes(NULL,	// default keychain
												   kSecInternetPasswordItemClass, // internet key
												   &searchAttrList, // attribute list constructed above
												   &searchRef);  // the returned search reference
	
	if (status == noErr) {
		SecKeychainItemRef itemRef = nil;
		OSStatus err;
		NSString *account, *server;
		while (SecKeychainSearchCopyNext(searchRef, &itemRef) == noErr ) {
			//Output storage.
			struct SecKeychainAttributeList *attrList = NULL;
			UInt32 passwordLength = 0U;
			void  *passwordBytes = NULL;
			
			//First, grab the username.
			UInt32    tags[] = { kSecAccountItemAttr, kSecServerItemAttr };
			UInt32 formats[] = { CSSM_DB_ATTRIBUTE_FORMAT_STRING, CSSM_DB_ATTRIBUTE_FORMAT_STRING };
			struct SecKeychainAttributeInfo info = {
				.count  = 2,
				.tag    = tags,
				.format = formats,
			};
			err = SecKeychainItemCopyAttributesAndData(itemRef,
													   &info,
													   /*itemClass*/ NULL,
													   &attrList,
													   &passwordLength,
													   &passwordBytes);
			if (err == noErr) {
				account = [[NSString alloc] initWithBytes:attrList->attr[0].data
												   length:attrList->attr[0].length
												 encoding:NSUTF8StringEncoding];
				server = [[NSString alloc] initWithBytes:attrList->attr[1].data
												  length:attrList->attr[1].length
												encoding:NSUTF8StringEncoding];
				[theResults addObject:[NSString stringWithFormat:@"%@@%@",account,server]];
				[account release];
				[server release];
			} else {
//				NSLog(@"Error extracting infomation from keychain item");
			}
			
			SecKeychainItemFreeAttributesAndData(attrList, passwordBytes);
			if (itemRef) CFRelease(itemRef);
		}
	}
	if (searchRef) CFRelease(searchRef);
	return [NSArray arrayWithArray:theResults];
}

+ (SecKeychainItemRef)getKeychainRefByLabel:(NSString *)theLabel
								withAccount:(NSString *)theAccount
								 withServer:(NSString *)theServer
{
	SecKeychainItemRef theResult = nil;
	// construct the search attribute list
 	struct SecKeychainAttribute searchAttrs[] = {
 		{
 			.tag    = kSecLabelItemAttr,
 			.length = [theLabel length],
 			.data   = (void *)[theLabel UTF8String],
 		},
 		{
 			.tag    = kSecServerItemAttr,
 			.length = [theServer length],
 			.data   = (void *)[theServer UTF8String],
 		},
 		{
 			.tag    = kSecAccountItemAttr,
 			.length = [theAccount length],
 			.data   = (void *)[theAccount UTF8String],
 		}
 	};
 	struct SecKeychainAttributeList searchAttrList = {
 		.count = 3,
 		.attr  = searchAttrs,
 	};	
	
	OSStatus status;
	SecKeychainSearchRef searchRef = nil;
	status = SecKeychainSearchCreateFromAttributes(NULL,	// default keychain
												   kSecInternetPasswordItemClass, // internet key
												   &searchAttrList, // attribute list constructed above
												   &searchRef);  // the returned search reference
	
	if (status == noErr) {
		status = SecKeychainSearchCopyNext(searchRef, &theResult);
		if (status == noErr) {
			//success
		} else {
			theResult = nil;
		}
	}
	if (searchRef) CFRelease(searchRef);
	return theResult;
}

+ (NSString *)getPasswordByLabel:(NSString *)theLabel
					 withAccount:(NSString *)theAccount
					  withServer:(NSString *)theServer
{
	NSString *theResult = nil;
	SecKeychainItemRef itemRef = [self getKeychainRefByLabel:theLabel
												 withAccount:theAccount
												  withServer:theServer];
	if (itemRef != nil) {
		OSStatus status;
		//Output storage.
		struct SecKeychainAttributeList *attrList = NULL;
		UInt32 passwordLength = 0U;
		void  *passwordBytes = NULL;
		
		//First, grab the username.
		UInt32    tags[] = {  };
		UInt32 formats[] = {  };
		struct SecKeychainAttributeInfo info = {
			.count  = 0,
			.tag    = tags,
			.format = formats,
		};
		status = SecKeychainItemCopyAttributesAndData(itemRef,
													  &info,
													  /*itemClass*/ NULL,
													  &attrList,
													  &passwordLength,
													  &passwordBytes);
		if (status == noErr) {
			theResult = [[[NSString alloc] initWithBytes:passwordBytes
												  length:passwordLength
												encoding:NSUTF8StringEncoding]
						 autorelease];
		} else {
			//				NSLog(@"Error extracting infomation from keychain item");
		}
		
		SecKeychainItemFreeAttributesAndData(attrList, passwordBytes);
		CFRelease(itemRef);
	}
	return theResult;
}

+ (void)makeNewInternetKeyWithLabel:(NSString *)theLabel
						withAccount:(NSString *)theAccount
						 withServer:(NSString *)theServer
					   withPassword:(NSString *)thePassword
{
	struct SecKeychainAttribute newAttrs[] = {
		{
			.tag    = kSecLabelItemAttr,
			.length = [theLabel length],
			.data   = (void *)[theLabel UTF8String],
		},
		{
			.tag    = kSecServerItemAttr,
			.length = [theServer length],
			.data   = (void *)[theServer UTF8String],
		},
		{
			.tag    = kSecAccountItemAttr,
			.length = [theAccount length],
			.data   = (void *)[theAccount UTF8String],
		}
	};
	struct SecKeychainAttributeList newAttrList = {
		.count = 3,
		.attr  = newAttrs,
	};
	
	SecKeychainItemCreateFromContent(kSecInternetPasswordItemClass,
									 &newAttrList,
									 [thePassword length],
									 [thePassword UTF8String],
									 NULL, // default keychain
									 NULL, // default access--the app creating it
									 NULL);
}

+ (void)deleteKeychainItemByLabel:(NSString *)theLabel
					  withAccount:(NSString *)theAccount
					   withServer:(NSString *)theServer
{
	SecKeychainItemRef itemRef = [self getKeychainRefByLabel:theLabel
												 withAccount:theAccount
												  withServer:theServer];
	if (itemRef != nil) {
		SecKeychainItemDelete(itemRef);
		CFRelease(itemRef);
	}
}

+ (void)editKeychainItemByLabel:(NSString *)theLabel
					withAccount:(NSString *)theAccount
					 withServer:(NSString *)theServer
					 setAccount:(NSString *)newAccount
					  setServer:(NSString *)newServer
					setPassword:(NSString *)newPassword
{
	SecKeychainItemRef itemRef = [self getKeychainRefByLabel:theLabel
												 withAccount:theAccount
												  withServer:theServer];
	if (itemRef != nil) {
		struct SecKeychainAttribute newAttrs[] = {
			{
				.tag    = kSecServerItemAttr,
				.length = [newServer length],
				.data   = (void *)[newServer UTF8String],
			},
			{
				.tag    = kSecAccountItemAttr,
				.length = [newAccount length],
				.data   = (void *)[newAccount UTF8String],
			}
		};
		struct SecKeychainAttributeList newAttrList = {
			.count = 2,
			.attr  = newAttrs,
		};	
		SecKeychainItemModifyAttributesAndData(itemRef,
											   &newAttrList,
											   [newPassword length],
											   [newPassword UTF8String]);
		CFRelease(itemRef);
	}
}


@end
