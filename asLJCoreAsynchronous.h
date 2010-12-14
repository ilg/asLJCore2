//
//  asLJCoreAsynchronous.h
//  asLJCore
//
//  Created by Isaac Greenspan on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLRPC/XMLRPCConnectionDelegate.h"
#import "XMLRPC/XMLRPCRequest.h"

typedef enum {
	kasLJCoreAsynchronousMethodIndexGetChallenge,
	kasLJCoreAsynchronousMethodIndexLogin,
	kasLJCoreAsynchronousMethodIndexGetDayCounts,
	kasLJCoreAsynchronousMethodIndexGetEvents,
	kasLJCoreAsynchronousMethodIndexGetUserTags,
	kasLJCoreAsynchronousMethodIndexDeleteEvent,
	kasLJCoreAsynchronousMethodIndexSessionGenerate,
	kasLJCoreAsynchronousMethodIndexGetFriends
} asLJCoreAsynchronousMethodType;

@interface asLJCoreAsynchronous : NSObject <XMLRPCConnectionDelegate> {
	id result;
	id target;
	SEL successAction;
	SEL errorAction;
	
	bool isFault;
	NSString *faultString;
	NSNumber *faultCode;

	@protected
	NSString *connectionIdentifier;
	NSDictionary *accountInfo;
	NSURL *url;
	asLJCoreAsynchronousMethodType methodIndex;
	NSMutableDictionary *paramDict;
	
	asLJCoreAsynchronous *getChallengeObject;
}

@property (retain) id result;
@property (retain) id target;
@property SEL successAction;
@property SEL errorAction;


#pragma mark -
#pragma mark convenience creator methods

+ (asLJCoreAsynchronous *)loginTo:(NSString *)account
						   target:(id)targetObject
					successAction:(SEL)successActionSelector
					  errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)getDayCountsFor:(NSString *)account
							  withJournal:(NSString *)journal
								   target:(id)targetObject
							successAction:(SEL)successActionSelector
							  errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)getEntriesFor:(NSString *)account
							withJournal:(NSString *)journal
								 onDate:(NSCalendarDate *)date
								 target:(id)targetObject
						  successAction:(SEL)successActionSelector
							errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)getTagsFor:(NSString *)account
						 withJournal:(NSString *)journal
							  target:(id)targetObject
					   successAction:(SEL)successActionSelector
						 errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)deleteEntryFor:(NSString *)account
							 withJournal:(NSString *)journal
							  withItemID:(NSString *)itemid
								  target:(id)targetObject
						   successAction:(SEL)successActionSelector
							 errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)getSessionCookieFor:(NSString *)account
									   target:(id)targetObject
								successAction:(SEL)successActionSelector
								  errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)getFriendsFor:(NSString *)account
								 target:(id)targetObject
						  successAction:(SEL)successActionSelector
							errorAction:(SEL)errorActionSelector;


#pragma mark -
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


#pragma mark -
#pragma mark actions

- (void)start;

- (void)cancel;


@end
