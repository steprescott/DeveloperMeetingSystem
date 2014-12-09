//
//  SearchableSelectableTableViewController.h
//  Developer meeting system
//
//  Created by Ste Prescott on 09/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SQKFetchedTableViewController.h"

@interface SearchableSelectableTableViewController : SQKFetchedTableViewController

@property (nonatomic, assign) Class classOfItems;
@property (nonatomic, strong) NSString *itemTextProperty;
@property (nonatomic, strong) NSString *itemSearchProperty;
@property (nonatomic, strong) NSSet *filterItems;

@property (nonatomic, assign) id selectedItem;

@property (nonatomic, copy) void (^didSelectItemBlock)(id selctedItem, NSInteger selectedItem);

@end
