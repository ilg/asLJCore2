//
//  KeychainStuff.m
//  asLJFramework
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

#import "KeychainStuff.h"
#import <Keychain/Keychain.h>
#import <Keychain/KeychainSearch.h>

@implementation KeychainStuff

- (NSArray *)getKeysByLabel:(NSString *)theLabel
{
	KeychainSearch *theSearch = [KeychainSearch keychainSearchWithKeychains:NULL];
	KeychainItem *aKey;
	NSMutableArray *theResults = [NSMutableArray arrayWithCapacity:0];
	[theSearch setLabel:theLabel];
	for (aKey in [theSearch internetSearchResults]) {
		[theResults addObject:[NSString stringWithFormat:@"%@@%@",[aKey account],[aKey server]]];
	}
	return theResults;
}

- (KeychainItem *)getKeychainItemByLabel:(NSString *)theLabel
							 withAccount:(NSString *)theAccount
							  withServer:(NSString *)theServer
{
	KeychainSearch *theSearch = [KeychainSearch keychainSearchWithKeychains:NULL];
	[theSearch setLabel:theLabel];
	[theSearch setAccount:theAccount];
	[theSearch setServer:theServer];
	return [[[theSearch internetSearchResults] lastObject] retain];
}

- (NSString *)getPasswordByLabel:(NSString *)theLabel
					 withAccount:(NSString *)theAccount
					  withServer:(NSString *)theServer
{
	KeychainItem *aKey = [self getKeychainItemByLabel:theLabel 
										  withAccount:theAccount 
										   withServer:theServer];
	return [aKey dataAsString];
}

- (void)makeNewInternetKeyWithLabel:(NSString *)theLabel
						withAccount:(NSString *)theAccount
						 withServer:(NSString *)theServer
					   withPassword:(NSString *)thePassword
{
	Keychain *theKeychain = [Keychain defaultKeychain];
	KeychainItem *theItem =	[theKeychain addInternetPassword:thePassword 
													onServer:theServer 
												  forAccount:theAccount
														port:0
														path:nil
											inSecurityDomain:nil
													protocol:kSecProtocolTypeAny
														auth:kSecAuthenticationTypeDefault
											 replaceExisting:YES];
	[theItem setLabel:theLabel];
	
}

@end
