//
//  Snapshot.h
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/27/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient;

@interface Snapshot : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) Patient *owner;

@end
