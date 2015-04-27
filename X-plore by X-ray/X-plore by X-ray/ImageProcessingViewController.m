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

@property (nonatomic) CGPoint tapPoint;
@property (nonatomic) UIView *selectedView;

@end

@implementation ImageProcessingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gestureRecognizer.delegate = self;
    
    //self.imageView.image = self.image;
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:self.gestureRecognizer];
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = CGSizeMake(self.imageView.layer.frame.size.width, self.imageView.layer.frame.size.height);
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = MAX(self.scrollView.layer.frame.size.width / self.imageView.image.size.width, self.scrollView.layer.frame.size.height / self.imageView.image.size.height);
    
    [self.backImageView addGestureRecognizer:self.gestureRecognizer];
    [self.healthyImageView addGestureRecognizer:self.gestureRecognizer];
    [self.problemImageView addGestureRecognizer:self.gestureRecognizer];
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

- (IBAction)tapImage:(id)sender {
    //[self.imageView removeFromSuperview];
    //CGFloat sizePercent = self.imageView.image.size.width / self.scrollView.contentSize.width;
    //    self.tapPoint = CGPointMake([sender locationInView:self.scrollView].x * sizePercent, ;
    self.tapPoint = [sender locationInView:self.imageView];
    //    CGPointApplyAffineTransform(self.tapPoint, CGAffineTransformMake(sizePercent, 0, 0, sizePercent, 0, 0));
    NSLog(@"%f %f", self.tapPoint.x, self.tapPoint.y);
    CGImageRef newImage = CGImageCreateWithImageInRect(self.imageView.image.CGImage, CGRectMake(self.tapPoint.x - 25/self.scrollView.zoomScale, self.tapPoint.y - 25/self.scrollView.zoomScale, 50/self.scrollView.zoomScale, 50/self.scrollView.zoomScale));
    
    
    //    CGImageRef newImage = CGImageCreateWithImageInRect(self.imageView.image.CGImage, CGRectMake(self.tapPoint.x - 25, self.tapPoint.y - 25, 50, 50));
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
    if (nil == _selectedView){
        
        _selectedView = [[UIView alloc] initWithFrame:selectedRect];
        _selectedView.layer.borderWidth = 3/self.scrollView.zoomScale;
        _selectedView.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        [_selectedView removeFromSuperview];
        _selectedView.center = self.tapPoint;
        _selectedView.frame = selectedRect;
    }
    NSLog(@"%f %f", selectedRect.size.width, selectedRect.size.height);
    [self.imageView addSubview:self.selectedView];
    
    int count = 0;
    float result = 0.0;
    //    printf("Pixel Data:\n");
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel =
            &bytes[row * bpr + col * bytes_per_pixel];
            
            //            printf("(");
            //            for(size_t x = 0; x < bytes_per_pixel; x++)
            //            {
            //                printf("%.2X", pixel[0]);
            //            printf("%f", [[NSString stringWithFormat:@"%d", pixel[0]] floatValue]);
            result += [[NSString stringWithFormat:@"%d", pixel[0]] floatValue];
            count++;
            //                if( x < bytes_per_pixel - 1 )
            //                    printf(",");
            //            }
            
            //            printf(")");
            //            if( col < width - 1 )
            //                printf(", ");
        }
        
        //        printf("\n");
    }
    
    printf("%f %i %f", result, count, result/count);
//    UIImageView testImageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithCGImage:newImage scale:1/(self.scrollView.zoomScale * 4) orientation:UIImageOrientationUp]];
    self.backImageView.image = [[UIImage alloc] initWithCGImage:newImage scale:1/self.scrollView.zoomScale * 4 orientation:UIImageOrientationUp];
    //    NSLog(@"%f", CGImageGetDecode(newImage));
    //[self.backImageView addSubview:self.bottomImageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
