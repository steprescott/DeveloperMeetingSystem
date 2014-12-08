//
//  InvitesMasterTableViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 04/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "InvitesMasterTableViewController.h"

static NSString *cellWithIdentifier = @"inviteCell";

@interface InvitesMasterTableViewController ()

@end

@implementation InvitesMasterTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier forIndexPath:indexPath];
    
    return cell;
}

@end
