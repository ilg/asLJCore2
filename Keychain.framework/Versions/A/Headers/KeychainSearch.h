//
//  KeychainSearch.h
//  Keychain
//
//  Created by Wade Tregaskis on Fri Jan 24 2003.
//
//  Copyright (c) 2003 - 2007, Wade Tregaskis.  All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//    * Neither the name of Wade Tregaskis nor the names of any other contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <Keychain/Keychain.h>


/*! @function FindCertificatesMatchingPublicKeyHash
    @abstract Locates and returns all certificates in the current user's keychain(s) matching the public key hash given.
    @discussion This method locates all the certificates matching the given public key hash in the current user's default keychain(s).  It returns nil if not found, the certificate otherwise.

                Note that this function is currently extremely inoptimal.  If performance is poor, please log a bug report to encourage it to be rewritten, or better yet rewrite it yourself. :)
    @param hash The hash of the public key for which to find certificates.
    @result An array of certificates, which may be empty if no matches are found.  Nil is returned on error. */

NSArray* FindCertificatesMatchingPublicKeyHash(NSData *hash);


/*! @class KeychainSearch
    @abstract Provides a mechanism for searching through a group of keychains for items with particular attributes.
    @discussion This is your general search mechanism for keychain items.  You can specify all manner of attributes to search by.  By default each new KeychainSearch instance has no parameters set, and will thus match all items in the searched keychains.  After you create the instance, you'll probably want to use the appropriate methods to define what attributes you're looking for.  When you're ready to collect your results, use any of the methods for acquiring results. */

@interface KeychainSearch : NSObject {
    NSArray *_keychainList;
    NSMutableArray *_attributes;
	NSPredicate *_predicate;
    OSStatus _error;
}

+ (KeychainSearch*)keychainSearchWithKeychains:(NSArray*)keychains;
+ (KeychainSearch*)keychainSearchWithKeychains:(NSArray*)keychains predicate:(NSPredicate*)predicate;

- (KeychainSearch*)initWithKeychains:(NSArray*)keychains; // 'keychains' may be NULL, in which case the behaviour is the same as for the init method
- (KeychainSearch*)initWithKeychains:(NSArray*)keychains predicate:(NSPredicate*)predicate; // 'keychains' may be NULL, in which case the behaviour is the same as for the init method

/*! @method init
    @abstract Initialises the receiver to search the current user's default list of keychains.
    @discussion The user's default keychain list usually includes - at the very least - their own user keychain as well as the system keychain.  It can, however, be configured by the user to be whatever they like.
    @result Returns the receiver is successful, otherwise releases the receiver and returns nil. */

- (KeychainSearch*)init;

- (void)setPredicate:(NSPredicate*)predicate;
- (NSPredicate*)predicate;

- (void)setCreationDate:(NSCalendarDate*)date;
- (void)setModificationDate:(NSCalendarDate*)date;
- (void)setTypeDescription:(NSString*)desc;
- (void)setComment:(NSString*)comment;
- (void)setCreator:(NSString*)creator;
- (void)setType:(NSString*)type;
- (void)setLabel:(NSString*)label;
- (void)setIsVisible:(BOOL)visible;
- (void)setPasswordIsValid:(BOOL)valid;
- (void)setHasCustomIcon:(BOOL)customIcon;
- (void)setAccount:(NSString*)account;
- (void)setService:(NSString*)service;
- (void)setUserDefinedAttribute:(NSData*)attr;
- (void)setSecurityDomain:(NSString*)securityDomain;
- (void)setServer:(NSString*)server;
- (void)setAuthenticationType:(SecAuthenticationType)type;
- (void)setPort:(uint16_t)port;
- (void)setPath:(NSString*)path;
- (void)setAppleShareVolume:(NSString*)volume;
- (void)setAppleShareAddress:(NSString*)address;
- (void)setAppleShareSignature:(SecAFPServerSignature*)sig;
- (void)setProtocol:(SecProtocolType)protocol;
- (void)setCertificateType:(CSSM_CERT_TYPE)type;
- (void)setCertificateEncoding:(CSSM_CERT_ENCODING)encoding;
- (void)setCRLType:(CSSM_CRL_TYPE)type;
- (void)setCRLEncoding:(CSSM_CRL_ENCODING)encoding;
- (void)setAlias:(NSString*)alias;

- (NSArray*)searchResultsForClass:(SecItemClass)class;

- (NSArray*)anySearchResults;
- (NSArray*)genericSearchResults;
- (NSArray*)internetSearchResults;
- (NSArray*)appleShareSearchResults;
- (NSArray*)certificateSearchResults;

/*! @method lastError
    @abstract Returns the last error that occured for the receiver.
    @discussion The set of error codes encompasses those returned by Sec* functions - refer to the Security framework documentation for a list.  At present there are no other error codes defined for Access instances.

                Please note that this error code is local to the receiver only, and not any sort of shared global value.
    @result The last error that occured, or zero if the last operation was successful. */

- (OSStatus)lastError;
- (NSArray*)keychains;

@end
