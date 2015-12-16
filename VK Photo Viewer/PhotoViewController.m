//
//  PhotoViewController.m
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/16/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import "PhotoViewController.h"
#import "VKSdk/VKSdk.h"
#import "VKPhotoHelper.h"

@interface PhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *photoFetchSpinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) VKPhoto* vkPhoto;
@property (strong, nonatomic) VKPhotoHelper* photoHelper;

@end

@implementation PhotoViewController

- (VKPhotoHelper *)photoHelper {
    if (!_photoHelper) {
        _photoHelper = [[VKPhotoHelper alloc] init];
    }
    
    return _photoHelper;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)fetchPhoto {
    [self.photoFetchSpinner startAnimating];

    NSUInteger photoId = [[self.photo objectForKey:@"id"] unsignedIntegerValue];
    NSUInteger ownerId = [[self.photo objectForKey:@"owner_id"] unsignedIntegerValue];

    VKRequest* request = [VKRequest requestWithMethod:@"photos.getById"
                                        andParameters:@{ @"photos": [NSString stringWithFormat:@"%lu_%lu", ownerId, photoId] }];
    [request executeWithResultBlock:^(VKResponse *response) {
        NSArray* result = response.json;
        self.vkPhoto = [[VKPhoto alloc] initWithDictionary:result[0]];
    } errorBlock:^(NSError *error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)setVkPhoto:(VKPhoto *)vkPhoto {
    _vkPhoto = vkPhoto;

    [self.photoHelper preparePhotosLargestSizeBySizeGroup:vkPhoto withCompletionHandler:^(BOOL local, NSString *localFile) {
        UIImage* image = [UIImage imageWithContentsOfFile:localFile];
        [self.imageView setImage:image];

        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        self.imageView.frame = frame;
        
        CGRect visibleArea = self.scrollView.frame;
        CGSize visibleSize = visibleArea.size;
        
        CGFloat xScale = visibleSize.width / frame.size.width;
        CGFloat yScale = visibleSize.height / frame.size.height;
        
        CGFloat scale = MIN(xScale, yScale);
        [self.scrollView setMinimumZoomScale:scale];
        [self.scrollView setZoomScale:scale];
        
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.scrollView.contentSize = image.size;
        
        [self.photoFetchSpinner stopAnimating];

    }];
}

- (UIImageView*)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }

    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.scrollView addSubview:self.imageView];
    [self.scrollView setDelegate:self];
    [self fetchPhoto];
}


@end
