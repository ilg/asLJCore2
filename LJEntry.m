//
//  LJEntry.m
//  asLJFramework
//
//  Created by Isaac Greenspan on 5/20/09.
//

/*** BEGIN LICENSE TEXT ***
 
 Copyright (c) 2009, Isaac Greenspan
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 *** END LICENSE TEXT ***/

#import "LJEntry.h"
#import "LJxmlrpc.h"

@implementation LJEntry

@synthesize account, server, event, subject, security, allowmask, year, mon, day,
			hour, min, usejournal, current_location, current_mood, current_moodid,
			current_music, opt_backdated, picture_keyword, taglist, opt_nocomments,
			opt_noemail, opt_screening, opt_preformatted,
			entryURL, isFault, faultCode, faultString;

- (LJEntry *) init
{
	self = [super init];

	if (self) {
		isFault = FALSE;
	}
	
	return self;
}

- (NSDictionary *) getEntryAsDictionary;
{
	// build the metadata "props" dictionary
	NSMutableDictionary *entryMetadata = [NSMutableDictionary dictionaryWithCapacity:1];
	if (current_location) [entryMetadata setObject:current_location forKey:@"current_location"];
	if (current_mood) [entryMetadata setObject:current_mood forKey:@"current_mood"];
	if (current_moodid) [entryMetadata setObject:[current_moodid stringValue] forKey:@"current_moodid"];
	if (current_music) [entryMetadata setObject:current_music forKey:@"current_music"];
	if (opt_backdated) [entryMetadata setObject:[opt_backdated stringValue] forKey:@"opt_backdated"];
	if (picture_keyword) [entryMetadata setObject:picture_keyword forKey:@"picture_keyword"];
	if (taglist) [entryMetadata setObject:taglist forKey:@"taglist"];
	if (opt_nocomments) [entryMetadata setObject:[opt_nocomments stringValue] forKey:@"opt_nocomments"];
	if (opt_noemail) [entryMetadata setObject:[opt_noemail stringValue] forKey:@"opt_noemail"];
	if (opt_screening) [entryMetadata setObject:opt_screening forKey:@"opt_screening"];
	if (opt_preformatted) [entryMetadata setObject:[opt_preformatted stringValue] forKey:@"opt_preformatted"];

	NSMutableDictionary *theEntry = [NSMutableDictionary dictionaryWithCapacity:1];
	if (event) [theEntry setObject:event forKey:@"event"];
	if (subject) [theEntry setObject:subject forKey:@"subject"];
	if (security) [theEntry setObject:security forKey:@"security"];
	if (allowmask) [theEntry setObject:[allowmask stringValue] forKey:@"allowmask"];
	if (usejournal) [theEntry setObject:usejournal forKey:@"usejournal"];
	if (year) [theEntry setObject:[year stringValue] forKey:@"year"];
	if (mon) [theEntry setObject:[mon stringValue] forKey:@"mon"];
	if (day) [theEntry setObject:[day stringValue] forKey:@"day"];
	if (hour) [theEntry setObject:[hour stringValue] forKey:@"hour"];
	if (min) [theEntry setObject:[min stringValue] forKey:@"min"];
	[theEntry setObject:[NSDictionary dictionaryWithDictionary:entryMetadata] forKey:@"props"];

	return [NSDictionary dictionaryWithDictionary:theEntry];
}

- (void) setEntryFromDictionary:(NSDictionary *)theDictionary;
{
	NSDictionary *theProps = [theDictionary objectForKey:@"props"];
	
	// pull from the event
	[self setEvent:[theDictionary objectForKey:@"event"]];
	if (![event isKindOfClass:[NSString class]]) [self setEvent:[(id)event stringValue]];
	[self setSubject:[theDictionary objectForKey:@"subject"]];
	if (![subject isKindOfClass:[NSString class]]) [self setSubject:[(id)subject stringValue]];
	[self setSecurity:[theDictionary objectForKey:@"security"]];
	[self setAllowmask:[NSNumber numberWithInteger:[[theDictionary objectForKey:@"allowmask"] integerValue]]];
	[self setUsejournal:[theDictionary objectForKey:@"usejournal"]];
	[self setYear:[NSNumber numberWithInteger:[[theDictionary objectForKey:@"year"] integerValue]]];
	[self setMon:[NSNumber numberWithInteger:[[theDictionary objectForKey:@"mon"] integerValue]]];
	[self setDay:[NSNumber numberWithInteger:[[theDictionary objectForKey:@"day"] integerValue]]];
	[self setHour:[NSNumber numberWithInteger:[[theDictionary objectForKey:@"hour"] integerValue]]];
	[self setMin:[NSNumber numberWithInteger:[[theDictionary objectForKey:@"min"] integerValue]]];
	
	// pull from the metadata
	[self setCurrent_location:[theProps objectForKey:@"current_location"]];
	if (![current_location isKindOfClass:[NSString class]]) [self setCurrent_location:[(id)current_location stringValue]];
	[self setCurrent_mood:[theProps objectForKey:@"current_mood"]];
	if (![current_mood isKindOfClass:[NSString class]]) [self setCurrent_mood:[(id)current_mood stringValue]];
	[self setCurrent_moodid:[NSNumber numberWithInteger:[[theProps objectForKey:@"current_moodid"] integerValue]]];
	[self setCurrent_music:[theProps objectForKey:@"current_music"]];
	if (![current_music isKindOfClass:[NSString class]]) [self setCurrent_music:[(id)current_music stringValue]];
	[self setOpt_backdated:[NSNumber numberWithBool:[[theProps objectForKey:@"opt_backdated"] boolValue]]];
	[self setPicture_keyword:[theProps objectForKey:@"picture_keyword"]];
	[self setTaglist:[theProps objectForKey:@"taglist"]];
	if (![taglist isKindOfClass:[NSString class]]) [self setTaglist:[(id)taglist stringValue]];
	[self setOpt_nocomments:[NSNumber numberWithBool:[[theProps objectForKey:@"opt_nocomments"] boolValue]]];
	[self setOpt_noemail:[NSNumber numberWithBool:[[theProps objectForKey:@"opt_noemail"] boolValue]]];
	[self setOpt_screening:[theProps objectForKey:@"opt_screening"]];
	[self setOpt_preformatted:[NSNumber numberWithBool:[[theProps objectForKey:@"opt_preformatted"] boolValue]]];
}

- (BOOL) saveEntryToFile:(NSString *)theFilename;
{
	return [[self getEntryAsDictionary] 
			writeToFile:theFilename
			atomically:YES];
}

- (BOOL) loadEntryFromFile:(NSString *)theFilename
{
	NSDictionary *fileContents = [NSDictionary dictionaryWithContentsOfFile:theFilename];
	if (fileContents) {
		[self setEntryFromDictionary:fileContents];
		return TRUE;
	} else {
		return FALSE;
	}
}


@end



@implementation LJPastEntry

@synthesize itemid;

- (LJPastEntry *) initPastItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer
						   error:(NSError **)anError
{
	self = (LJPastEntry *)[super init];  // typecast to get rid of a warning here... doesn't make sense to me.
	
	if (self) {
		[self setItemid:theItemid];
		[self setUsejournal:theJournal];
		[self setAccount:theAccount];
		[self setServer:theServer];
		
		// do the LJ call to load the entry and set the rest of the properties
		NSError *myError;
		LJxmlrpc *theLJCall = [[LJxmlrpc alloc] init];
		if (![theLJCall call:@"getevents"
				  withParams:[NSDictionary dictionaryWithObjectsAndKeys: // (value, key); end with nil
							  @"one",@"selecttype",
							  usejournal,@"usejournal",
							  itemid,@"itemid",
							  @"mac",@"lineendings",
							  nil
							  ]
					   atURL:SERVER2URL(server)
					 forUser:account
					   error:&myError]) {
			// call failed
			[theLJCall release];
			isFault = TRUE;
			faultString = [[myError userInfo] objectForKey:NSLocalizedDescriptionKey];
			faultCode = [NSNumber numberWithInteger:[myError code]];
			VLOG(@"Fault (%@): %@", faultCode, faultString);
			self = nil;
			if (anError != NULL) *anError = [[myError copy] autorelease];
			return nil;
		} else {
			// call succeded
			
			// extract the one event we want and its metadata "props"
			NSMutableDictionary *theEvent = [NSMutableDictionary dictionaryWithDictionary:[[theLJCall objectForKey:@"events"] lastObject]];
			[theLJCall release];
			
			// parse out the eventtime
			NSString *eventtime = [theEvent objectForKey:@"eventtime"];  // "YYYY-MM-DD hh:mm:ss", but ss is always 00
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
			
			[self setEntryFromDictionary:theEvent];
		}
	}
	
	return self;
}

- (LJPastEntry *) initPastItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer
{
	return [self initPastItemid:theItemid forJournal:theJournal forAccount:theAccount fromServer:theServer error:NULL];
}

- (BOOL) saveEntryError:(NSError **)anError
{
	// do the LJ call to save the entry, return TRUE for success, FALSE for failure
	LJxmlrpc *theLJCall = [[LJxmlrpc alloc] init];
	
	NSError *myError;
	NSMutableDictionary *theParams = [NSMutableDictionary dictionaryWithDictionary:[self getEntryAsDictionary]];
	[theParams setObject:@"mac" forKey:@"lineendings"];
	[theParams setObject:itemid forKey:@"itemid"];
	if (![theLJCall call:@"editevent"
			  withParams:theParams
				   atURL:SERVER2URL(server)
				 forUser:account
				   error:&myError]) {
		// call failed
		[theLJCall release];
		isFault = TRUE;
		faultString = [[myError userInfo] objectForKey:NSLocalizedDescriptionKey];
		faultCode = [NSNumber numberWithInteger:[myError code]];
		VLOG(@"Fault (%@): %@", faultCode, faultString);
		if (anError != NULL) *anError = [[myError copy] autorelease];
		return FALSE;
	} else {
		// call succeded
		entryURL = [[theLJCall objectForKey:@"url"] copy];
		[theLJCall release];
		return TRUE;
	}
}

- (BOOL) saveEntry
{
	return [self saveEntryError:NULL];
}

@end



@implementation LJNewEntry

- (BOOL) postEntryError:(NSError **)anError
{
	// do the LJ call to post the entry, return TRUE for success, FALSE for failure
	LJxmlrpc *theLJCall = [[LJxmlrpc alloc] init];
	
	NSError *myError;
	NSMutableDictionary *theParams = [NSMutableDictionary dictionaryWithDictionary:[self getEntryAsDictionary]];
	[theParams setObject:@"mac" forKey:@"lineendings"];
	if (![theLJCall call:@"postevent"
			  withParams:theParams
				   atURL:SERVER2URL(server)
				 forUser:account
				   error:&myError]) {
		// call failed
		[theLJCall release];
		isFault = TRUE;
		faultString = [[myError userInfo] objectForKey:NSLocalizedDescriptionKey];
		faultCode = [NSNumber numberWithInteger:[myError code]];
		VLOG(@"Fault (%@): %@", faultCode, faultString);
		if (anError != NULL) *anError = [[myError copy] autorelease];
		return FALSE;
	} else {
		// call succeded
		entryURL = [[theLJCall objectForKey:@"url"] copy];
		[theLJCall release];
		return TRUE;
	}
}

- (BOOL) postEntry
{
	return [self postEntryError:NULL];
}

@end
