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
//  asLJCoreAsynchronous.m
//  asLJCore
//
//  Created by Isaac Greenspan on 12/13/10.
//

#import "asLJCoreAsynchronous.h"
#import "asLJCore.h"
#import "asLJCoreKeychain.h"
#import "LJxmlrpc.h"
#import "LJMoods.h"
#import "NSString+MD5.h"


// for internal use (in +splitAccountString: and the results therefrom)
extern NSString * const kasLJCoreAccountUsernameKey;
extern NSString * const kasLJCoreAccountServerKey;

@interface asLJCore ()
+ (NSDictionary *)splitAccountString:(NSString *)account;
@end

@interface asLJCoreAsynchronous () {
	id target;
	SEL successAction;
	SEL errorAction;
@protected
	NSString *connectionIdentifier;
	NSDictionary *accountInfo;
	NSURL *url;
	asLJCoreAsynchronousMethodType methodIndex;
	NSMutableDictionary *paramDict;
	
	asLJCoreAsynchronous *challengeGettingObject;
}
@property (retain) id target;
@property SEL successAction;
@property SEL errorAction;
@property (retain) asLJCoreAsynchronous *challengeGettingObject;
@property bool isFault;
@property (retain) NSString *faultString;
@property (retain) NSNumber *faultCode;
- (void)setFaultWithCode:(NSNumber *)code
				  string:(NSString *)string;
#pragma mark setup methods
- (void)loginTo:(NSString *)account;
- (void)getDayCountsFor:(NSString *)account
			withJournal:(NSString *)journal;
- (void)getEntriesFor:(NSString *)account
		  withJournal:(NSString *)journal
			   onDate:(NSCalendarDate *)date;
- (void)getTagsFor:(NSString *)account
	   withJournal:(NSString *)journal;
- (void)deleteEntryFor:(NSString *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid;
- (void)getSessionCookieFor:(NSString *)account;
- (void)getFriendsFor:(NSString *)account;
- (void)getLJPastEntryWithItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer;
- (void)saveLJPastEntry:(LJPastEntry *)theEntry;
- (void)postLJNewEntry:(LJNewEntry *)theEntry;
#pragma mark actions
- (void)start;
@end



extern NSString *keychainItemName;



@implementation asLJCoreAsynchronous

@synthesize result;
@synthesize target;
@synthesize successAction;
@synthesize errorAction;
@synthesize challengeGettingObject;

@synthesize isFault;
@synthesize faultString;
@synthesize faultCode;


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

+ (asLJCoreAsynchronous *)getLJPastEntryWithItemid:(NSNumber *)theItemid
										forJournal:(NSString *)theJournal
										forAccount:(NSString *)theAccount
										fromServer:(NSString *)theServer
											target:(id)targetObject
									 successAction:(SEL)successActionSelector
									   errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async getLJPastEntryWithItemid:theItemid
						 forJournal:theJournal
						 forAccount:theAccount
						 fromServer:theServer];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)saveLJPastEntry:(LJPastEntry *)theEntry
								   target:(id)targetObject
							successAction:(SEL)successActionSelector
							  errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async saveLJPastEntry:theEntry];
	[async start];
	return async;
}

+ (asLJCoreAsynchronous *)postLJNewEntry:(LJNewEntry *)theEntry
								  target:(id)targetObject
						   successAction:(SEL)successActionSelector
							 errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async postLJNewEntry:theEntry];
	[async start];
	return async;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	// release retained properties
	[result release];
	[target release];
	[faultString release];
	[faultCode release];
	[challengeGettingObject release];
	
	[super dealloc];
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
		case kasLJCoreAsynchronousMethodIndexEntryPost:
			return @"LJ.XMLRPC.postevent";
			break;
		case kasLJCoreAsynchronousMethodIndexEntryEdit:
			return @"LJ.XMLRPC.editevent";
			break;
		case kasLJCoreAsynchronousMethodIndexEntryGet:
			return @"LJ.XMLRPC.getevents";
			break;
		default:
			return nil;
			break;
	}
}

- (void)jumpstartForAccount:(NSString *)account
{
	accountInfo = [[asLJCore splitAccountString:account]
				   retain];
	url = [NSURL
		   URLWithString:SERVER2URL([accountInfo
									 objectForKey:kasLJCoreAccountServerKey])];
	[url retain];
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

- (void)getLJPastEntryWithItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer
{
	[self jumpstartForAccount:[NSString stringWithFormat:@"%@@%@",
							   theAccount, theServer]];
	methodIndex = kasLJCoreAsynchronousMethodIndexEntryGet;
	paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: // (value, key); end with nil
				 @"one",@"selecttype",
				 theJournal,@"usejournal",
				 theItemid,@"itemid",
				 @"mac",@"lineendings",
				 nil];
	[paramDict retain];
}

- (void)saveLJPastEntry:(LJPastEntry *)theEntry
{
	[self jumpstartForAccount:[NSString stringWithFormat:@"%@@%@",
							   [theEntry account],
							   [theEntry server]]];
	methodIndex = kasLJCoreAsynchronousMethodIndexEntryEdit;
	paramDict = [NSMutableDictionary dictionaryWithDictionary:[theEntry getEntryAsDictionary]];
	[paramDict setObject:@"mac" forKey:@"lineendings"];
	[paramDict setObject:[theEntry itemid] forKey:@"itemid"];
	[paramDict retain];
}

- (void)postLJNewEntry:(LJNewEntry *)theEntry
{
	[self jumpstartForAccount:[NSString stringWithFormat:@"%@@%@",
							   [theEntry account],
							   [theEntry server]]];
	methodIndex = kasLJCoreAsynchronousMethodIndexEntryPost;
	paramDict = [NSMutableDictionary dictionaryWithDictionary:[theEntry getEntryAsDictionary]];
	[paramDict setObject:@"mac" forKey:@"lineendings"];
	[paramDict retain];
}


#pragma mark -
#pragma mark challenge callbacks and starter

- (void)challengeError
{
	// FIXME: this is all fake
	[self setFaultWithCode:nil
					string:nil];
	
	[[self target] performSelector:[self errorAction]];
}

- (void)gotChallenge
{
	NSString *authChallenge = [[self challengeGettingObject] result];
	[self setChallengeGettingObject:nil];
	
	if (!authChallenge) {
		// something went wrong and though we got a valid XML-RPC response, it didn't contain the challenge as expected
		// TODO: may need to set some error info in here
		[self challengeError];
	} else {
		// set response to md5( challenge + md5([password]) )   where md5() returns the hex digest
		NSString *serverFQDN = [accountInfo objectForKey:kasLJCoreAccountServerKey];
		NSString *pwdMD5 = [[asLJCoreKeychain getPasswordByLabel:[LJxmlrpc keychainItemName]
                                                     withAccount:[accountInfo
                                                                  objectForKey:kasLJCoreAccountUsernameKey]
                                                      withServer:serverFQDN]
                            md5];
		NSString *authResponse = [NSString md5WithFormat:@"%@%@",
                                  authChallenge, pwdMD5];
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
	}
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
	VLOG(@"Calling method %@ for %@@%@...",
		 [self methodNameForIndex:methodIndex],
		 [accountInfo objectForKey:kasLJCoreAccountUsernameKey],
		 [url absoluteString]);
	[self setChallengeGettingObject:[asLJCoreAsynchronous jumpstartWithTarget:self
																successAction:@selector(gotChallenge)
																  errorAction:@selector(challengeError)]];
	[[self challengeGettingObject] getChallenge:[accountInfo objectForKey:kasLJCoreAccountServerKey]];
}

- (void)cancel
{
	[[self challengeGettingObject] cancel];
	
	[[[XMLRPCConnectionManager sharedManager] connectionForIdentifier:connectionIdentifier] cancel];
	[connectionIdentifier release];
	connectionIdentifier = nil;
	
	[paramDict release];
	paramDict = nil;
	
	[self setTarget:nil];
}


#pragma mark -
#pragma mark convenience setter methods

- (void)setFaultWithCode:(NSNumber *)code
				  string:(NSString *)string
{
	if (!code) code = [NSNumber numberWithInt:0];
	string = NIL2EMPTY(string);
	[self setIsFault:YES];
	[self setFaultCode:code];
	[self setFaultString:string];
}

#pragma mark -
#pragma mark XMLRPCConnectionDelegate methods
- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	[connectionIdentifier release];
	connectionIdentifier = nil;
	if ([response isFault]) {
		result = nil;
		
		[self setFaultWithCode:[response faultCode]
						string:[response faultString]];
		
		VLOG(@"Error returned by XMLRPC call (%@): %@",faultCode,faultString);
		[[self target] performSelector:[self errorAction]];
	} else {
		//NSLog(@"Parsed response: %@", [response object]);
		
		NSDictionary *theResponseDict = [LJxmlrpc cleanseUTF8:[NSDictionary
															   dictionaryWithDictionary:[response object]]];
		
		[self setIsFault:NO];
		
		switch (methodIndex) {
			case kasLJCoreAsynchronousMethodIndexGetChallenge:
			{
				NSString *challenge = [theResponseDict objectForKey:@"challenge"];
				if (challenge) {
					result = [NSString stringWithString:challenge];
				} else {
					result = nil;
					[self setFaultWithCode:nil
									string:@"GetChallenge failed."];
					VLOG(@"GetChallenge failed (response dictionary: %@)", theResponseDict);
				}
			}
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
				NSString *ljsession = [theResponseDict objectForKey:@"ljsession"];
				if (ljsession) {
					result = [NSString stringWithString:ljsession];
					VLOG(@"Got session cookie.");
				} else {
					result = nil;
					[self setFaultWithCode:nil
									string:@"Failed to get session cookie."];
					VLOG(@"Failed to get session cookie (response dictionary: %@)", theResponseDict);
				}
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
			case kasLJCoreAsynchronousMethodIndexEntryGet:
			{
				// extract the one event we want and its metadata "props"
				NSMutableDictionary *theEvent = [NSMutableDictionary dictionaryWithDictionary:
												 [[theResponseDict objectForKey:@"events"] lastObject]];
				
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
				
				result = [[LJPastEntry alloc] init];
				[result setItemid:[paramDict objectForKey:@"itemid"]];
				[result setUsejournal:[paramDict objectForKey:@"usejournal"]];
				[result setAccount:[accountInfo objectForKey:kasLJCoreAccountUsernameKey]];
				[result setServer:[accountInfo objectForKey:kasLJCoreAccountServerKey]];
				[result setEntryFromDictionary:theEvent];
			}
				break;
			case kasLJCoreAsynchronousMethodIndexEntryEdit: // same as ...Post
			case kasLJCoreAsynchronousMethodIndexEntryPost:
			{
				NSString *postURL = [theResponseDict objectForKey:@"url"];
				if (postURL) {
					result = [NSString stringWithString:postURL];
				} else {
					result = nil;
				}
			}
				break;
			default:
			{
				result = nil;
				[self setFaultWithCode:nil
								string:@"Unknown method index in [asLJCoreAsynchronous request:didReceiveResponse:]."];
				VLOG(@"Unknown method index in [asLJCoreAsynchronous request:didReceiveResponse:].");
			}
				break;
		}
		[result retain];
		//	NSLog(@"%@",self);
		//	NSLog(@"Done with call, returning...");
		if ([self isFault]) {
			[[self target] performSelector:[self errorAction]];
		} else {
			[[self target] performSelector:[self successAction]];
		}
	}
	
	[paramDict release];
	paramDict = nil;
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	[connectionIdentifier release];
	connectionIdentifier = nil;
	result = nil;
	
	// FIXME: this is all fake
	[self setFaultWithCode:nil
					string:nil];
	[[self target] performSelector:[self errorAction]];
	
	[paramDict release];
	paramDict = nil;
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
