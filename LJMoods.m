/*********************************************************************************
 
 © Copyright 2009-2010, Isaac Greenspan
 
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
//  LJMoods.m
//  asLJCore
//
//  Created by Isaac Greenspan on 1/27/09.
//

#import "LJMoods.h"

@interface LJMoods (privateInterface)

+ (NSString *)applicationSupportFolder;

@end


@implementation LJMoods

static NSMutableDictionary *everyMood;

#define USERDEFAULTS_KEY @"asLJCore-EveryMood"
#define LJMoodsCacheFILENAME [[LJMoods applicationSupportFolder] stringByAppendingPathComponent:@"LJMoodsCache.plist"]

+ (void)initialize
{
	@synchronized(self)
	{
		if (!everyMood) {
			NSMutableDictionary *loadedMoods = [NSMutableDictionary dictionaryWithContentsOfFile:LJMoodsCacheFILENAME];
			if (loadedMoods) {
				everyMood = loadedMoods;
				[everyMood retain];
			} else {
				everyMood = [[NSMutableDictionary dictionary] retain];
			}
		}
		// remove old-style mood cache from the application preferences
		// (which might be the wrong thing to do, since older versions will be looking for it there,
		//  but they can recreate it and if we don't remove it, it'll be there forever taking up space)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_KEY];
	}
}

+ (NSArray *)getMoodStringsForServer:(NSString *)theServer
{
	return [[[everyMood objectForKey:theServer] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

+ (NSString *)getMoodIDForString:(NSString *)theMood
			   withServer:(NSString *)theServer
{
	NSString *theMoodID = [[everyMood objectForKey:theServer] objectForKey:theMood];
	if (theMoodID)
	{
		return theMoodID;
	} else {
		return @"";
	}
}



static NSInteger intSort(id num1, id num2, void *context)
{
	int v1 = [num1 intValue];
	int v2 = [num2 intValue];
	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

+ (NSString *)getHighestMoodIDForServer:(NSString *)theServer
{
	NSString *theMoodID = [[[[everyMood objectForKey:theServer] allValues] sortedArrayUsingFunction:intSort context:NULL] lastObject];
	if (theMoodID)
	{
		return theMoodID;
	} else {
		return @"0";
	}
}


+ (void)addNewMoods:(NSArray *)theMoods
			withIDs:(NSArray *)theIDs
		  forServer:(NSString *)theServer
{
	NSMutableDictionary *thisServerMoods = [everyMood objectForKey:theServer];
	if (thisServerMoods) {
		[thisServerMoods addEntriesFromDictionary:[NSDictionary dictionaryWithObjects:theIDs forKeys:theMoods]];
	} else {
		thisServerMoods = [NSMutableDictionary dictionaryWithObjects:theIDs forKeys:theMoods];
		[everyMood setObject:thisServerMoods forKey:theServer];
	}
	if ([theMoods count] > 0) {
		// only bother to write the moods to the cache file if we actually added something to them.
		[everyMood writeToFile:LJMoodsCacheFILENAME atomically:YES];
	}
}



+ (NSString *)applicationSupportFolder
{
	// based on http://stackoverflow.com/questions/359590/cocoa-equivalent-of-nets-environment-specialfolder-for-saving-preferences-setti
	
    // Find this framework's "Application" Support Folder, creating it if needed.
	
    NSString *frameworkName, *supportPath = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask, YES );
	
    if ( [paths count] > 0)
    {
        frameworkName = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
        supportPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:frameworkName];
		
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:supportPath] )
			if ( ![[NSFileManager defaultManager] createDirectoryAtPath:supportPath attributes:nil] )
				supportPath = nil;
    }
	
    return supportPath;
}


@end
