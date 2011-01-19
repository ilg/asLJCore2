/*********************************************************************************
 
 © Copyright 2009-2011, Isaac Greenspan
 
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
//  LJEntry.h
//  asLJCore
//
//  Created by Isaac Greenspan on 5/20/09.
//

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
