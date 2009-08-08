//
//  MutableKey.h
//  Keychain
//
//  Created by Wade Tregaskis on Sat Mar 15 2003.
//
//  Copyright (c) 2003 - 2007, Wade Tregaskis.  All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//    * Neither the name of Wade Tregaskis nor the names of any other contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import <Keychain/Key.h>


@interface MutableKey : Key {
    CSSM_KEY *_MutableCSSMKey;
    BOOL _freeWhenDone;
}

+ (MutableKey*)generateKey:(CSSM_ALGORITHMS)algorithm size:(uint32_t)keySizeInBits validFrom:(NSCalendarDate*)validFrom validTo:(NSCalendarDate*)validTo usage:(uint32_t)keyUsage mutable:(BOOL)keyIsMutable extractable:(BOOL)keyIsExtractable sensitive:(BOOL)keyIsSensitive label:(NSString*)label module:(CSSMModule*)CSPModule;

+ (MutableKey*)keyWithKeyRef:(SecKeyRef)ke module:(CSSMModule*)CSPModule;
+ (MutableKey*)keyWithCSSMKey:(CSSM_KEY*)ke module:(CSSMModule*)CSPModule;
+ (MutableKey*)keyWithCSSMKey:(CSSM_KEY*)ke freeWhenDone:(BOOL)freeWhenDo module:(CSSMModule*)CSPModule;

- (MutableKey*)initWithKeyRef:(SecKeyRef)ke module:(CSSMModule*)CSPModule;
- (MutableKey*)initWithCSSMKey:(CSSM_KEY*)ke freeWhenDone:(BOOL)freeWhenDo module:(CSSMModule*)CSPModule;

/*! @method init
    @abstract Reject initialiser.
    @discussion You cannot initialise a MutableKey using "init" - use one of the other initialisation methods.
    @result This method always releases the receiver and returns nil. */

- (MutableKey*)init;

- (void)setFreeWhenDone:(BOOL)freeWhenDo;
- (BOOL)freeWhenDone;

- (void)setVersion:(CSSM_HEADERVERSION)version;
- (void)setBlobType:(CSSM_KEYBLOB_TYPE)blobType;
- (void)setFormat:(CSSM_KEYBLOB_FORMAT)format;
- (void)setAlgorithm:(CSSM_ALGORITHMS)algorithm;
- (void)setWrapAlgorithm:(CSSM_ALGORITHMS)wrapAlgorithm;
- (void)setKeyClass:(CSSM_KEYCLASS)keyClass;
- (void)setLogicalSize:(int)size;
- (void)setAttributes:(CSSM_KEYATTR_FLAGS)attributes;
- (void)setUsage:(CSSM_KEYUSE)usage;
- (void)setStartDate:(NSCalendarDate*)date;
- (void)setEndDate:(NSCalendarDate*)date;
- (void)setWrapMode:(CSSM_ENCRYPT_MODE)wrapMode;

- (void)setData:(NSData*)data;

- (CSSM_KEY*)CSSMKey;

@end

CSSM_RETURN generateKeyPair(CSSM_ALGORITHMS algorithm, uint32_t keySizeInBits, NSCalendarDate *validFrom, NSCalendarDate *validTo, uint32_t publicKeyUsage, uint32_t privateKeyUsage, NSString *publicKeyLabel, NSString *privateKeyLabel, CSSMModule *CSPModule, MutableKey **publicKey, MutableKey **privateKey);
