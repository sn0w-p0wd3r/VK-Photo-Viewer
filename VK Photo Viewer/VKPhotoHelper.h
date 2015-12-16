//
//  VKPhotoHelper.h
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/15/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKSdk/VKSdk.h"

@interface VKPhotoHelper : NSObject

- (void)preparePhoto:(VKPhoto*)photo withType:(NSString*)type withCompletionHandler:(void (^)(BOOL local, NSString* localPath))handler;
- (void)preparePhotosLargestSizeBySizeGroup:(VKPhoto*)photo withCompletionHandler:(void (^)(BOOL local, NSString* localFile))handler;

@end
