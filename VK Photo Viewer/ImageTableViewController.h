//
//  ImageTableViewController.h
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/16/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPhotoHelper.h"

@interface ImageTableViewController : UITableViewController

@property (strong, nonatomic) NSArray* photos;
@property (strong, nonatomic) VKPhotoHelper* photoHelper;

- (void)fetchItemsWithMethod:(NSString*)method andParameters:(NSDictionary*)parameters;
- (void)initCell:(UITableViewCell*)cell;
- (void)setImageForCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath withImageType:(NSString*)type;

@end
