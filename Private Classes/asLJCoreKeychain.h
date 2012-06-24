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
//  asLJCoreKeychain.h
//  asLJCore
//
//  Created by Isaac Greenspan on 1/22/09.
//

#import <Cocoa/Cocoa.h>


@interface asLJCoreKeychain :  NSObject 
{
	
}
+ (NSArray *)getKeysByLabel:(NSString *)theLabel;
+ (NSString *)getPasswordByLabel:(NSString *)theLabel
					 withAccount:(NSString *)theAccount
					  withServer:(NSString *)theServer;
+ (void)makeNewInternetKeyWithLabel:(NSString *)theLabel
						withAccount:(NSString *)theAccount
						 withServer:(NSString *)theServer
					   withPassword:(NSString *)thePassword;
+ (void)deleteKeychainItemByLabel:(NSString *)theLabel
					  withAccount:(NSString *)theAccount
					   withServer:(NSString *)theServer;
+ (void)editKeychainItemByLabel:(NSString *)theLabel
					withAccount:(NSString *)theAccount
					 withServer:(NSString *)theServer
					 setAccount:(NSString *)newAccount
					  setServer:(NSString *)newServer
					setPassword:(NSString *)newPassword;
@end
