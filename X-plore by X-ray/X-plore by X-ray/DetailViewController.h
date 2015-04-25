//
//  DetailViewController.h
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/18/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *regNum;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UIView *detailPatientInfoView;

@end

