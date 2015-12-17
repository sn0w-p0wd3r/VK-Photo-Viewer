//
//  AlbumsTableViewController.m
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/13/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import "AlbumsTableViewController.h"
#import "FilesTableViewController.h"
#import "VKSdk/VKSdk.h"
#import "VKPhotoHelper.h"

@interface AlbumsTableViewController ()

@end

@implementation AlbumsTableViewController

- (IBAction)logoutButtonClicked:(id)sender {
    [VKSdk forceLogout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadData:(UIRefreshControl*)refreshControl {
    [self fetchData];
    [refreshControl endRefreshing];
}

- (void)fetchData {
    [self fetchItemsWithMethod:@"photos.getAlbums" andParameters:@{ @"need_covers": @1, @"photo_sizes": @1 }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];
    [self.refreshControl addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
    [self fetchData];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Album cell" forIndexPath:indexPath];

    [self setImageForCell:cell withIndexPath:indexPath withImageType:@"p"];

    NSDictionary* vkObject = [self.photos objectAtIndex:indexPath.row];
    [[cell viewWithTag:3] setText:[vkObject valueForKey:@"title"]];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Album selected"]) {
        if (sender && [sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell* cell = sender;
            NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];

            NSDictionary* album = [self.photos objectAtIndex:indexPath.row];

            FilesTableViewController* ftvc = segue.destinationViewController;
            ftvc.albumId = [[album valueForKey:@"id"] unsignedIntegerValue];
            [ftvc.navigationItem setTitle:[album valueForKey:@"title"]];
        }
    }
}

@end
