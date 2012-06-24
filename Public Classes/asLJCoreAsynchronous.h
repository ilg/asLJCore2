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
//  asLJCoreAsynchronous.h
//  asLJCore
//
//  Created by Isaac Greenspan on 12/13/10.
//

#import <Cocoa/Cocoa.h>
#import "XMLRPC/XMLRPCConnectionDelegate.h"
#import "XMLRPC/XMLRPCRequest.h"

@class LJPastEntry;
@class LJNewEntry;

typedef enum {
	kasLJCoreAsynchronousMethodIndexGetChallenge,
	kasLJCoreAsynchronousMethodIndexLogin,
	kasLJCoreAsynchronousMethodIndexGetDayCounts,
	kasLJCoreAsynchronousMethodIndexGetEvents,
	kasLJCoreAsynchronousMethodIndexGetUserTags,
	kasLJCoreAsynchronousMethodIndexDeleteEvent,
	kasLJCoreAsynchronousMethodIndexSessionGenerate,
	kasLJCoreAsynchronousMethodIndexGetFriends,
	
	// for LJEntry:
	kasLJCoreAsynchronousMethodIndexEntryPost,
	kasLJCoreAsynchronousMethodIndexEntryEdit,
	kasLJCoreAsynchronousMethodIndexEntryGet,
} asLJCoreAsynchronousMethodType;

@interface asLJCoreAsynchronous : NSObject <XMLRPCConnectionDelegate> {
	id result;
	
	bool isFault;
	NSString *faultString;
	NSNumber *faultCode;
}

@property (readonly,retain) id result;

@property (readonly) bool isFault;
@property (readonly,retain) NSString *faultString;
@property (readonly,retain) NSNumber *faultCode;


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

+ (asLJCoreAsynchronous *)getLJPastEntryWithItemid:(NSNumber *)theItemid
										forJournal:(NSString *)theJournal
										forAccount:(NSString *)theAccount
										fromServer:(NSString *)theServer
											target:(id)targetObject
									 successAction:(SEL)successActionSelector
									   errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)saveLJPastEntry:(LJPastEntry *)theEntry
								   target:(id)targetObject
							successAction:(SEL)successActionSelector
							  errorAction:(SEL)errorActionSelector;

+ (asLJCoreAsynchronous *)postLJNewEntry:(LJNewEntry *)theEntry
								  target:(id)targetObject
						   successAction:(SEL)successActionSelector
							 errorAction:(SEL)errorActionSelector;


#pragma mark -
#pragma mark actions

- (void)cancel;


@end
