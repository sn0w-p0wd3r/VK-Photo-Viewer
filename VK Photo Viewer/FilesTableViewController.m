//
//  FilesTableViewController.m
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/15/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import "FilesTableViewController.h"
#import "PhotoViewController.h"
#import "VKSdk/VKSdk.h"
#import "VKPhotoHelper.h"

@interface FilesTableViewController ()

@end

@implementation FilesTableViewController

- (void)reloadData:(UIRefreshControl*)refreshControl {
    [self fetchData];
    [refreshControl endRefreshing];
}

- (void)fetchData {
    [self fetchItemsWithMethod:@"photos.get" andParameters:@{ @"album_id": @(self.albumId), @"photo_sizes": @1 }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.refreshControl addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
    [self fetchData];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo cell" forIndexPath:indexPath];

    [self setImageForCell:cell withIndexPath:indexPath withImageType:@"r"];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Photo selected"]) {
        if (sender && [sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell* cell = sender;
            NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];

            NSDictionary* photo = [self.photos objectAtIndex:indexPath.row];

            PhotoViewController* fvc = segue.destinationViewController;
            fvc.photo = photo;
        }
    }
}

@end
