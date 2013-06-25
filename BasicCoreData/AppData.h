//
//  AppData.h
//  BasicCoreData
//
//  Created by James Border on 6/24/13.
//  Copyright (c) 2013 James Border. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppLaunches;
@class AppStatus;

@interface AppData : NSObject {
    
}

+(AppData*)sharedData;

@property (nonatomic, retain) NSString *sanityCheck;
@property (nonatomic, retain) AppLaunches *currentLaunch;

-(void)addAppLaunch:(NSDate*)date;
-(void)addAppStatusUpdate:(NSString*)statusChange at:(NSDate*)date;

- (NSMutableString*)rawLaunchData;
- (NSMutableString*)rawStatusData:(NSSet*)appStatusData;

@end
