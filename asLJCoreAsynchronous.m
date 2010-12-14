//
//  asLJCoreAsynchronous.m
//  asLJCore
//
//  Created by Isaac Greenspan on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "asLJCoreAsynchronous.h"
#import "asLJCore.h"
#import "asLJCoreKeychain.h"
#import "LJxmlrpc.h"
#import "LJMoods.h"


// for internal use (in +splitAccountString: and the results therefrom)
extern NSString * const kasLJCoreAccountUsernameKey;
extern NSString * const kasLJCoreAccountServerKey;

@interface asLJCore (privateInterface)

+ (NSDictionary *)splitAccountString:(NSString *)account;

@end

extern NSString *keychainItemName;



@implementation asLJCoreAsynchronous

@synthesize result;
@synthesize target;
@synthesize successAction;
@synthesize errorAction;


#pragma mark -
#pragma mark convenience creator methods

+ (asLJCoreAsynchronous *)jumpstartWithTarget:(id)targetObject
								successAction:(SEL)successActionSelector
								  errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [[[asLJCoreAsynchronous alloc] init] autorelease];
	[async setTarget:targetObject];
	[async setSuccessAction:successActionSelector];
	[async setErrorAction:errorActionSelector];
	return async;
}

+ (asLJCoreAsynchronous *)loginTo:(NSString *)account
						   target:(id)targetObject
					successAction:(SEL)successActionSelector
					  errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async loginTo:account];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)getDayCountsFor:(NSString *)account
							  withJournal:(NSString *)journal
								   target:(id)targetObject
							successAction:(SEL)successActionSelector
							  errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async getDayCountsFor:account
			   withJournal:journal];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)getEntriesFor:(NSString *)account
							withJournal:(NSString *)journal
								 onDate:(NSCalendarDate *)date
								 target:(id)targetObject
						  successAction:(SEL)successActionSelector
							errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async getEntriesFor:account
			 withJournal:journal
				  onDate:date];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)getTagsFor:(NSString *)account
						 withJournal:(NSString *)journal
							  target:(id)targetObject
					   successAction:(SEL)successActionSelector
						 errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async getTagsFor:account
		  withJournal:journal];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)deleteEntryFor:(NSString *)account
							 withJournal:(NSString *)journal
							  withItemID:(NSString *)itemid
								  target:(id)targetObject
						   successAction:(SEL)successActionSelector
							 errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async deleteEntryFor:account
			  withJournal:journal
			   withItemID:itemid];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)getSessionCookieFor:(NSString *)account
									   target:(id)targetObject
								successAction:(SEL)successActionSelector
								  errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async getSessionCookieFor:account];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)getFriendsFor:(NSString *)account
								 target:(id)targetObject
						  successAction:(SEL)successActionSelector
							errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async getFriendsFor:account];
	[async start];
	return async;
}


#pragma mark -
#pragma mark setup methods

- (NSString *)methodNameForIndex:(asLJCoreAsynchronousMethodType)method
{
	switch (methodIndex) {
		case kasLJCoreAsynchronousMethodIndexGetChallenge:
			return @"LJ.XMLRPC.getchallenge";
			break;
		case kasLJCoreAsynchronousMethodIndexLogin:
			return @"LJ.XMLRPC.login";
			break;
		case kasLJCoreAsynchronousMethodIndexGetDayCounts:
			return @"LJ.XMLRPC.getdaycounts";
			break;
		case kasLJCoreAsynchronousMethodIndexGetEvents:
			return @"LJ.XMLRPC.getevents";
			break;
		case kasLJCoreAsynchronousMethodIndexGetUserTags:
			return @"LJ.XMLRPC.getusertags";
			break;
		case kasLJCoreAsynchronousMethodIndexDeleteEvent:
			return @"LJ.XMLRPC.editevent";
			break;
		case kasLJCoreAsynchronousMethodIndexSessionGenerate:
			return @"LJ.XMLRPC.sessiongenerate";
			break;
		case kasLJCoreAsynchronousMethodIndexGetFriends:
			return @"LJ.XMLRPC.getfriends";
			break;
		default:
			return nil;
			break;
	}
}

- (void)jumpstartForAccount:(NSString *)account
{
	accountInfo = [asLJCore splitAccountString:account];
	url = [NSURL
		   URLWithString:SERVER2URL([accountInfo
									 objectForKey:kasLJCoreAccountServerKey])];
	paramDict = [NSMutableDictionary dictionary];
	[paramDict retain];
}

- (void)loginTo:(NSString *)account
{
	[self jumpstartForAccount:account];
	methodIndex = kasLJCoreAsynchronousMethodIndexLogin;
	paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
				 @"1",@"getpickws",
				 @"1",@"getpickwurls",
				 [LJMoods getHighestMoodIDForServer:[accountInfo objectForKey:kasLJCoreAccountServerKey]],@"getmoods",
				 nil];
	[paramDict retain];
}

- (void)getDayCountsFor:(NSString *)account
			withJournal:(NSString *)journal
{
	[self jumpstartForAccount:account];
	methodIndex = kasLJCoreAsynchronousMethodIndexGetDayCounts;
	paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
				 journal,@"usejournal",
				 nil];
	[paramDict retain];
}

- (void)getEntriesFor:(NSString *)account
		  withJournal:(NSString *)journal
			   onDate:(NSCalendarDate *)date
{
	[self jumpstartForAccount:account];
	methodIndex = kasLJCoreAsynchronousMethodIndexGetEvents;
	paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
				 journal,@"usejournal",
				 @"day",@"selecttype",
				 [NSString stringWithFormat:@"%d",[date yearOfCommonEra]],@"year",
				 [NSString stringWithFormat:@"%d",[date monthOfYear]],@"month",
				 [NSString stringWithFormat:@"%d",[date dayOfMonth]],@"day",
				 @"mac",@"linenedings",
				 @"1",@"noprops",
				 @"1",@"prefersubject",
				 @"200",@"truncate",
				 nil];
	[paramDict retain];
}

- (void)getTagsFor:(NSString *)account
	   withJournal:(NSString *)journal
{
	[self jumpstartForAccount:account];
	methodIndex = kasLJCoreAsynchronousMethodIndexGetUserTags;
	paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
				 journal,@"usejournal",
				 nil];
	[paramDict retain];
}

- (void)deleteEntryFor:(NSString *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid
{
	[self jumpstartForAccount:account];
	methodIndex = kasLJCoreAsynchronousMethodIndexDeleteEvent;
	paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
				 journal,@"usejournal",
				 itemid,@"itemid",
				 @"",@"event",
				 @"",@"subject",
				 @"mac",@"linenedings",
				 nil];
	[paramDict retain];
}

- (void)getSessionCookieFor:(NSString *)account
{
	[self jumpstartForAccount:account];
	methodIndex = kasLJCoreAsynchronousMethodIndexSessionGenerate;
	paramDict = [NSMutableDictionary dictionary];
	[paramDict retain];
}

- (void)getFriendsFor:(NSString *)account
{
	[self jumpstartForAccount:account];
	methodIndex = kasLJCoreAsynchronousMethodIndexGetFriends;
	paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
				 @"1",@"includebdays",
				 nil];
	[paramDict retain];
}


#pragma mark -
#pragma mark challenge callbacks and starter

- (void)gotChallenge
{
	NSString *authChallenge = [getChallengeObject result];
	
	// set response to md5( challenge + md5([password]) )   where md5() returns the hex digest
	NSString *serverFQDN = [accountInfo objectForKey:kasLJCoreAccountServerKey];
	NSString *pwdMD5 = [LJxmlrpc 
						md5:[asLJCoreKeychain getPasswordByLabel:[LJxmlrpc keychainItemName]
													 withAccount:[accountInfo
																  objectForKey:kasLJCoreAccountUsernameKey]
													  withServer:serverFQDN]];
	NSString *authResponse = [LJxmlrpc
							  md5:[NSString
								   stringWithFormat:@"%@%@",
								   authChallenge,
								   pwdMD5
								   ]
							  ];
	[getChallengeObject release];
	/*
	 to [paramDict], we need to add the things that every request should include:
	 'auth_method': 'challenge'
	 'auth_challenge': [challenge]
	 'auth_response': [response]
	 'username': [username]
	 'ver': 1  -- protocol version
	 'clientversion': [pull 'LJversionString' from user defaults]
	 */
	[paramDict addEntriesFromDictionary:[NSDictionary
										 dictionaryWithObjectsAndKeys:
										 @"challenge",@"auth_method",
										 authChallenge,@"auth_challenge",
										 authResponse,@"auth_response",
										 [accountInfo objectForKey:kasLJCoreAccountUsernameKey],@"username",
										 @"1",@"ver",
										 [LJxmlrpc clientVersion],@"clientversion",
										 nil
										 ]];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL:url];
	[request setMethod:[self methodNameForIndex:methodIndex]
		 withParameter:paramDict];

	connectionIdentifier = [[XMLRPCConnectionManager sharedManager]
							spawnConnectionWithXMLRPCRequest:request
							delegate:self];
	[connectionIdentifier retain];
	
	[request release];
	
	[paramDict release];
	paramDict = nil;
}

- (void)challengeError
{
	// FIXME: this is all fake
	isFault = TRUE;
	faultCode = 0;
	faultString = @"";
	
	[[self target] performSelector:[self errorAction]];
}

- (void)getChallenge:(NSString *)server
{
	methodIndex = kasLJCoreAsynchronousMethodIndexGetChallenge;
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL:[NSURL
												  URLWithString:SERVER2URL(server)]];
	[request setMethod:[self methodNameForIndex:kasLJCoreAsynchronousMethodIndexGetChallenge]];
	connectionIdentifier = [[XMLRPCConnectionManager sharedManager]
							spawnConnectionWithXMLRPCRequest:request
							delegate:self];
	[connectionIdentifier retain];
	[request release];
}


#pragma mark -
#pragma mark actions

- (void)start
{
	getChallengeObject = [asLJCoreAsynchronous jumpstartWithTarget:self
													 successAction:@selector(gotChallenge)
													   errorAction:@selector(challengeError)];
	[getChallengeObject retain];
	[getChallengeObject getChallenge:[accountInfo objectForKey:kasLJCoreAccountServerKey]];
}

- (void)cancel
{
	[[[XMLRPCConnectionManager sharedManager] connectionForIdentifier:connectionIdentifier] cancel];
	[connectionIdentifier release];
	connectionIdentifier = nil;
}



#pragma mark -
#pragma mark XMLRPCConnectionDelegate methods
- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	[connectionIdentifier release];
	connectionIdentifier = nil;
	if ([response isFault]) {
		result = nil;
		
		isFault = TRUE;
		faultCode = [response faultCode];
		faultString = NIL2EMPTY([response faultString]);
		
		VLOG(@"Error returned by XMLRPC call (%@): %@",faultCode,faultString);
		[[self target] performSelector:[self errorAction]];
	} else {
		//NSLog(@"Parsed response: %@", [response object]);
		
		NSDictionary *theResponseDict = [LJxmlrpc cleanseUTF8:[NSDictionary
															   dictionaryWithDictionary:[response object]]];
		
		isFault = FALSE;
		
		switch (methodIndex) {
			case kasLJCoreAsynchronousMethodIndexGetChallenge:
				result = [NSString stringWithString:[theResponseDict objectForKey:@"challenge"]];
				break;
			case kasLJCoreAsynchronousMethodIndexLogin:
			{
				VLOG(@"... logged in.");
				NSArray *newMoods = [theResponseDict objectForKey:kasLJCoreLJLoginMoodsKey];
				NSMutableArray *newMoodStrings = [NSMutableArray arrayWithCapacity:[newMoods count]];
				NSMutableArray *newMoodIDs = [NSMutableArray arrayWithCapacity:[newMoods count]];
				for (id theNewMood in newMoods) {
					[newMoodStrings addObject:[theNewMood objectForKey:@"name"]];
					[newMoodIDs addObject:[theNewMood objectForKey:@"id"]];
				}
				[LJMoods addNewMoods:newMoodStrings
							 withIDs:newMoodIDs
						   forServer:[accountInfo objectForKey:kasLJCoreAccountServerKey]];
				result = theResponseDict;
			}
				break;
			case kasLJCoreAsynchronousMethodIndexGetDayCounts:
			{
				NSArray *dayCountArray = [theResponseDict objectForKey:@"daycounts"];
				VLOG(@"Got counts for %d days",[dayCountArray count]);
				NSMutableDictionary *temporaryResults = [NSMutableDictionary dictionaryWithCapacity:[dayCountArray count]];
				for (id theDayCount in dayCountArray) {
					[temporaryResults setObject:[theDayCount objectForKey:@"count"]
										 forKey:[theDayCount objectForKey:@"date"]];
				}
				result = [NSDictionary dictionaryWithDictionary:temporaryResults];
			}
				break;
			case kasLJCoreAsynchronousMethodIndexGetEvents:
			{
				NSArray *eventArray = [theResponseDict objectForKey:@"events"];
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
				result = [NSDictionary dictionaryWithDictionary:temporaryResults];
			}
				break;
			case kasLJCoreAsynchronousMethodIndexGetUserTags:
			{
				NSArray *tagsArray = [theResponseDict objectForKey:@"tags"];
				VLOG(@"Got %d tags",[tagsArray count]);
				NSMutableArray *temporaryResults = [NSMutableArray arrayWithCapacity:[tagsArray count]];
				for (id aTag in tagsArray) {
					[temporaryResults addObject:[aTag objectForKey:@"name"]];
				}
				result = [NSArray arrayWithArray:temporaryResults];
			}
				break;
			case kasLJCoreAsynchronousMethodIndexDeleteEvent:
			{
				VLOG(@"... entry deleted.");
				result = [NSNumber numberWithBool:YES];
			}
				break;
			case kasLJCoreAsynchronousMethodIndexSessionGenerate:
			{
				VLOG(@"Got session cookie.");
				result = [NSString stringWithString:[theResponseDict objectForKey:@"ljsession"]];
			}
				break;
			case kasLJCoreAsynchronousMethodIndexGetFriends:
			{
				NSArray *friends = [theResponseDict objectForKey:@"friends"];
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
				result = [NSArray arrayWithArray:temporaryResults];
				VLOG(@"Got %d friends",[result count]);
			}
				break;
			default:
				result = nil;
				break;
		}
		[result retain];
		// FIXME: rearrange the stuff in theResponseDict into the method-specific desired response
		
		//	NSLog(@"%@",self);
		//	NSLog(@"Done with call, returning...");
		[[self target] performSelector:[self successAction]];
	}
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	[connectionIdentifier release];
	connectionIdentifier = nil;
	result = nil;
	
	// FIXME: this is all fake
	isFault = TRUE;
	faultCode = 0;
	faultString = @"";
	[[self target] performSelector:[self errorAction]];
}

- (BOOL)request: (XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace
{
	return NO;  // FIXME: just here to supress warning
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
}


@end
