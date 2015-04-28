//
//  ImageProcessingViewController.m
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/27/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import "ImageProcessingViewController.h"

@interface ImageProcessingViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *healthyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *problemImageView;

@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UILabel *healthyLabel;
@property (weak, nonatomic) IBOutlet UILabel *problemLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (nonatomic) CGPoint tapPoint;

@property (nonatomic) UIView *selectedBackView;
@property (nonatomic) UIView *selectedHealthyView;
@property (nonatomic) UIView *selectedProblemView;

@property (nonatomic) NSInteger imageViewTag;
@end

@implementation ImageProcessingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gestureRecognizer.delegate = self;
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.userInteractionEnabled = YES;
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = CGSizeMake(self.imageView.layer.frame.size.width, self.imageView.layer.frame.size.height);
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = MAX(self.scrollView.layer.frame.size.width / self.imageView.image.size.width, self.scrollView.layer.frame.size.height / self.imageView.image.size.height);
    
    self.backImageView.userInteractionEnabled = YES;
    self.healthyImageView.userInteractionEnabled = YES;
    self.problemImageView.userInteractionEnabled = YES;
    
    self.backImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.healthyImageView.layer.borderColor = [UIColor greenColor].CGColor;
    self.problemImageView.layer.borderColor = [UIColor redColor].CGColor;
    
    [self defaultBorders];
    self.backImageView.layer.borderWidth = 2.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)defaultBorders
{
    self.backImageView.layer.borderWidth = 2.0;
    self.healthyImageView.layer.borderWidth = 2.0;
    self.problemImageView.layer.borderWidth = 2.0;
}

- (IBAction)selectImageView:(id)sender
{
    [self defaultBorders];
    self.imageViewTag = [[sender view] tag];
    switch (self.imageViewTag) {
        case 2:
            self.healthyImageView.layer.borderWidth = 5.0;
            break;
        case 3:
            self.problemImageView.layer.borderWidth = 5.0;
            break;
        default:
            self.backImageView.layer.borderWidth = 5.0;
            break;
    }
}

- (IBAction)tapImage:(id)sender {
    self.tapPoint = [sender locationInView:self.imageView];
//    NSLog(@"%f %f", self.tapPoint.x, self.tapPoint.y);
    CGImageRef newImage = CGImageCreateWithImageInRect(self.imageView.image.CGImage, CGRectMake(self.tapPoint.x - 25/self.scrollView.zoomScale, self.tapPoint.y - 25/self.scrollView.zoomScale, 50/self.scrollView.zoomScale, 50/self.scrollView.zoomScale));
    
    size_t width  = CGImageGetWidth(newImage);
    size_t height = CGImageGetHeight(newImage);
    
    size_t bpr = CGImageGetBytesPerRow(newImage);
    size_t bpp = CGImageGetBitsPerPixel(newImage);
    size_t bpc = CGImageGetBitsPerComponent(newImage);
    size_t bytes_per_pixel = bpp / bpc;
    
    NSLog(@"BPP = %zu", bytes_per_pixel);
    
    CGDataProviderRef provider = CGImageGetDataProvider(newImage);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    const uint8_t* bytes = [data bytes];
    
    CGRect selectedRect = CGRectMake(self.tapPoint.x - width/2, self.tapPoint.y - height/2, width, height);
    switch (self.imageViewTag) {
        case 2:
            if (nil == _selectedHealthyView){
                _selectedHealthyView = [[UIView alloc] initWithFrame:selectedRect];
                _selectedHealthyView.layer.borderWidth = 3.0;//self.scrollView.zoomScale;
                _selectedHealthyView.layer.borderColor = [UIColor greenColor].CGColor;
            } else {
                [_selectedHealthyView removeFromSuperview];
                _selectedHealthyView.center = self.tapPoint;
                _selectedHealthyView.frame = selectedRect;
            }
            NSLog(@"%f %f", selectedRect.size.width, selectedRect.size.height);
            [self.imageView addSubview:self.selectedHealthyView];
            break;
        case 3:
            if (nil == _selectedProblemView){
                _selectedProblemView = [[UIView alloc] initWithFrame:selectedRect];
                _selectedProblemView.layer.borderWidth = 3.0;//self.scrollView.zoomScale;
                _selectedProblemView.layer.borderColor = [UIColor redColor].CGColor;
            } else {
                [_selectedProblemView removeFromSuperview];
                _selectedProblemView.center = self.tapPoint;
                _selectedProblemView.frame = selectedRect;
            }
            NSLog(@"%f %f", selectedRect.size.width, selectedRect.size.height);
            [self.imageView addSubview:self.selectedProblemView];
            break;
        default:
            if (nil == _selectedBackView){
                _selectedBackView = [[UIView alloc] initWithFrame:selectedRect];
                _selectedBackView.layer.borderWidth = 3.0;//self.scrollView.zoomScale;
                _selectedBackView.layer.borderColor = [UIColor yellowColor].CGColor;
            } else {
                [_selectedBackView removeFromSuperview];
                _selectedBackView.center = self.tapPoint;
                _selectedBackView.frame = selectedRect;
            }
            NSLog(@"%f %f", selectedRect.size.width, selectedRect.size.height);
            [self.imageView addSubview:self.selectedBackView];
            break;
    }
    
#pragma mark - Pixel counter
    int count = 0;
    float result = 0.0;
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel =
            &bytes[row * bpr + col * bytes_per_pixel];

            result += [[NSString stringWithFormat:@"%d", pixel[0]] floatValue];
            count++;
        }
    }

    UIImage *image = [[UIImage alloc] initWithCGImage:newImage scale:1/self.scrollView.zoomScale * 4 orientation:UIImageOrientationUp];
    switch (self.imageViewTag) {
        case 2:
            self.healthyImageView.image = image;
            self.healthyLabel.text = [NSString stringWithFormat:@"%.2f", result/count];
            break;
        case 3:
            self.problemImageView.image = image;
            self.problemLabel.text = [NSString stringWithFormat:@"%.2f", result/count];
            break;
        default:
            self.backImageView.image = image;
            self.backLabel.text = [NSString stringWithFormat:@"%.2f", result/count];
            break;
    }
    
    CGFloat problemBackDiff = [self.problemLabel.text floatValue] - [self.backLabel.text floatValue];
    CGFloat healthyBackDiff = [self.healthyLabel.text floatValue] - [self.backLabel.text floatValue];
    CGFloat diff = 100 * problemBackDiff / healthyBackDiff;
    if (diff < 0 || problemBackDiff < 0 || 0 >= healthyBackDiff){
        self.resultLabel.text = [NSString stringWithFormat:@"Check data"];
    }else if (diff > 100){
        self.resultLabel.text = [NSString stringWithFormat:@"100%%"];
    }else {
        self.resultLabel.text = [NSString stringWithFormat:@"%.2f%%", diff];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
