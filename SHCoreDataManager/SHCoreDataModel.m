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
@synthesize readMOC = _readMOC;
@synthesize handleMOC = _handleMOC;

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
    //使用Lazy Load方式初始化MOC、persistentStoreCoordinator
    [self.handleMOC performBlock:^{
        NSLog(@"HandleMOC init");
    }];
    [self.readMOC performBlock:^{
        NSLog(@"ReadMOC init");
    }];
}

- (BOOL)save
{
    NSError *error;
    return [self.handleMOC save:&error];
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
    if (self.readMOC==saveContext) {
        return;
    }
    if (self.readMOC.persistentStoreCoordinator!=saveContext.persistentStoreCoordinator) {
        return;
    }
    __weak NSManagedObjectContext *weakReadMOC = self.readMOC;
    [weakReadMOC performBlock:^{
        [weakReadMOC mergeChangesFromContextDidSaveNotification:notification];
    }];
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

- (NSManagedObjectContext *)readMOC
{
    if (_readMOC != nil) {
        return _readMOC;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _readMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_readMOC setPersistentStoreCoordinator:coordinator];
    return _readMOC;
}

- (NSManagedObjectContext *)handleMOC
{
    if (_handleMOC != nil) {
        return _handleMOC;
    }
    
    _handleMOC = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_handleMOC setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return _handleMOC;
}
@end