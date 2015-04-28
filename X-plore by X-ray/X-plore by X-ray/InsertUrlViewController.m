//
//  InsertUrlViewController.m
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/27/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import "InsertUrlViewController.h"

@interface InsertUrlViewController ()

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@end

@implementation InsertUrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate performSelectorInBackground:@selector(downloadImage:) withObject:self.urlTextField.text];
    }];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
