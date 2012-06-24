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
#import "LJxmlrpc.h"
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

// for internal use (in +splitAccountString: and the results therefrom)
NSString * const kasLJCoreAccountUsernameKey = @"username";
NSString * const kasLJCoreAccountServerKey = @"server";

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
	[LJxmlrpc setKeychainItemName:theName];
}

// set the version string reported to the LJ-type site
+ (void)setClientVersion:(NSString *)theVersion
{
	[LJxmlrpc setClientVersion:theVersion];
}

// enable/disable verbose logging
+ (void)setVerboseLogging:(BOOL)verbose
{
	[asLJCoreLogger setVerboseLogging:verbose];
}


#pragma mark -
#pragma mark internal utility

// turn a@b into kasLJCoreAccountUsernameKey => a, kasLJCoreAccountServerKey => b
+ (NSDictionary *)splitAccountString:(NSString *)account
{
	NSArray *parts = [account componentsSeparatedByString:@"@"];
	if ([parts count] == 2) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				[parts objectAtIndex:0],kasLJCoreAccountUsernameKey,
				[parts objectAtIndex:1],kasLJCoreAccountServerKey,
				nil];
	} else {
		return nil;
	}
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

+ (void)deleteAccount:(NSString *)account
{
	NSDictionary *accountInfo = [self splitAccountString:account];
	[asLJCoreKeychain deleteKeychainItemByLabel:keychainItemName
									withAccount:[accountInfo objectForKey:kasLJCoreAccountUsernameKey]
									 withServer:[accountInfo objectForKey:kasLJCoreAccountServerKey]];
}

+ (void)editAccount:(NSString *)account
		  setServer:(NSString *)server
		setUsername:(NSString *)username
		setPassword:(NSString *)password
{
	NSDictionary *accountInfo = [self splitAccountString:account];
	[asLJCoreKeychain editKeychainItemByLabel:keychainItemName
								  withAccount:[accountInfo objectForKey:kasLJCoreAccountUsernameKey]
								   withServer:[accountInfo objectForKey:kasLJCoreAccountServerKey]
								   setAccount:username
									setServer:server
								  setPassword:password];
}


#pragma mark -
#pragma mark server interaction

+ (NSDictionary *)convenientCall:(NSString *)methodName
					  forAccount:(NSString *)account
					  withParams:(NSDictionary *)params
						   error:(NSError **)anError
{
	NSDictionary *theResult;
	NSDictionary *accountInfo = [self splitAccountString:account];
	NSError *myError;
	LJxmlrpc *theCall = [LJxmlrpc newCall:methodName
							   withParams:params
									atURL:SERVER2URL([accountInfo objectForKey:kasLJCoreAccountServerKey])
								  forUser:[accountInfo objectForKey:kasLJCoreAccountUsernameKey]
									error:&myError];
	if (!theCall) {
		// call failed
		VLOG(@"Fault (%d): %@", [myError code], [[myError userInfo] objectForKey:NSLocalizedDescriptionKey]);
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		theResult = [theCall getResultDictionary];
	}
	[theCall release];
	return theResult;
}


+ (NSDictionary *)loginTo:(NSString *)account
					error:(NSError **)anError
{
	NSDictionary *theResult;
	NSError *myError;
	NSDictionary *accountInfo = [self splitAccountString:account];
	NSDictionary *theCall =[self convenientCall:@"login"
									 forAccount:account
									 withParams:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
												 @"1",@"getpickws",
												 @"1",@"getpickwurls",
												 [LJMoods getHighestMoodIDForServer:[accountInfo objectForKey:kasLJCoreAccountServerKey]],@"getmoods",
												 nil]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		VLOG(@"... logged in.");
		
		// store new moods
		NSArray *newMoods = [theCall objectForKey:kasLJCoreLJLoginMoodsKey];
		NSMutableArray *newMoodStrings = [NSMutableArray arrayWithCapacity:[newMoods count]];
		NSMutableArray *newMoodIDs = [NSMutableArray arrayWithCapacity:[newMoods count]];
		for (id theNewMood in newMoods) {
			[newMoodStrings addObject:[theNewMood objectForKey:@"name"]];
			[newMoodIDs addObject:[theNewMood objectForKey:@"id"]];
		}
		[LJMoods addNewMoods:newMoodStrings
					 withIDs:newMoodIDs
				   forServer:[accountInfo objectForKey:kasLJCoreAccountServerKey]];
		theResult = [NSDictionary dictionaryWithDictionary:theCall];
	}
	return theResult;
}

+ (NSDictionary *)loginTo:(NSString *)account
{
	return [self loginTo:account error:NULL];
}

+ (NSDictionary *)getDayCountsFor:(NSString *)account
					  withJournal:(NSString *)journal
							error:(NSError **)anError
{
	NSDictionary *theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:@"getdaycounts"
									 forAccount:account
									 withParams:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
												 journal,@"usejournal",
												 nil]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		NSArray *dayCountArray = [theCall objectForKey:@"daycounts"];
		VLOG(@"Got counts for %d days",[dayCountArray count]);
		NSMutableDictionary *temporaryResults = [NSMutableDictionary dictionaryWithCapacity:[dayCountArray count]];
		for (id theDayCount in dayCountArray) {
			[temporaryResults setObject:[theDayCount objectForKey:@"count"]
								 forKey:[theDayCount objectForKey:@"date"]];
		}
		theResult = [NSDictionary dictionaryWithDictionary:temporaryResults];
	}
	return theResult;
}

+ (NSDictionary *)getDayCountsFor:(NSString *)account
					  withJournal:(NSString *)journal
{
	return [self getDayCountsFor:account withJournal:journal error:NULL];
}

+ (NSDictionary *)getEntriesFor:(NSString *)account
					withJournal:(NSString *)journal
						 onDate:(NSCalendarDate *)date
						  error:(NSError **)anError
{
	NSDictionary *theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:@"getevents"
									 forAccount:account
									 withParams:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
												 journal,@"usejournal",
												 @"day",@"selecttype",
												 [NSString stringWithFormat:@"%d",[date yearOfCommonEra]],@"year",
												 [NSString stringWithFormat:@"%d",[date monthOfYear]],@"month",
												 [NSString stringWithFormat:@"%d",[date dayOfMonth]],@"day",
												 @"mac",@"linenedings",
												 @"1",@"noprops",
												 @"1",@"prefersubject",
												 @"200",@"truncate",
												 nil]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		NSArray *eventArray = [theCall objectForKey:@"events"];
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
		theResult = [NSDictionary dictionaryWithDictionary:temporaryResults];
	}
	return theResult;
}

+ (NSDictionary *)getEntriesFor:(NSString *)account
					withJournal:(NSString *)journal
						 onDate:(NSCalendarDate *)date
{
	return [self getEntriesFor:account withJournal:journal onDate:date error:NULL];
}

+ (NSArray *)getTagsFor:(NSString *)account
			withJournal:(NSString *)journal
				  error:(NSError **)anError
{
	NSArray *theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:@"getusertags"
									 forAccount:account
									 withParams:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
												 journal,@"usejournal",
												 nil]
										  error:&myError]; 
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		NSArray *tagsArray = [theCall objectForKey:@"tags"];
		VLOG(@"Got %d tags",[tagsArray count]);
		NSMutableArray *temporaryResults = [NSMutableArray arrayWithCapacity:[tagsArray count]];
		for (id aTag in tagsArray) {
			[temporaryResults addObject:[aTag objectForKey:@"name"]];
		}
		theResult = [NSArray arrayWithArray:temporaryResults];
	}
	return theResult;
}

+ (NSArray *)getTagsFor:(NSString *)account
			withJournal:(NSString *)journal
{
	return [self getTagsFor:account withJournal:journal error:NULL];
}

+ (BOOL)deleteEntryFor:(NSString *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid
				 error:(NSError **)anError
{
	BOOL theResult;
	NSError *myError;
	NSDictionary *theCall =[self convenientCall:@"editevent"
									 forAccount:account
									 withParams:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
												 journal,@"usejournal",
												 itemid,@"itemid",
												 @"",@"event",
												 @"",@"subject",
												 @"mac",@"linenedings",
												 nil]
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

+ (NSString *)getSessionCookieFor:(NSString *)account
							error:(NSError **)anError
{
	NSString *theResult;
	NSError *myError;
	NSDictionary *theCall = [self convenientCall:@"sessiongenerate"
									  forAccount:account
									  withParams:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
												  nil]
										   error:&myError];
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		VLOG(@"Got session cookie.");
		theResult = [NSString stringWithString:[theCall objectForKey:@"ljsession"]];
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
	NSString *server = [[self splitAccountString:account] objectForKey:kasLJCoreAccountServerKey];
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
	NSString *server = [[self splitAccountString:account] objectForKey:kasLJCoreAccountServerKey];
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


+ (NSArray *)getFriendsFor:(NSString *)account
					 error:(NSError **)anError
{
	NSArray *theResult;
	NSError *myError;
	NSDictionary *theCall = [self convenientCall:@"getfriends"
									  forAccount:account
									  withParams:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
												  @"1",@"includebdays",
												  nil]
										   error:&myError];
	if (!theCall) {
		// call failed
		theResult = nil;
		if (anError != NULL) *anError = [[myError copy] autorelease];
	} else {
		// call succeded
		NSArray *friends = [theCall objectForKey:@"friends"];
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
		theResult = [NSArray arrayWithArray:temporaryResults];
		VLOG(@"Got %d friends",[theResult count]);
	}
	return theResult;
}

+ (NSArray *)getFriendsFor:(NSString *)account
{
	return [self getFriendsFor:account error:NULL];
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
