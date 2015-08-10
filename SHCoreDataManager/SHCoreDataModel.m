//
//  WCCCoreDataModel.m
//  wochacha
//
//  Created by Hayden on 15/2/11.
//  Copyright (c) 2015年 wochacha. All rights reserved.
//

#import "SHCoreDataModel.h"

@interface SHCoreDataModel()

@property (strong, nonatomic) NSString *defaultDatabaseName;

@property (strong, nonatomic) NSMutableDictionary *muDicPSCs;
@property (strong, nonatomic) NSMutableDictionary *muDicMOMs;
@property (strong, nonatomic) NSMutableDictionary *muDicMOCs;

@property (strong, nonatomic) NSManagedObjectModel *defaultMOM;
@property (strong, nonatomic) NSPersistentStoreCoordinator *defaultPSC;

@end

@implementation SHCoreDataModel
@synthesize defaultMOC = _defaultMOC;
@synthesize defaultPSC = _defaultPSC;
@synthesize defaultMOM = _defaultMOM;
@synthesize muDicMOCs = _muDicMOCs;
@synthesize muDicPSCs = _muDicPSCs;
@synthesize muDicMOMs = _muDicMOMs;

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        _muDicMOMs = [[NSMutableDictionary alloc]init];
        _muDicPSCs = [[NSMutableDictionary alloc]init];
        _muDicMOCs = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - Public Methods
- (NSManagedObjectContext*)mocWithDatabaseName:(NSString*)strDatabaseName
{
    if (strDatabaseName.length==0) {
        return nil;
    }
    
    return [_muDicMOCs valueForKey:strDatabaseName];
}

- (BOOL)setDefaultDatabase:(NSString*)strDatabaseName
{
    if (strDatabaseName.length>0 && ![self existDatabase:strDatabaseName]) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:strDatabaseName withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        if (mom) {
            return [self addDatabase:strDatabaseName withManagedObjectModel:mom default:YES];
        }
    }
    return NO;
}

- (BOOL)addDatabase:(NSString*)strDatabaseName
{
    if (strDatabaseName.length>0 && ![self existDatabase:strDatabaseName]) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:strDatabaseName withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        if (mom) {
            return [self addDatabase:strDatabaseName withManagedObjectModel:mom];
        }
    }
    return NO;
}

- (BOOL)addDatabase:(NSString*)strDatabaseName withManagedObjectModel:(NSManagedObjectModel*)mom
{
    return [self addDatabase:strDatabaseName withManagedObjectModel:mom default:NO];
}

- (BOOL)addDatabase:(NSString*)strDatabaseName withManagedObjectModel:(NSManagedObjectModel*)mom default:(BOOL)bDefault
{
    if (mom && strDatabaseName.length>0 && ![self existDatabase:strDatabaseName]) {
        NSLog(@"**********************\n");
        
        for (id obj in mom.versionIdentifiers) {
            NSLog(@"==>%@",obj);
        }
        NSLog(@"**********************\n");
        NSString *dataFileName = [NSString stringWithFormat:@"%@.sqlite", strDatabaseName];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
        
        NSError *error = nil;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
        if ([psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSManagedObjectContext *moc = [[NSManagedObjectContext alloc]init];
            [moc setPersistentStoreCoordinator:psc];
            if (bDefault) {
                _defaultMOC = moc;
                _defaultMOM = mom;
                _defaultPSC = psc;
                self.defaultDatabaseName = strDatabaseName;
            }else{
                [_muDicMOMs setValue:mom forKey:strDatabaseName];
                [_muDicPSCs setValue:psc forKey:strDatabaseName];
                [_muDicMOCs setValue:moc forKey:strDatabaseName];
            }
            return YES;
        }
    }
    return NO;
}

- (BOOL)saveDefault
{
    return [_defaultMOC save:nil];
}

- (BOOL)saveMOC:(NSManagedObjectContext*)moc
{
    return [moc save:nil];
}

#pragma mark - Private Methods
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)existDatabase:(NSString*)strDatabaseName
{
    for (NSString *strName in [_muDicPSCs allKeys]) {
        if ([strDatabaseName isEqualToString:strName]) {
            return YES;
        }
    }
    if ([strDatabaseName isEqualToString:self.defaultDatabaseName]) {
        return YES;
    }
    return NO;
}
@end