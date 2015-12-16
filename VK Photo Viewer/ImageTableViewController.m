//
//  ImageTableViewController.m
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/16/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import "ImageTableViewController.h"
#import "VKSdk/VKSdk.h"

@interface ImageTableViewController ()

@end

@implementation ImageTableViewController

- (VKPhotoHelper *)photoHelper {
    if (!_photoHelper) {
        _photoHelper = [[VKPhotoHelper alloc] init];
    }
    
    return _photoHelper;
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;

    [self.tableView reloadData];
}

- (void)fetchItemsWithMethod:(NSString*)method andParameters:(NSDictionary*)parameters {
    VKRequest* request = [VKRequest requestWithMethod:method andParameters:parameters];
    [request executeWithResultBlock:^(VKResponse *response) {
        NSDictionary* result = response.json;
        self.photos = [result objectForKey:@"items"];
    } errorBlock:^(NSError *error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

#pragma mark - Table view data source

- (void)setImageForCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath withImageType:(NSString*)type {
    [self initCell:cell];

    NSDictionary* vkObject = [self.photos objectAtIndex:indexPath.row];
    VKPhoto* photo = [[VKPhoto alloc] initWithDictionary:vkObject];

    __weak ImageTableViewController* weakself = self;
    [self.photoHelper preparePhoto:photo withType:type withCompletionHandler:^(BOOL local, NSString *localPath) {
        if (local) {
            [weakself setImageFromFile:localPath toCell:cell];
        } else {
            [weakself setImageFromFile:localPath toCellAtIndexPath:indexPath];
        }
    }];

}

- (void)initCell:(UITableViewCell*)cell {
    [[cell viewWithTag:1] setImage:nil];
    [[cell viewWithTag:2] startAnimating];
}

- (void)setImageFromFile:(NSString*)file toCell:(UITableViewCell*)cell {
    UIImage* image = [UIImage imageWithContentsOfFile:file];
    [[cell viewWithTag:1] setImage:image];
    [[cell viewWithTag:2] stopAnimating];
}

- (void)setImageFromFile:(NSString*)file toCellAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self setImageFromFile:file toCell:cell];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}

@end
