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
//  asLJCore.h
//  asLJCore
//
//  Created by Isaac Greenspan on 7/17/09.
//


#import <Cocoa/Cocoa.h>

#import "LJAccount.h"
#import "LJCall.h"
#import "LJEntry.h"
#import "LJErrors.h"

// for results from -loginTo:error:
extern NSString * const kasLJCoreLJLoginFullNameKey;
extern NSString * const kasLJCoreLJLoginMessageKey;
extern NSString * const kasLJCoreLJLoginFriendGroupsKey;
extern NSString * const kasLJCoreLJLoginUsejournalsKey;
extern NSString * const kasLJCoreLJLoginMoodsKey;
extern NSString * const kasLJCoreLJLoginUserpicKeywordsKey;
extern NSString * const kasLJCoreLJLoginUserpicURLsKey;
extern NSString * const kasLJCoreLJLoginDefaultUserpicURLKey;
extern NSString * const kasLJCoreLJLoginFastServerKey;
extern NSString * const kasLJCoreLJLoginUserIDKey;
extern NSString * const kasLJCoreLJLoginMenusKey;

// for entry security levels
extern NSString * const kasLJCoreLJEntryPrivateSecurity;
extern NSString * const kasLJCoreLJEntryUsemaskSecurity;
extern NSString * const kasLJCoreLJEntryPublicSecurity; // use for posting only

// for comment screening settings
extern NSString * const kasLJCoreLJCommentScreenEveryone;
extern NSString * const kasLJCoreLJCommentScreenAnonymous;
extern NSString * const kasLJCoreLJCommentScreenNonFriends;
extern NSString * const kasLJCoreLJCommentScreenNoOne;

// for results from -getFriendsFor:error:
extern NSString * const kasLJCoreLJFriendTypeKey;
extern NSString * const kasLJCoreLJFriendUsernameKey;
extern NSString * const kasLJCoreLJFriendTypePersonKey;
extern NSString * const kasLJCoreLJFriendTypeCommunityKey;



@interface asLJCore : NSObject {
    
}

#pragma mark -
#pragma mark initialization/confifguration

// set the name under which account keychain items are stored
+ (void)setKeychainItemName:(NSString *)theName;

// set the version string reported to the LJ-type site
+ (void)setClientVersion:(NSString *)theVersion;

// enable/disable verbose logging
+ (void)setVerboseLogging:(BOOL)verbose;


#pragma mark -
#pragma mark account-handling

+ (NSArray *)allAccounts;

+ (void)addAccountOnServer:(NSString *)server
			  withUsername:(NSString *)username
			  withPassword:(NSString *)password;

+ (void)deleteAccount:(LJAccount *)account;

+ (void)editAccount:(LJAccount *)account
		  setServer:(NSString *)server
		setUsername:(NSString *)username
		setPassword:(NSString *)password;


#pragma mark -
#pragma mark server interaction

+ (LJCall)loginTo:(LJAccount *)account
        onSuccess:(void(^)(NSString *fullName,
                           NSString *message,
                           NSArray *friendGroups,
                           NSArray *useJournals,
                           NSArray *picKeywords,
                           NSArray *picUrls,
                           NSString *defaultPicUrl)
                   )successBlock
          onError:(void(^)(NSError *error))failureBlock;
+ (NSDictionary *)loginTo:(LJAccount *)account
					error:(NSError **)anError;
+ (NSDictionary *)loginTo:(LJAccount *)account;

+ (LJCall)getDayCountsFor:(LJAccount *)account
              withJournal:(NSString *)journal
                onSuccess:(void(^)(NSDictionary *dayCounts))successBlock
                  onError:(void(^)(NSError *error))failureBlock;
+ (NSDictionary *)getDayCountsFor:(LJAccount *)account
					  withJournal:(NSString *)journal
							error:(NSError **)anError;
+ (NSDictionary *)getDayCountsFor:(LJAccount *)account
					  withJournal:(NSString *)journal;

+ (LJCall)getEntriesFor:(LJAccount *)account
            withJournal:(NSString *)journal
                 onDate:(NSCalendarDate *)date
              onSuccess:(void(^)(NSDictionary *entries))successBlock
                onError:(void(^)(NSError *error))failureBlock;
+ (NSDictionary *)getEntriesFor:(LJAccount *)account
					withJournal:(NSString *)journal
						 onDate:(NSCalendarDate *)date
						  error:(NSError **)anError;
+ (NSDictionary *)getEntriesFor:(LJAccount *)account
					withJournal:(NSString *)journal
						 onDate:(NSCalendarDate *)date;

+ (LJCall)getTagsFor:(LJAccount *)account
         withJournal:(NSString *)journal
           onSuccess:(void(^)(NSArray *tags))successBlock
             onError:(void(^)(NSError *error))failureBlock;
+ (NSArray *)getTagsFor:(LJAccount *)account
			withJournal:(NSString *)journal
				  error:(NSError **)anError;
+ (NSArray *)getTagsFor:(LJAccount *)account
			withJournal:(NSString *)journal;

+ (LJCall)deleteEntryFor:(LJAccount *)account
             withJournal:(NSString *)journal
              withItemID:(NSString *)itemid
               onSuccess:(void(^)())successBlock
                 onError:(void(^)(NSError *error))failureBlock;
+ (BOOL)deleteEntryFor:(LJAccount *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid
				 error:(NSError **)anError;
+ (void)deleteEntryFor:(LJAccount *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid;

+ (LJCall)getSessionCookieFor:(LJAccount *)account
                    onSuccess:(void(^)(NSString *sessionCookie))successBlock
                      onError:(void(^)(NSError *error))failureBlock;
+ (NSString *)getSessionCookieFor:(LJAccount *)account
							error:(NSError **)anError;
+ (NSString *)getSessionCookieFor:(LJAccount *)account;

+ (NSString *)makeLoggedInCookieFromSessionCookie:(NSString *)sessionCookie;
+ (NSHTTPCookie *)makeSessionNSHTTPCookieFromSessionCookie:(NSString *)sessionCookie
												forAccount:(LJAccount *)account;
+ (NSHTTPCookie *)makeLoggedInNSHTTPCookieFromSessionCookie:(NSString *)sessionCookie
												 forAccount:(LJAccount *)account;

+ (LJCall)getFriendsFor:(LJAccount *)account
              onSuccess:(void(^)(NSArray *friends))successBlock
                onError:(void(^)(NSError *error))failureBlock;
+ (NSArray *)getFriendsFor:(LJAccount *)account
					 error:(NSError **)anError;
+ (NSArray *)getFriendsFor:(LJAccount *)account;

+ (LJCall)getLJPastEntryWithItemid:(NSNumber *)theItemid
                        forJournal:(NSString *)theJournal
                        forAccount:(LJAccount *)account
                         onSuccess:(void(^)(LJPastEntry *theEntry))successBlock
                           onError:(void(^)(NSError *error))failureBlock;

+ (LJCall)saveLJPastEntry:(LJPastEntry *)theEntry
                onSuccess:(void(^)(NSString *postUrl))successBlock
                  onError:(void(^)(NSError *error))failureBlock;

+ (LJCall)postLJNewEntry:(LJNewEntry *)theEntry
               onSuccess:(void(^)(NSString *postUrl))successBlock
                 onError:(void(^)(NSError *error))failureBlock;


#pragma mark -
#pragma mark moods

+ (NSArray *)getMoodStringsForServer:(NSString *)theServer;
+ (NSString *)getMoodIDForString:(NSString *)theMood
					  withServer:(NSString *)theServer;


@end
