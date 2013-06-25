//
//  AppData.m
//  BasicCoreData
//
//  Created by James Border on 6/24/13.
//  Copyright (c) 2013 James Border. All rights reserved.
//

#import "AppData.h"
#import <CoreData/CoreData.h>

#import "AppLaunches.h"
#import "AppStatus.h"

@interface AppData () {}

@property NSManagedObjectContext *managedObjectContext;
@property NSManagedObjectContext *privateQueueContext;
@property NSOperationQueue *operationQueue;

- (void)initializeCoreData;
- (void)saveContext;

@end

@implementation AppData

static AppData* _sharedData = nil;

#pragma mark - 
#pragma mark App Specific Core Data Stuff Here

-(void)addAppLaunch:(NSDate*)date {

    AppLaunches *appLaunch = [NSEntityDescription insertNewObjectForEntityForName:@"AppLaunches" inManagedObjectContext:[self managedObjectContext]];
    [appLaunch setLaunchDate:date];
    [appLaunch setLaunchID:[self createUUID]];
    
    [self saveContext];
    
    _currentLaunch = appLaunch;
    
}

-(void)addAppStatusUpdate:(NSString*)statusChange at:(NSDate*)date {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppStatus" inManagedObjectContext:[self managedObjectContext]];
    AppStatus *appStatus = [[AppStatus alloc]initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    [appStatus setDate:date];
    [appStatus setStatus:statusChange];
    [_currentLaunch addAppStatusDataObject:appStatus];
    
    [self saveContext];
    
}

- (NSMutableString*)rawLaunchData
{
    
	NSMutableString *workString = [[NSMutableString alloc]init];
    NSError *error = nil;
    
    NSSortDescriptor *sortByLaunchDate = [[NSSortDescriptor alloc] initWithKey:@"launchDate" ascending:NO];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AppLaunches"];
    [fetchRequest setSortDescriptors:@[sortByLaunchDate]];
    
    NSArray *appLaunches = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (!appLaunches) {
        NSLog(@"Failed to load AppLaunches: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    for (AppLaunches *appLaunch in appLaunches) {
        
        [workString appendFormat:@"\rappLaunch.launchDate:%@",appLaunch.launchDate];
        [workString appendFormat:@"\r%@",[self rawStatusData:appLaunch.appStatusData]];
        
    }
    
    return workString;
    
}

- (NSMutableString*)rawStatusData:(NSSet*)appStatusData
{
    
	NSMutableString *workString = [[NSMutableString alloc]init];

    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
	NSArray *statusArray = [appStatusData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
	
	[statusArray enumerateObjectsUsingBlock:^(AppStatus *appStatus, NSUInteger idx, BOOL *stop) {

        [workString appendFormat:@"   %@ - %@\r",appStatus.date,appStatus.status];

	}];

    return workString;
    
}


#pragma mark -
#pragma mark Generic Core Data Stuff Here

- (void)saveContext
{
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    if (moc && [moc hasChanges]) {
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
    }
    
    moc = [self privateQueueContext];
    if (!moc) return;
    if (![moc hasChanges]) return;
    
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"Unresolved error: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
}

- (void)initializeCoreData
{

    if ([self managedObjectContext]) return;
    
    NSString *dataFileName = @"DataModel";
    
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:dataFileName withExtension:@"momd"];
    NSManagedObjectModel* mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    NSAssert2(mom, @"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    
    NSPersistentStoreCoordinator* coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSAssert(coordinator, @"Failed to initialize coordinator");
    
    [self setPrivateQueueContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [[self privateQueueContext] setPersistentStoreCoordinator:coordinator];
    
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    [[self managedObjectContext] setParentContext:[self privateQueueContext]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSPersistentStoreCoordinator *psc = [[self privateQueueContext] persistentStoreCoordinator];
        
        [psc lock];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",dataFileName ]];
        
        NSError *error = nil;

        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        
        [psc unlock];
        
//        NSLog(@"persistent store initialized");
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self contextInitialized];
//        });

    });

}

//- (void)contextInitialized
//{
//
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AppLaunches"];
//    NSError *error = nil;
//    
//    NSInteger count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&error];
//    
//    if (count == NSNotFound) {
//        NSLog(@"Error loading servers: %@\n%@", [error localizedDescription], [error userInfo]);
//        abort();
//    }
//    
//    if (count > 0) {
//        //  [self refreshServers];
//        return;
//    }
//
//}

#pragma mark -
#pragma mark Singleton stuff below

-(id)init {
	
	self = [super init];
	
	if (self != nil) {

        _sanityCheck = @"Connected";

        [self setOperationQueue:[[NSOperationQueue alloc] init]];
        [self initializeCoreData];

    }

    return self;

}

+(AppData*)sharedData {
    
    @synchronized(self) {
		
        if (_sharedData == nil) {
			_sharedData = [[self alloc] init];
		}

    }
	
    return _sharedData;
    
}

+(id)alloc {
	
	@synchronized([AppData class]) {
		
		NSAssert(_sharedData == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedData = [super alloc];
		
		return _sharedData;
        
	}
	
	return nil;
	
}

#pragma mark -
#pragma mark

-(NSString *)createUUID
{
    
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
	
    return uuidString;
}

@end
