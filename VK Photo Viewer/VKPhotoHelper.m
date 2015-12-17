//
//  VKPhotoHelper.m
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/15/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import "VKPhotoHelper.h"

@interface VKPhotoHelper()

@property (strong, nonatomic) NSURLSession* session;

@end

@implementation VKPhotoHelper

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }

    return _session;
}

- (void)downloadImageFromUrl:(NSString*)remoteUrl toLocalFile:(NSString*)localFile withCompletionHandler:(void (^)(BOOL local, NSString* localFile))handler {
    NSURL* downloadTaskURL = [NSURL URLWithString:remoteUrl];
    [[self.session downloadTaskWithURL: downloadTaskURL
                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *fileManagerError;
                    
                    [fileManager removeItemAtPath:localFile error:NULL];
                    if (location) {
                        [fileManager copyItemAtPath:[location path] toPath:localFile error:&fileManagerError];
                    }

                    dispatch_async(dispatch_get_main_queue(), ^(){
                        handler(NO, localFile);
                    });
                }] resume];
}

- (void)processFile:(NSString*)localFile withRemoteUrl:(NSString*)remoteFile withCompletionHandler:(void (^)(BOOL local, NSString* localFile))handler {
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFile]) {
        handler(YES, localFile);
    } else {
        [self downloadImageFromUrl:remoteFile toLocalFile:localFile withCompletionHandler:handler];
    }
}

- (void)preparePhoto:(VKPhoto*)photo withType:(NSString*)type withCompletionHandler:(void (^)(BOOL local, NSString* localFile))handler {
    NSString* localFile = [VKPhotoHelper getLocalPhotoPathForPhoto:photo withType:type];
    NSString* remoteFile = [VKPhotoHelper getPhotoUrlForPhoto:photo withType:type];
    [self processFile:localFile withRemoteUrl:remoteFile withCompletionHandler:handler];
}

- (void)preparePhotosLargestSizeBySizeGroup:(VKPhoto*)photo withCompletionHandler:(void (^)(BOOL local, NSString* localFile))handler {
    NSArray* sizeGroups = @[@"2560", @"1280", @"807", @"604", @"130", @"75"];
    for (NSString* sizeGroup in sizeGroups) {
        NSString* key = [NSString stringWithFormat:@"photo_%@", sizeGroup];

        NSString* remoteFile = [photo valueForKey:key];
        if (remoteFile) {
            NSString* localFile = [NSString stringWithFormat:@"%@_%@", sizeGroup, [remoteFile lastPathComponent]];
            localFile = [VKPhotoHelper getLocalPhotoPathForPhotoName:localFile];

            [self processFile:localFile withRemoteUrl:remoteFile withCompletionHandler:handler];
            return;
        }
    }
    handler(YES, nil);
}

#pragma mark - Helper methods

+ (NSString*)getLocalPhotoPathForPhotoName:(NSString*)fileName {
    NSString* documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    return [documents stringByAppendingPathComponent:fileName];
}

+ (NSString*)getLocalPhotoPathForPhoto:(VKPhoto*)photo withType:(NSString*)type {
    VKPhotoSizes* sizes = photo.sizes;

    for (VKPhotoSize* size in sizes) {
        if ([[size valueForKey:@"type"] isEqualToString:type]) {
            NSString* remoteUrl = [size valueForKey:@"src"];
            NSString* fileName = [NSString stringWithFormat:@"%@_%@", type, [remoteUrl lastPathComponent]];
            return [self getLocalPhotoPathForPhotoName:fileName];
        }
    }

    return nil;
}

+ (NSString*)getPhotoUrlForPhoto:(VKPhoto*)photo withType:(NSString*)type {
    VKPhotoSizes* sizes = photo.sizes;

    for (VKPhotoSize* size in sizes) {
        if ([[size valueForKey:@"type"] isEqualToString:type]) {
            return [size valueForKey:@"src"];
        }
    }

    return nil;
}

@end
