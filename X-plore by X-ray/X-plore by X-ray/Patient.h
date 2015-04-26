//
//  Patient.h
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/27/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Patient : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * regNum;
@property (nonatomic, retain) NSSet *snapshots;
@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addSnapshotsObject:(NSManagedObject *)value;
- (void)removeSnapshotsObject:(NSManagedObject *)value;
- (void)addSnapshots:(NSSet *)values;
- (void)removeSnapshots:(NSSet *)values;

@end
