//
//  CoreDataManager.h
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/25/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)defaultManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
