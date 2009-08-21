//
//  asLJCoreLogger.h
//  asLJCore
//
//  Created by Isaac Greenspan on 8/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface asLJCoreLogger : NSObject {

}

+ (void)setVerboseLogging:(BOOL)verbose;

+(void)log:(NSString*)format, ...;

@end
