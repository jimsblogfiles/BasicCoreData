//
//  AppLaunches.h
//  BasicCoreData
//
//  Created by James Border on 6/24/13.
//  Copyright (c) 2013 James Border. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppStatus;

@interface AppLaunches : NSManagedObject

@property (nonatomic, retain) NSDate * launchDate;
@property (nonatomic, retain) NSString * launchID;
@property (nonatomic, retain) NSSet *appStatusData;
@end

@interface AppLaunches (CoreDataGeneratedAccessors)

- (void)addAppStatusDataObject:(AppStatus *)value;
- (void)removeAppStatusDataObject:(AppStatus *)value;
- (void)addAppStatusData:(NSSet *)values;
- (void)removeAppStatusData:(NSSet *)values;

@end
