//
//  SelectableListTableViewController.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectableListTableViewController : UITableViewController

@property (nonatomic, strong) NSString *itemTextProperty;

@property (nonatomic, assign) id selectedItem;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, copy) void (^didSelectItemBlock)(id selctedItem, NSInteger selectedItem);

@end
