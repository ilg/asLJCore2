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
#import "LJxmlrpc2.h"
#import "LJMoods.h"
#import "LJaccount.h"
#import "NSString+MD5.h"


@interface asLJCoreAsynchronous ()

@property (readwrite, copy) void(^successBlock)(NSDictionary *result);
@property (readwrite, copy) void(^failureBlock)(NSError *error);

@property (retain) LJxmlrpc2 *currentCall;

@property (retain) id result;
@property bool isFault;
@property (retain) NSString *faultString;
@property (retain) NSNumber *faultCode;
- (void)setFaultWithCode:(NSNumber *)code
				  string:(NSString *)string;
#pragma mark setup methods
- (void)loginTo:(LJaccount *)account;
- (void)getDayCountsFor:(LJaccount *)account
			withJournal:(NSString *)journal;
- (void)getEntriesFor:(LJaccount *)account
		  withJournal:(NSString *)journal
			   onDate:(NSCalendarDate *)date;
- (void)getTagsFor:(LJaccount *)account
	   withJournal:(NSString *)journal;
- (void)deleteEntryFor:(LJaccount *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid;
- (void)getSessionCookieFor:(LJaccount *)account;
- (void)getFriendsFor:(LJaccount *)account;
- (void)getLJPastEntryWithItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer;
- (void)saveLJPastEntry:(LJPastEntry *)theEntry;
- (void)postLJNewEntry:(LJNewEntry *)theEntry;
@end



extern NSString *keychainItemName;



@implementation asLJCoreAsynchronous

@synthesize result = _result;

@synthesize successBlock = _successBlock;
@synthesize failureBlock = _failureBlock;

@synthesize isFault = _isFault;
@synthesize faultString = _faultString;
@synthesize faultCode = _faultCode;
@synthesize currentCall = _currentCall;

#pragma mark -
#pragma mark convenience creator methods

+ (asLJCoreAsynchronous *)jumpstartWithTarget:(id)targetObject
								successAction:(SEL)successActionSelector
								  errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [[asLJCoreAsynchronous alloc] init];
    [async setSuccessBlock:^(NSDictionary *result) {
        [targetObject performSelector:successActionSelector];
    }];
    [async setFailureBlock:^(NSError *error) {
        [targetObject performSelector:errorActionSelector];
    }];
	return [async autorelease];
}

+ (asLJCoreAsynchronous *)loginTo:(NSString *)account
						   target:(id)targetObject
					successAction:(SEL)successActionSelector
					  errorAction:(SEL)errorActionSelector
{
	asLJCoreAsynchronous *async = [asLJCoreAsynchronous jumpstartWithTarget:targetObject
															  successAction:successActionSelector
																errorAction:errorActionSelector];
	[async loginTo:[LJaccount accountFromString:account]];
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
	[async getDayCountsFor:[LJaccount accountFromString:account]
			   withJournal:journal];
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
	[async getEntriesFor:[LJaccount accountFromString:account]
			 withJournal:journal
				  onDate:date];
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
	[async getTagsFor:[LJaccount accountFromString:account]
		  withJournal:journal];
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
	[async deleteEntryFor:[LJaccount accountFromString:account]
			  withJournal:journal
			   withItemID:itemid];
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
	[async getSessionCookieFor:[LJaccount accountFromString:account]];
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
	[async getFriendsFor:[LJaccount accountFromString:account]];
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
	return async;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	// release retained properties
	[_result release];
	[_faultString release];
	[_faultCode release];
    [_currentCall release];
    [_successBlock release];
    [_failureBlock release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark setup methods

- (NSString *)methodNameForIndex:(asLJCoreAsynchronousMethodType)method
{
	switch (method) {
		case kasLJCoreAsynchronousMethodIndexGetChallenge:
			return @"getchallenge";
			break;
		case kasLJCoreAsynchronousMethodIndexLogin:
			return @"login";
			break;
		case kasLJCoreAsynchronousMethodIndexGetDayCounts:
			return @"getdaycounts";
			break;
		case kasLJCoreAsynchronousMethodIndexGetEvents:
			return @"getevents";
			break;
		case kasLJCoreAsynchronousMethodIndexGetUserTags:
			return @"getusertags";
			break;
		case kasLJCoreAsynchronousMethodIndexDeleteEvent:
			return @"editevent";
			break;
		case kasLJCoreAsynchronousMethodIndexSessionGenerate:
			return @"sessiongenerate";
			break;
		case kasLJCoreAsynchronousMethodIndexGetFriends:
			return @"getfriends";
			break;
		case kasLJCoreAsynchronousMethodIndexEntryPost:
			return @"postevent";
			break;
		case kasLJCoreAsynchronousMethodIndexEntryEdit:
			return @"editevent";
			break;
		case kasLJCoreAsynchronousMethodIndexEntryGet:
			return @"getevents";
			break;
		default:
			return nil;
			break;
	}
}

- (void)success:(NSDictionary *)result {
    [self successBlock](result);
}
- (void)failure:(NSError *)error {
    [self setFaultWithCode:[NSNumber numberWithInteger:[error code]]
                    string:[error localizedDescription]];
    
    VLOG(@"Error returned by XMLRPC call (%@): %@", [self faultCode], [self faultString]);
    [self failureBlock](error);
}


- (void)jumpstartForAccount:(LJaccount *)account
                     method:(asLJCoreAsynchronousMethodType)method
                 parameters:(NSDictionary *)parameters
                    success:(void(^)(NSDictionary *result))successBlock_
{
    void(^oldSuccessBlock)(NSDictionary *result) = [[self successBlock] copy];
    [self setSuccessBlock:^(NSDictionary *result) {
        successBlock_(result);
        oldSuccessBlock(result);
        [oldSuccessBlock release];
    }];
    [self setCurrentCall:
     [LJxmlrpc2 asynchronousCallMethod:[self methodNameForIndex:method]
                        withParameters:parameters
                                 atUrl:SERVER2URL([account server])
                               forUser:[account username]
                               success:^(NSDictionary *result) {
                                   [self success:result];
                               }
                               failure:^(NSError *error) {
                                   [self failure:error];
                               }]
     ];
}

- (void)loginTo:(LJaccount *)account
{
	[self jumpstartForAccount:account
                       method:kasLJCoreAsynchronousMethodIndexLogin
                   parameters:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
                               @"1",@"getpickws",
                               @"1",@"getpickwurls",
                               [LJMoods getHighestMoodIDForServer:[account server]],@"getmoods",
                               nil]
                      success:^(NSDictionary *result) {
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
                          [self setResult:result];
                      }];
}

- (void)getDayCountsFor:(LJaccount *)account
			withJournal:(NSString *)journal
{
	[self jumpstartForAccount:account
                       method:kasLJCoreAsynchronousMethodIndexGetDayCounts
                   parameters:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
                               journal,@"usejournal",
                               nil]
                      success:^(NSDictionary *result) {
                          NSArray *dayCountArray = [result objectForKey:@"daycounts"];
                          VLOG(@"Got counts for %d days", [dayCountArray count]);
                          NSMutableDictionary *temporaryResults = [NSMutableDictionary dictionaryWithCapacity:[dayCountArray count]];
                          for (id theDayCount in dayCountArray) {
                              [temporaryResults setObject:[theDayCount objectForKey:@"count"]
                                                   forKey:[theDayCount objectForKey:@"date"]];
                          }
                          [self setResult:[NSDictionary dictionaryWithDictionary:temporaryResults]];
                      }];
}

- (void)getEntriesFor:(LJaccount *)account
		  withJournal:(NSString *)journal
			   onDate:(NSCalendarDate *)date
{
	[self jumpstartForAccount:account
                       method:kasLJCoreAsynchronousMethodIndexGetEvents
                   parameters:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
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
                      success:^(NSDictionary *result) {
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
                          [self setResult:[NSDictionary dictionaryWithDictionary:temporaryResults]];
                      }];
}

- (void)getTagsFor:(LJaccount *)account
	   withJournal:(NSString *)journal
{
	[self jumpstartForAccount:account
                       method:kasLJCoreAsynchronousMethodIndexGetUserTags
                   parameters:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
                               journal,@"usejournal",
                               nil]
                      success:^(NSDictionary *result) {
                          NSArray *tagsArray = [result objectForKey:@"tags"];
                          VLOG(@"Got %d tags",[tagsArray count]);
                          NSMutableArray *temporaryResults = [NSMutableArray arrayWithCapacity:[tagsArray count]];
                          for (id aTag in tagsArray) {
                              [temporaryResults addObject:[aTag objectForKey:@"name"]];
                          }
                          [self setResult:[NSArray arrayWithArray:temporaryResults]];
                      }];
}

- (void)deleteEntryFor:(LJaccount *)account
		   withJournal:(NSString *)journal
			withItemID:(NSString *)itemid
{
	[self jumpstartForAccount:account
                       method:kasLJCoreAsynchronousMethodIndexDeleteEvent
                   parameters:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
                               journal,@"usejournal",
                               itemid,@"itemid",
                               @"",@"event",
                               @"",@"subject",
                               @"mac",@"linenedings",
                               nil]
                      success:^(NSDictionary *result) {
                          VLOG(@"... entry deleted.");
                          [self setResult:[NSNumber numberWithBool:YES]];
                      }];
}

- (void)getSessionCookieFor:(LJaccount *)account
{
	[self jumpstartForAccount:account
                       method:kasLJCoreAsynchronousMethodIndexSessionGenerate
                   parameters:[NSDictionary dictionary]
                      success:^(NSDictionary *result) {
                          NSString *ljsession = [result objectForKey:@"ljsession"];
                          if (!ljsession) {
                              [self setResult:nil];
                              [self setFaultWithCode:nil
                                              string:@"Failed to get session cookie."];
                              VLOG(@"Failed to get session cookie (response dictionary: %@)", result);
                              [self failure:nil];  // FIXME: use a proper NSError here
                              return;
                          }
                          [self setResult:[NSString stringWithString:ljsession]];
                          VLOG(@"Got session cookie.");
                      }];
}

- (void)getFriendsFor:(LJaccount *)account
{
	[self jumpstartForAccount:account
                       method:kasLJCoreAsynchronousMethodIndexGetFriends
                   parameters:[NSDictionary dictionaryWithObjectsAndKeys:// (value,key), nil to end
                               @"1",@"includebdays",
                               nil]
                      success:^(NSDictionary *result) {
                          NSArray *friends = [result objectForKey:@"friends"];
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
                          [self setResult:[NSArray arrayWithArray:temporaryResults]];
                          VLOG(@"Got %d friends",[[self result] count]);
                      }];
}

- (void)getLJPastEntryWithItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer
{
	[self jumpstartForAccount:[LJaccount accountWithUsername:theAccount
                                                    atServer:theServer]
                       method:kasLJCoreAsynchronousMethodIndexEntryGet
                   parameters:[NSDictionary dictionaryWithObjectsAndKeys: // (value, key); end with nil
                               @"one",@"selecttype",
                               theJournal,@"usejournal",
                               theItemid,@"itemid",
                               @"mac",@"lineendings",
                               nil]
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
                          [entry setItemid:theItemid];
                          [entry setUsejournal:theJournal];
                          [entry setAccount:theAccount];
                          [entry setServer:theServer];
                          [entry setEntryFromDictionary:theEvent];
                          [self setResult:entry];
                          [entry release];
                      }];
}

- (void)saveLJPastEntry:(LJPastEntry *)theEntry
{
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:[theEntry getEntryAsDictionary]];
	[paramDict setObject:@"mac" forKey:@"lineendings"];
	[paramDict setObject:[theEntry itemid] forKey:@"itemid"];
	[self jumpstartForAccount:[LJaccount accountWithUsername:[theEntry account]
                                                    atServer:[theEntry server]]
                       method:kasLJCoreAsynchronousMethodIndexEntryEdit
                   parameters:paramDict
                      success:^(NSDictionary *result) {
                          NSString *postURL = [result objectForKey:@"url"];
                          if (postURL) {
                              [self setResult:[NSString stringWithString:postURL]];
                          } else {
                              [self setResult:nil];
                          }
                      }];
}

- (void)postLJNewEntry:(LJNewEntry *)theEntry
{
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:[theEntry getEntryAsDictionary]];
	[paramDict setObject:@"mac" forKey:@"lineendings"];
	[self jumpstartForAccount:[LJaccount accountWithUsername:[theEntry account]
                                                    atServer:[theEntry server]]
                       method:kasLJCoreAsynchronousMethodIndexEntryPost
                   parameters:paramDict
                      success:^(NSDictionary *result) {
                          NSString *postURL = [result objectForKey:@"url"];
                          if (postURL) {
                              [self setResult:[NSString stringWithString:postURL]];
                          } else {
                              [self setResult:nil];
                          }
                      }];
}



#pragma mark -
#pragma mark actions

- (void)cancel
{
    [[self currentCall] cancel];
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

@end
