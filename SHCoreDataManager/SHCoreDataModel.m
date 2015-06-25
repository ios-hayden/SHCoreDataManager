//
//  WCCCoreDataModel.m
//  wochacha
//
//  Created by Hayden on 15/2/11.
//  Copyright (c) 2015年 wochacha. All rights reserved.
//

#import "SHCoreDataModel.h"

@implementation SHCoreDataModel
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize asyncHandleMOC = _asyncHandleMOC;
@synthesize syncHandleMOC = _syncHandleMOC;

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods
- (void)initIfNeed
{
    [self.syncHandleMOC class];
    [self.asyncHandleMOC class];
}

- (BOOL)saveSyncMOC
{
    @synchronized(self.syncHandleMOC){
        NSError *error;
        return [self.syncHandleMOC save:&error];
    }
}

- (void)saveAsyncMOC
{
    [self.asyncHandleMOC performBlock:^{
        NSError *error;
        [self.asyncHandleMOC save:&error];
    }];
}

#pragma mark - Private Methods
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Notification Handle
- (void)mocDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *saveContext=[notification object];
    if (saveContext == self.asyncHandleMOC) {
        __weak NSManagedObjectContext *weakMOC = self.syncHandleMOC;
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakMOC mergeChangesFromContextDidSaveNotification:notification];
        });
    }else if(saveContext == self.syncHandleMOC){
        __weak NSManagedObjectContext *weakMOC = self.asyncHandleMOC;
        [weakMOC performBlock:^{
            [weakMOC mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark - Getters
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.dataModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *dataFileName = [NSString stringWithFormat:@"%@.sqlite", self.dataModelName];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Handle error
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)asyncHandleMOC
{
    if (_asyncHandleMOC != nil) {
        return _asyncHandleMOC;
    }
    
    _asyncHandleMOC = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_asyncHandleMOC setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return _asyncHandleMOC;
}

- (NSManagedObjectContext *)syncHandleMOC
{
    if (_syncHandleMOC != nil) {
        return _syncHandleMOC;
    }
    
    _syncHandleMOC = [[NSManagedObjectContext alloc]init];
    [_syncHandleMOC setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return _syncHandleMOC;
}
@end