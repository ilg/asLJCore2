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
//  asLJCore.m
//  asLJCore
//
//  Created by Isaac Greenspan on 7/17/09.
//

#import "asLJCore.h"
#import "LJxmlrpc2.h"
#import "LJMoods.h"
#import "asLJCoreKeychain.h"

#pragma mark constants

// for results from -loginTo:error:
NSString * const kasLJCoreLJLoginFullNameKey = @"fullname";
NSString * const kasLJCoreLJLoginMessageKey = @"message";
NSString * const kasLJCoreLJLoginFriendGroupsKey = @"friendgroups";
NSString * const kasLJCoreLJLoginUsejournalsKey = @"usejournals";
NSString * const kasLJCoreLJLoginMoodsKey = @"moods";
NSString * const kasLJCoreLJLoginUserpicKeywordsKey = @"pickws";
NSString * const kasLJCoreLJLoginUserpicURLsKey = @"pickwurls";
NSString * const kasLJCoreLJLoginDefaultUserpicURLKey = @"defaultpicurl";
NSString * const kasLJCoreLJLoginFastServerKey = @"fastserver";
NSString * const kasLJCoreLJLoginUserIDKey = @"userid";
NSString * const kasLJCoreLJLoginMenusKey = @"menus";

// for entry security levels
NSString * const kasLJCoreLJEntryPrivateSecurity = @"private";
NSString * const kasLJCoreLJEntryUsemaskSecurity = @"usemask";
NSString * const kasLJCoreLJEntryPublicSecurity = @"public"; // use for posting only

// for comment screening settings
NSString * const kasLJCoreLJCommentScreenEveryone = @"A";
NSString * const kasLJCoreLJCommentScreenAnonymous = @"R";
NSString * const kasLJCoreLJCommentScreenNonFriends = @"F";
NSString * const kasLJCoreLJCommentScreenNoOne = @"N";

// for results from -getFriendsFor:error:
NSString * const kasLJCoreLJFriendTypeKey = @"type";
NSString * const kasLJCoreLJFriendUsernameKey = @"username";
NSString * const kasLJCoreLJFriendTypePersonKey = @"";
NSString * const kasLJCoreLJFriendTypeCommunityKey = @"community";

#pragma mark -

@implementation asLJCore

#pragma mark -
#pragma mark initialization/confifguration

static NSString *keychainItemName;

// set the name under which account keychain items are stored
+ (void)setKeychainItemName:(NSString *)theName
{
	[keychainItemName release];
	keychainItemName = [[theName copy] retain];
	[LJxmlrpc2 setKeychainItemName:theName];
}

// set the version string reported to the LJ-type site
+ (void)setClientVersion:(NSString *)theVersion
{
	[LJxmlrpc2 setClientVersion:theVersion];
}

// enable/disable verbose logging
+ (void)setVerboseLogging:(BOOL)verbose
{
	[asLJCoreLogger setVerboseLogging:verbose];
}


#pragma mark -
#pragma mark account-handling

+ (NSArray *)allAccounts
{
	NSArray *accountArray = [asLJCoreKeychain getKeysByLabel:keychainItemName];
	return [NSArray arrayWithArray:accountArray];
}

+ (void)addAccountOnServer:(NSString *)server
			  withUsername:(NSString *)username
			  withPassword:(NSString *)password
{
	[asLJCoreKeychain makeNewInternetKeyWithLabel:keychainItemName
									  withAccount:username
									   withServer:server
									 withPassword:password];
}

+ (void)deleteAccount:(NSString *)accountString
{
    LJAccount *account = [LJAccount accountFromString:accountString];
	[asLJCoreKeychain deleteKeychainItemByLabel:keychainItemName
									withAccount:[account username]
									 withServer:[account server]];
}

+ (void)editAccount:(NSString *)accountString
		  setServer:(NSString *)server
		setUsername:(NSString *)username
		setPassword:(NSString *)password
{
    LJAccount *account = [LJAccount accountFromString:accountString];
	[asLJCoreKeychain editKeychainItemByLabel:keychainItemName
								  withAccount:[account username]
								   withServer:[account server]
								   setAccount:username
									setServer:server
								  setPassword:password];
}


#pragma mark - server interaction
#pragma mark internal/convenience

+ (NSDictionary *)convenientCall:(NSString *)methodName
					  forAccount:(NSString *)accountString
					  withParams:(NSDictionary *)params
						   error:(NSError **)anError
{
    LJAccount *account = [LJAccount accountFromString:accountString];
	NSError *myError;
    NSDictionary *callResult = [LJxmlrpc2 synchronousCallMethod:methodName
                                                 withParameters:params
                                                          atUrl:SERVER2URL([account server])
                                                        forUser:[account username]
                                                          error:&myError];
	if (!callResult) {
		// call failed
		VLOG(@"Fault (%d): %@", [myError code], [[myError userInfo] objectForKey:NSLocalizedDescriptionKey]);
		if (anError != NULL) *anError = [[myError copy] autorelease];
        return nil;
	}
	return callResult;
}

#pragma mark login

+ (NSDictionary *)parametersForLoginTo:(LJAccount *)account
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            // (value,key), nil to end
            kLJXmlRpcParameterYes, kLJXmlRpcParameterGetPicKwsKey,
            kLJXmlRpcParameterYes, kLJXmlRpcParameterGetPicKwUrlsKey,
            [LJMoods getHighestMoodIDForServer:[account server]], kLJXmlRpcParameterGetMoodsKey,
            nil];
}
+ (NSDictionary *)processResult:(NSDictionary *)result
                    fromLoginTo:(LJAccount *)account
{
    VLOG(@"... logged in.");
    NSArray *newMoods = [result objectForKey:kasLJCoreLJLoginMoodsKey];
    NSMutableArray *newMoodStrings = [NSMutableArray arrayWithCapacity:[newMoods count]];
    NSMutableArray *newMoodIDs = [NSMutableArray arrayWithCapacity:[newMoods count]];
    for (id theNewMood in newMoods) {
        [newMoodStrings addObject:[theNewMood objectForKey:@"name"]];
        [newMoodIDs addObject:[theNewMood objectForKey:@"id"]];
    }
    [LJMoods addNewMoods:newMoodStrings
                 withIDs:newMoodIDs
               forServer:[account server]];
    return result;
}
+ (LJCall)loginTo:(LJAccount *)account
        onSuccess:(void(^)(NSString *fullName,
                           NSString *message,
                           NSArray *friendGroups,
                           NSArray *useJournals,
                           NSArray *picKeywords,
                           NSArray *picUrls,
                           NSString *defaultPicUrl)
                   )successBlock
          onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodLogin
            withParameters:[self parametersForLoginTo:account]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                [self processResult:result
                        fromLoginTo:account];
                successBlock(
                             [result objectForKey:kasLJCoreLJLoginFullNameKey],
                             [result objectForKey:kasLJCoreLJLoginMessageKey],
                             [result objectForKey:kasLJCoreLJLoginFriendGroupsKey],
                             [result objectForKey:kasLJCoreLJLoginUsejournalsKey],
                             [result objectForKey:kasLJCoreLJLoginUserpicKeywordsKey],
                             [result objectForKey:kasLJCoreLJLoginUserpicURLsKey],
                             [result objectForKey:kasLJCoreLJLoginDefaultUserpicURLKey]
                             );
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

+ (NSDictionary *)loginTo:(NSString *)accountString
					error:(NSError **)anError
{
	NSDictionary *theResult;
	NSError *myError;
    LJAccount *account = [LJAccount accountFromString:accountString];
	NSDictionary *theCall =[self convenientCall:kLJXmlRpcMethodLogin
									 forAccount:accountString
									 withParams:[self parametersForLoginTo:account]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		theResult = [self processResult:[NSDictionary dictionaryWithDictionary:theCall]
                            fromLoginTo:account];
	}
	return theResult;
}

+ (NSDictionary *)loginTo:(NSString *)account
{
	return [self loginTo:account error:NULL];
}

#pragma mark getDayCounts

+ (NSDictionary *)parametersForGetDayCountsForJournal:(NSString *)journal
{
    return [NSDictionary dictionaryWithObject:journal
                                       forKey:kLJXmlRpcParameterUsejournalKey];
}
+ (NSDictionary *)processGetDayCountsResult:(NSDictionary *)result
{
    NSArray *dayCountArray = [result objectForKey:@"daycounts"];
    VLOG(@"Got counts for %d days", [dayCountArray count]);
    NSMutableDictionary *temporaryResults = [NSMutableDictionary dictionaryWithCapacity:[dayCountArray count]];
    for (id theDayCount in dayCountArray) {
        [temporaryResults setObject:[theDayCount objectForKey:@"count"]
                             forKey:[theDayCount objectForKey:@"date"]];
    }
    return [NSDictionary dictionaryWithDictionary:temporaryResults];
}
+ (LJCall)getDayCountsFor:(LJAccount *)account
              withJournal:(NSString *)journal
                onSuccess:(void(^)(NSDictionary *dayCounts))successBlock
                  onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodGetDayCounts
            withParameters:[self parametersForGetDayCountsForJournal:journal]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                successBlock([self processGetDayCountsResult:result]);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

+ (NSDictionary *)getDayCountsFor:(NSString *)account
					  withJournal:(NSString *)journal
							error:(NSError **)anError
{
	NSDictionary *theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:kLJXmlRpcMethodGetDayCounts
									 forAccount:account
									 withParams:[self parametersForGetDayCountsForJournal:journal]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		theResult = [self processGetDayCountsResult:theCall];
	}
	return theResult;
}

+ (NSDictionary *)getDayCountsFor:(NSString *)account
					  withJournal:(NSString *)journal
{
	return [self getDayCountsFor:account withJournal:journal error:NULL];
}

#pragma mark getEntries

+ (NSDictionary *)parametersForGetEntriesForJournal:(NSString *)journal
                                             onDate:(NSCalendarDate *)date
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            // (value,key), nil to end
            journal, kLJXmlRpcParameterUsejournalKey,
            kLJXmlRpcParameterDaySelectType, kLJXmlRpcParameterSelectTypeKey,
            [NSString stringWithFormat:@"%d",[date yearOfCommonEra]], kLJXmlRpcParameterYearKey,
            [NSString stringWithFormat:@"%d",[date monthOfYear]], kLJXmlRpcParameterMonthKey,
            [NSString stringWithFormat:@"%d",[date dayOfMonth]], kLJXmlRpcParameterDayKey,
            kLJXmlRpcParameterMacLineEndings, kLJXmlRpcParameterLineEndingsKey,
            kLJXmlRpcParameterYes, kLJXmlRpcParameterNoPropsKey,
            kLJXmlRpcParameterYes, kLJXmlRpcParameterPreferSubjectKey,
            @"200", kLJXmlRpcParameterTruncateKey,
            nil];
}
+ (NSDictionary *)processGetEntriesResult:(NSDictionary *)result
{
    NSArray *eventArray = [result objectForKey:@"events"];
    VLOG(@"Got %d events",[eventArray count]);
    NSMutableDictionary *temporaryResults = [NSMutableDictionary dictionaryWithCapacity:[eventArray count]];
    for (id anEvent in eventArray) {
        [temporaryResults setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"[%@] %@",
                                      [[[anEvent objectForKey:@"eventtime"] 
                                        componentsSeparatedByString:@" "] lastObject],
                                      [anEvent objectForKey:@"event"]],
                                     @"title",
                                     [anEvent objectForKey:@"url"],@"url",
                                     nil]
                             forKey:[anEvent objectForKey:@"itemid"]];
    }
    return [NSDictionary dictionaryWithDictionary:temporaryResults];
}
+ (LJCall)getEntriesFor:(LJAccount *)account
            withJournal:(NSString *)journal
                 onDate:(NSCalendarDate *)date
              onSuccess:(void(^)(NSDictionary *entries))successBlock
                onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodGetEvents
            withParameters:[self parametersForGetEntriesForJournal:journal
                                                            onDate:date]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                successBlock([self processGetEntriesResult:result]);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

+ (NSDictionary *)getEntriesFor:(NSString *)account
					withJournal:(NSString *)journal
						 onDate:(NSCalendarDate *)date
						  error:(NSError **)anError
{
	NSDictionary *theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:kLJXmlRpcMethodGetEvents
									 forAccount:account
									 withParams:[self parametersForGetEntriesForJournal:journal
                                                                                 onDate:date]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		theResult = [self processGetEntriesResult:theCall];
	}
	return theResult;
}

+ (NSDictionary *)getEntriesFor:(NSString *)account
					withJournal:(NSString *)journal
						 onDate:(NSCalendarDate *)date
{
	return [self getEntriesFor:account withJournal:journal onDate:date error:NULL];
}

#pragma mark getTags

+ (NSDictionary *)parametersForGetTagsForJournal:(NSString *)journal
{
    return [NSDictionary dictionaryWithObject:journal
                                       forKey:kLJXmlRpcParameterUsejournalKey];
}
+ (NSArray *)processGetTagsResult:(NSDictionary *)result
{
    NSArray *tagsArray = [result objectForKey:@"tags"];
    VLOG(@"Got %d tags",[tagsArray count]);
    NSMutableArray *temporaryResults = [NSMutableArray arrayWithCapacity:[tagsArray count]];
    for (id aTag in tagsArray) {
        [temporaryResults addObject:[aTag objectForKey:@"name"]];
    }
    return [NSArray arrayWithArray:temporaryResults];
}
+ (LJCall)getTagsFor:(LJAccount *)account
         withJournal:(NSString *)journal
           onSuccess:(void(^)(NSArray *tags))successBlock
             onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodGetUserTags
            withParameters:[self parametersForGetTagsForJournal:journal]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                successBlock([self processGetTagsResult:result]);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

+ (NSArray *)getTagsFor:(NSString *)account
			withJournal:(NSString *)journal
				  error:(NSError **)anError
{
	NSArray *theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:kLJXmlRpcMethodGetUserTags
									 forAccount:account
									 withParams:[self parametersForGetTagsForJournal:journal]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
        theResult = [self processGetTagsResult:theCall];
	}
	return theResult;
}

+ (NSArray *)getTagsFor:(NSString *)account
			withJournal:(NSString *)journal
{
	return [self getTagsFor:account withJournal:journal error:NULL];
}

#pragma mark deleteEntry

+ (NSDictionary *)parametersForDeleteEntryForJournal:(NSString *)journal
                                          withItemId:(NSString *)itemId
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            // (value,key), nil to end
            journal, kLJXmlRpcParameterUsejournalKey,
            itemId, kLJXmlRpcParameterItemIdKey,
            kLJXmlRpcParameterEmpty, kLJXmlRpcParameterEventKey,
            kLJXmlRpcParameterEmpty, kLJXmlRpcParameterSubjectKey,
            kLJXmlRpcParameterMacLineEndings, kLJXmlRpcParameterLineEndingsKey,
            nil];
}
+ (LJCall)deleteEntryFor:(LJAccount *)account
             withJournal:(NSString *)journal
              withItemID:(NSString *)itemid
               onSuccess:(void(^)())successBlock
                 onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodEditEvent
            withParameters:[self parametersForDeleteEntryForJournal:journal
                                                         withItemId:itemid]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                VLOG(@"Deleted entry with itemid=%@",itemid);
                successBlock();
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

+ (BOOL)deleteEntryFor:(NSString *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid
				 error:(NSError **)anError
{
	BOOL theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:kLJXmlRpcMethodEditEvent
									 forAccount:account
									 withParams:[self parametersForDeleteEntryForJournal:journal
                                                                              withItemId:itemid]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = NO;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		VLOG(@"Deleted entry with itemid=%@",itemid);
		theResult = YES;
	}
	return theResult;
}

+ (void)deleteEntryFor:(NSString *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid
{
	[self deleteEntryFor:account withJournal:journal withItemID:itemid error:NULL];
}

#pragma mark getSessionCookie

+ (NSString *)processGetSessionCookieResult:(NSDictionary *)result
{
    VLOG(@"Got session cookie.");
    return [NSString stringWithString:[result objectForKey:@"ljsession"]];
}
+ (LJCall)getSessionCookieFor:(LJAccount *)account
                    onSuccess:(void(^)(NSString *sessionCookie))successBlock
                      onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodSessionGenerate
            withParameters:kLJXmlRpcNoParameters
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                successBlock([self processGetSessionCookieResult:result]);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

+ (NSString *)getSessionCookieFor:(NSString *)account
							error:(NSError **)anError
{
	NSString *theResult;
	NSError *myError;
	NSDictionary *theCall = [self convenientCall:kLJXmlRpcMethodSessionGenerate
									  forAccount:account
									  withParams:kLJXmlRpcNoParameters
										   error:&myError];
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		theResult = [self processGetSessionCookieResult:theCall];
	}
	return theResult;
}

+ (NSString *)getSessionCookieFor:(NSString *)account
{
	return [self getSessionCookieFor:account error:NULL];
}

+ (NSString *)makeLoggedInCookieFromSessionCookie:(NSString *)sessionCookie
{
	return [[[sessionCookie componentsSeparatedByString:@":"]
			 objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1,2)]]
			componentsJoinedByString:@":"];
}

+ (NSHTTPCookie *)makeSessionNSHTTPCookieFromSessionCookie:(NSString *)sessionCookie
												forAccount:(NSString *)account
{
	NSString *server = [[LJAccount accountFromString:account] server];
	NSString *cookieDomain;
	if ([server hasPrefix:@"www."]) {
		cookieDomain = [NSString stringWithFormat:@".%@",[server substringFromIndex:4]];
	} else {
		cookieDomain = [NSString stringWithFormat:@".%@",server];
	}
	return [NSHTTPCookie
			cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
								  @"ljsession",NSHTTPCookieName,
								  sessionCookie,NSHTTPCookieValue,
								  cookieDomain,NSHTTPCookieDomain,
								  @"/",NSHTTPCookiePath,
								  nil]];
}

+ (NSHTTPCookie *)makeLoggedInNSHTTPCookieFromSessionCookie:(NSString *)sessionCookie
												 forAccount:(NSString *)account
{
	NSString *server = [[LJAccount accountFromString:account] server];
	NSString *cookieDomain;
	if ([server hasPrefix:@"www."]) {
		cookieDomain = [NSString stringWithFormat:@".%@",[server substringFromIndex:4]];
	} else {
		cookieDomain = [NSString stringWithFormat:@".%@",server];
	}
	NSString *loggedInCookie = [self makeLoggedInCookieFromSessionCookie:sessionCookie];
	return [NSHTTPCookie
			cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
								  @"ljloggedin",NSHTTPCookieName,
								  loggedInCookie,NSHTTPCookieValue,
								  cookieDomain,NSHTTPCookieDomain,
								  @"/",NSHTTPCookiePath,
								  nil]];
}


#pragma mark getFriends

+ (NSDictionary *)parametersForGetFriends
{
    return [NSDictionary dictionaryWithObject:kLJXmlRpcParameterYes
                                       forKey:kLJXmlRpcParameterIncludeBDaysKey];
}
+ (NSArray *)processGetFriendsResult:(NSDictionary *)result
{
    NSArray *friends = [result objectForKey:@"friends"];
    VLOG(@"Got %d friends", [friends count]);
    NSMutableArray *temporaryResults = [NSMutableArray arrayWithCapacity:[friends count]];
    for (NSDictionary *aFriend in friends) {
        [temporaryResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
                                     NIL2EMPTY([aFriend objectForKey:@"username"]),@"username",
                                     NIL2EMPTY([aFriend objectForKey:@"fullname"]),@"fullname",
                                     NIL2EMPTY([aFriend objectForKey:@"identity_type"]),@"identity_type",
                                     NIL2EMPTY([aFriend objectForKey:@"identity_value"]),@"identity_value",
                                     NIL2EMPTY([aFriend objectForKey:@"identity_display"]),@"identity_display",
                                     NIL2EMPTY([aFriend objectForKey:@"type"]),@"type",
                                     NIL2EMPTY([aFriend objectForKey:@"birthday"]),@"birthday",
                                     NIL2EMPTY([aFriend objectForKey:@"fgcolor"]),@"fgcolor",
                                     NIL2EMPTY([aFriend objectForKey:@"bgcolor"]),@"bgcolor",
                                     NIL2EMPTY([aFriend objectForKey:@"groupmask"]),@"groupmask",
                                     nil]]; 
    }
    return [NSArray arrayWithArray:temporaryResults];
}
+ (LJCall)getFriendsFor:(LJAccount *)account
              onSuccess:(void(^)(NSArray *friends))successBlock
                onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodGetFriends
            withParameters:[self parametersForGetFriends]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                successBlock([self processGetFriendsResult:result]);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

+ (NSArray *)getFriendsFor:(NSString *)account
					 error:(NSError **)anError
{
	NSArray *theResult;
	NSError *myError;
	NSDictionary *theCall = [self convenientCall:kLJXmlRpcMethodGetFriends
									  forAccount:account
									  withParams:[self parametersForGetFriends]
										   error:&myError];
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		theResult = [self processGetFriendsResult:theCall];
	}
	return theResult;
}

+ (NSArray *)getFriendsFor:(NSString *)account
{
	return [self getFriendsFor:account error:NULL];
}

#pragma mark getLJPastEntry
+ (LJCall)getLJPastEntryWithItemid:(NSNumber *)itemId
                        forJournal:(NSString *)journal
                        forAccount:(LJAccount *)account
                         onSuccess:(void(^)(LJPastEntry *theEntry))successBlock
                           onError:(void(^)(NSError *error))failureBlock
{
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodGetEvents
            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                            // (value, key); end with nil
                            kLJXmlRpcParameterOneSelectType, kLJXmlRpcParameterSelectTypeKey,
                            journal, kLJXmlRpcParameterUsejournalKey,
                            itemId, kLJXmlRpcParameterItemIdKey,
                            kLJXmlRpcParameterMacLineEndings, kLJXmlRpcParameterLineEndingsKey,
                            nil]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                // extract the one event we want and its metadata "props"
                NSMutableDictionary *theEvent = [NSMutableDictionary dictionaryWithDictionary:
                                                 [[result objectForKey:@"events"] lastObject]];
                
                // parse out the eventtime
                NSString *eventtime = [theEvent objectForKey:@"eventtime"];  // "YYYY-MM-DD hh:mm:00"
                [theEvent setObject:[eventtime substringWithRange:NSMakeRange(0, 4)]
                             forKey:@"year"];
                [theEvent setObject:[eventtime substringWithRange:NSMakeRange(5, 2)]
                             forKey:@"mon"];
                [theEvent setObject:[eventtime substringWithRange:NSMakeRange(8, 2)]
                             forKey:@"day"];
                [theEvent setObject:[eventtime substringWithRange:NSMakeRange(11, 2)]
                             forKey:@"hour"];
                [theEvent setObject:[eventtime substringWithRange:NSMakeRange(14, 2)]
                             forKey:@"min"];
                
                LJPastEntry *entry = [[LJPastEntry alloc] init];
                [entry setItemid:itemId];
                [entry setUsejournal:journal];
                [entry setAccount:[account username]];
                [entry setServer:[account server]];
                [entry setEntryFromDictionary:theEvent];
                successBlock([entry autorelease]);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

#pragma mark saveLJPastEntry

+ (NSDictionary *)parametersForSaveLJPastEntry:(LJPastEntry *)theEntry
{
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:
                                      [theEntry getEntryAsDictionary]];
	[paramDict setObject:kLJXmlRpcParameterMacLineEndings
                  forKey:kLJXmlRpcParameterLineEndingsKey];
	[paramDict setObject:[theEntry itemid]
                  forKey:kLJXmlRpcParameterItemIdKey];
    return paramDict;
}
+ (LJCall)saveLJPastEntry:(LJPastEntry *)theEntry
                onSuccess:(void(^)(NSString *postUrl))successBlock
                  onError:(void(^)(NSError *error))failureBlock
{
    LJAccount *account = [LJAccount accountWithUsername:[theEntry account]
                                               atServer:[theEntry server]];
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodEditEvent
            withParameters:[self parametersForSaveLJPastEntry:theEntry]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                NSString *postUrl = [result objectForKey:@"url"];
                if (postUrl) {
                    postUrl = [NSString stringWithString:postUrl];
                }
                successBlock(postUrl);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

#pragma mark postLJNewEntry

+ (NSDictionary *)parametersForPostLJNewEntry:(LJNewEntry *)theEntry
{
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:
                                      [theEntry getEntryAsDictionary]];
	[paramDict setObject:kLJXmlRpcParameterMacLineEndings
                  forKey:kLJXmlRpcParameterLineEndingsKey];
    return paramDict;
}
+ (LJCall)postLJNewEntry:(LJNewEntry *)theEntry
               onSuccess:(void(^)(NSString *postUrl))successBlock
                 onError:(void(^)(NSError *error))failureBlock
{
    LJAccount *account = [LJAccount accountWithUsername:[theEntry account]
                                               atServer:[theEntry server]];
    return [LJxmlrpc2
            asynchronousCallMethod:kLJXmlRpcMethodPostEvent
            withParameters:[self parametersForPostLJNewEntry:theEntry]
            atUrl:SERVER2URL([account server])
            forUser:[account username]
            success:^(NSDictionary *result) {
                NSString *postUrl = [result objectForKey:@"url"];
                if (postUrl) {
                    postUrl = [NSString stringWithString:postUrl];
                }
                successBlock(postUrl);
            }
            failure:^(NSError *error) {
                failureBlock(error);
            }];
}

#pragma mark -
#pragma mark moods

+ (NSArray *)getMoodStringsForServer:(NSString *)theServer
{
	return [LJMoods getMoodStringsForServer:theServer];
}

+ (NSString *)getMoodIDForString:(NSString *)theMood
					  withServer:(NSString *)theServer
{
	return [LJMoods getMoodIDForString:theMood withServer:theServer];
}

@end
