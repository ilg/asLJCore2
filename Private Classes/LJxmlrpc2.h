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
#import "LJCall.h"


#pragma mark LJ XML-RPC client/server protocol constants

// method names
extern NSString * const kLJXmlRpcMethodCheckFriends;
extern NSString * const kLJXmlRpcMethodConsoleCommand;
extern NSString * const kLJXmlRpcMethodEditEvent;
extern NSString * const kLJXmlRpcMethodEditFriendGroups;
extern NSString * const kLJXmlRpcMethodEditFriends;
extern NSString * const kLJXmlRpcMethodFriendOf;
extern NSString * const kLJXmlRpcMethodGetChallenge;
extern NSString * const kLJXmlRpcMethodGetDayCounts;
extern NSString * const kLJXmlRpcMethodGetEvents;
extern NSString * const kLJXmlRpcMethodGetFriends;
extern NSString * const kLJXmlRpcMethodGetFriendGroups;
extern NSString * const kLJXmlRpcMethodGetUserTags;
extern NSString * const kLJXmlRpcMethodLogin;
extern NSString * const kLJXmlRpcMethodPostEvent;
extern NSString * const kLJXmlRpcMethodSessionExpire;
extern NSString * const kLJXmlRpcMethodSessionGenerate;
extern NSString * const kLJXmlRpcMethodSyncItems;

#define kLJXmlRpcNoParameters [NSDictionary dictionary]

// parameter dictionary keys
extern NSString * const kLJXmlRpcParameterGetPicKwsKey;
extern NSString * const kLJXmlRpcParameterGetPicKwUrlsKey;
extern NSString * const kLJXmlRpcParameterGetMoodsKey;
extern NSString * const kLJXmlRpcParameterUsejournalKey;
extern NSString * const kLJXmlRpcParameterSelectTypeKey;
extern NSString * const kLJXmlRpcParameterYearKey;
extern NSString * const kLJXmlRpcParameterMonthKey;
extern NSString * const kLJXmlRpcParameterDayKey;
extern NSString * const kLJXmlRpcParameterLineEndingsKey;
extern NSString * const kLJXmlRpcParameterNoPropsKey;
extern NSString * const kLJXmlRpcParameterPreferSubjectKey;
extern NSString * const kLJXmlRpcParameterTruncateKey;
extern NSString * const kLJXmlRpcParameterItemIdKey;
extern NSString * const kLJXmlRpcParameterEventKey;
extern NSString * const kLJXmlRpcParameterSubjectKey;
extern NSString * const kLJXmlRpcParameterIncludeBDaysKey;

// parameter dictionary values
extern NSString * const kLJXmlRpcParameterYes;
extern NSString * const kLJXmlRpcParameterNo;
extern NSString * const kLJXmlRpcParameterEmpty;
extern NSString * const kLJXmlRpcParameterMacLineEndings;
extern NSString * const kLJXmlRpcParameterDaySelectType;
extern NSString * const kLJXmlRpcParameterOneSelectType;

@interface LJxmlrpc2 : NSObject <LJCancelable> {
@private
    BOOL cancelled;
}

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

@end
