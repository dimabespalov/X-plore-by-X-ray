//
//  DetailViewController.m
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/18/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"firstName"] description];
        self.firstName.text = [[self.detailItem valueForKey:@"firstName"] description];
        self.lastName.text = [[self.detailItem valueForKey:@"lastName"] description];
        self.regNum.text = [[self.detailItem valueForKey:@"regNum"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    if (self.detailItem) {
        self.detailPatientInfoView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
