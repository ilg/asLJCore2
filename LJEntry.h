//
//  LJEntry.h
//  asLJCore
//
//  Created by Isaac Greenspan on 5/20/09.
//

/*** BEGIN LICENSE TEXT ***
 
 Copyright (c) 2009-2010, Isaac Greenspan
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the <organization> nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 *** END LICENSE TEXT ***/

#import <Cocoa/Cocoa.h>


@interface LJEntry : NSObject {
	// over-arching connection settings
	NSString *account;
	NSString *server;
	
	// major features of an entry
	NSString *event;
	NSString *subject;
	NSString *security;
	NSNumber *allowmask;
	NSNumber *year;
	NSNumber *mon;
	NSNumber *day;
	NSNumber *hour;
	NSNumber *min;
	
	// which journal to use for the entry
	NSString *usejournal;
	
	// entry metadata "props"
	NSString *current_location;
	NSString *current_mood;
	NSNumber *current_moodid;
	NSString *current_music;
	NSNumber *opt_backdated;
	NSString *picture_keyword;
	NSString *taglist;
	NSNumber *opt_nocomments;
	NSNumber *opt_noemail;
	NSString *opt_screening;
	NSNumber *opt_preformatted;
	
	// the URL of the entry when posted
	NSString *entryURL;
	
	// error info
	BOOL isFault;
	NSNumber *faultCode;
	NSString *faultString;
	
}

@property(copy) NSString *account;
@property(copy) NSString *server;
@property(copy) NSString *event;
@property(copy) NSString *subject;
@property(copy) NSString *security;
@property(copy) NSNumber *allowmask;
@property(copy) NSNumber *year;
@property(copy) NSNumber *mon;
@property(copy) NSNumber *day;
@property(copy) NSNumber *hour;
@property(copy) NSNumber *min;
@property(copy) NSString *usejournal;
@property(copy) NSString *current_location;
@property(copy) NSString *current_mood;
@property(copy) NSNumber *current_moodid;
@property(copy) NSString *current_music;
@property(copy) NSNumber *opt_backdated;
@property(copy) NSString *picture_keyword;
@property(copy) NSString *taglist;
@property(copy) NSNumber *opt_nocomments;
@property(copy) NSNumber *opt_noemail;
@property(copy) NSString *opt_screening;
@property(copy) NSNumber *opt_preformatted;

@property(readonly) NSString *entryURL;

@property(readonly) BOOL isFault;
@property(readonly) NSNumber *faultCode;
@property(readonly) NSString *faultString;

- (LJEntry *) init;
- (NSDictionary *) getEntryAsDictionary;
- (void) setEntryFromDictionary:(NSDictionary *)theDictionary;
- (BOOL) saveEntryToFile:(NSString *)theFilename;
- (BOOL) loadEntryFromFile:(NSString *)theFilename;

@end

@interface LJPastEntry : LJEntry {
	NSNumber *itemid;
}

@property(copy) NSNumber *itemid;

- (LJPastEntry *) initPastItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer
						   error:(NSError **)anError;
- (LJPastEntry *) initPastItemid:(NSNumber *)theItemid
					  forJournal:(NSString *)theJournal
					  forAccount:(NSString *)theAccount
					  fromServer:(NSString *)theServer;

- (BOOL) saveEntryError:(NSError **)anError;
- (BOOL) saveEntry;

@end

@interface LJNewEntry : LJEntry {

}

- (BOOL) postEntryError:(NSError **)anError;
- (BOOL) postEntry;

@end
