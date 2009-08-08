//
//  LJMoods.m
//  asLJFramework
//
//  Created by Isaac Greenspan on 1/27/09.
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

#import "LJMoods.h"


@implementation LJMoods

static NSMutableDictionary *everyMood;

#define USERDEFAULTS_KEY @"asLJFramework-EveryMood"

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
