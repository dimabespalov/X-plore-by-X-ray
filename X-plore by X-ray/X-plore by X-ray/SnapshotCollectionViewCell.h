//
//  SnapshotCollectionViewCell.h
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/27/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapshotCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *imageNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
