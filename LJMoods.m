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


@implementation LJMoods

static NSMutableDictionary *everyMood;

#define USERDEFAULTS_KEY @"asLJCore-EveryMood"

+ (void)initialize
{
	@synchronized(self)
	{
		if (!everyMood) {
			NSData *theData = [[NSUserDefaults standardUserDefaults] dataForKey:USERDEFAULTS_KEY];
			if (theData) {
				everyMood = (NSMutableDictionary *)[NSUnarchiver unarchiveObjectWithData:theData];
				[everyMood retain];
			} else {
				everyMood = [[NSMutableDictionary dictionary] retain];
			}
		}
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
	[[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:everyMood] forKey:USERDEFAULTS_KEY];
}


@end
