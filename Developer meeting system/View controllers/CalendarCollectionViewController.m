//
//  CalendarCollectionViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 04/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "CalendarCollectionViewController.h"
#import "MeetingDetailsTableViewController.h"

#import "ContextManager.h"
#import "WebServiceClient.h"

#import <MSCollectionViewCalendarLayout/MSCollectionViewCalendarLayout.h>

#import "Gridline.h"
#import "TimeRowHeaderBackground.h"
#import "DayColumnHeaderBackground.h"
#import "MeetingCell.h"
#import "DayColumnHeader.h"
#import "TimeRowHeader.h"
#import "CurrentTimeIndicator.h"
#import "CurrentTimeGridline.h"

NSString * const EventCellReuseIdentifier = @"EventCellReuseIdentifier";
NSString * const DayColumnHeaderReuseIdentifier = @"DayColumnHeaderReuseIdentifier";
NSString * const TimeRowHeaderReuseIdentifier = @"TimeRowHeaderReuseIdentifier";

@interface CalendarCollectionViewController () <MSCollectionViewDelegateCalendarLayout, NSFetchedResultsControllerDelegate, MeetingDetailsTableViewControllerDelegate>

@property (nonatomic, strong) MSCollectionViewCalendarLayout *collectionViewCalendarLayout;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) Meeting *selectedMeeting;


- (IBAction)addNewMeetingButtonWasTapped:(id)sender;

@end

@implementation CalendarCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionViewCalendarLayout = [[MSCollectionViewCalendarLayout alloc] init];
    self.collectionViewCalendarLayout.delegate = self;
    self.collectionView.collectionViewLayout = self.collectionViewCalendarLayout;
    
    [self.collectionView registerClass:MeetingCell.class forCellWithReuseIdentifier:EventCellReuseIdentifier];
    [self.collectionView registerClass:DayColumnHeader.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:DayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:TimeRowHeader.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:TimeRowHeaderReuseIdentifier];
    
    NSFetchRequest *request = [Meeting sqk_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[ContextManager mainContext]
                                                                          sectionNameKeyPath:@"day"
                                                                                   cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    
    self.view.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![WebServiceClient hasUserToken])
    {
        [self performSegueWithIdentifier:@"showLoginNoAnimation" sender:self];
        return;
    }
    
    NSManagedObjectContext *context = [ContextManager newPrivateContext];
    
    [[WebServiceClient sharedInstance] GETAllMeetingsRoomsSuccess:^(NSDictionary *JSON) {
        NSArray *array = (NSArray *)JSON;
        [MeetingRoom importMeetingRooms:array intoContext:context];
        
        [[WebServiceClient sharedInstance] GETAllUserDetailsSuccess:^(NSDictionary *JSON) {
            NSArray *array = (NSArray *)JSON;
            [User importUsers:array intoContext:context];
            
            [[WebServiceClient sharedInstance] GETAllMeetingsSuccess:^(NSDictionary *JSON) {
                NSArray *array = (NSArray *)JSON;
                [Meeting importMeetings:array intoContext:context];
                [Meeting deleteInvalidMeetingsInContext:context];
                
                NSError *error;
                [context save:&error];
                
                if(error)
                {
                    NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);
                }
            }
                                                             failure:^(NSError *error) {
                                                                 NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                                             }];
        }
                                                            failure:^(NSError *error) {
                                                                NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                                            }];
    }
                                                          failure:^(NSError *error) {
                                                              NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                                          }];
    
    self.view.alpha = 1.0;
    [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
    [self.collectionView deselectItemAtIndexPath:self.selectedIndexPath animated:YES];
    self.selectedIndexPath = nil;
}

- (IBAction)addNewMeetingButtonWasTapped:(id)sender
{
    [self performSegueWithIdentifier:@"showMeetingDetails" sender:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // On iPhone, adjust width of sections on interface rotation. No necessary in horizontal layout (iPad)
    if (self.collectionViewCalendarLayout.sectionLayoutType == MSSectionLayoutTypeVerticalTile) {
        [self.collectionViewCalendarLayout invalidateLayoutCache];
        // These are the only widths that are defined by default. There are more that factor into the overall width.
        self.collectionViewCalendarLayout.sectionWidth = (CGRectGetWidth(self.collectionView.frame) - self.collectionViewCalendarLayout.timeRowHeaderWidth - self.collectionViewCalendarLayout.contentMargin.right);
        [self.collectionView reloadData];
    }
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionViewCalendarLayout invalidateLayoutCache];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [(id <NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MeetingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EventCellReuseIdentifier forIndexPath:indexPath];
    Meeting *meeting = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.meeting = meeting;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == MSCollectionElementKindDayColumnHeader)
    {
        DayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:DayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day = [self.collectionViewCalendarLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.collectionViewCalendarLayout];
        dayColumnHeader.day = day;
        dayColumnHeader.currentDay = [[day beginningOfDay] isEqualToDate:[currentDay beginningOfDay]];
        view = dayColumnHeader;
    }
    else if (kind == MSCollectionElementKindTimeRowHeader)
    {
        TimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowHeader.time = [self.collectionViewCalendarLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
    }
    return view;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    self.selectedMeeting = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showMeetingDetails" sender:self];
}

#pragma mark - MSCollectionViewCalendarLayout

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout dayForSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    Meeting *meeting = [sectionInfo.objects firstObject];
    return meeting.day;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Meeting *meeting = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return meeting.startDate;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Meeting *meeting = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return meeting.endDate;
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return [NSDate date];
}

#pragma mark - MeetingDetailsTableViewControllerDelegate

-(void)meetingDetailsFormDissmissed
{
    [self.collectionView deselectItemAtIndexPath:self.selectedIndexPath animated:YES];
    self.selectedIndexPath = nil;
}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = segue.identifier;
    
    if([segueIdentifier isEqualToString:@"showMeetingDetails"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        MeetingDetailsTableViewController *meetingDetailsTableViewController = (MeetingDetailsTableViewController *)[navigationController.viewControllers firstObject];
        meetingDetailsTableViewController.delegate = self;
        meetingDetailsTableViewController.meeting = self.selectedMeeting;
        
        self.selectedMeeting = nil;
    }
}

@end
