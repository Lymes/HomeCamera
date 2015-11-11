//
//  VideoTableViewController.m
//  homecamera
//
//  Created by Leonid Mesentsev on 30/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "VideoTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


#define kVideoCell    @"videoCell"
#define kHeaderHeight 200

#define kPathKey      @"path"
#define kDateKey      @"date"
#define kSizeKey      @"size"
#define kDurationKey  @"duration"


@interface VideoTableViewController () {

    UIImageOrientation scrollOrientation;
    CGPoint lastPos;

}

@property UIView *headerView;
@property MPMoviePlayerController *videoPlayer;
@property NSMutableArray *videoItems;

@end


static NSDateFormatter *_fmt;


@implementation VideoTableViewController


- (BOOL)prefersStatusBarHidden
{
    return NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    if ( [self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)] )
    {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }


    if ( !_fmt )
    {
        _fmt = [NSDateFormatter new];
        [_fmt setDateFormat:@"dd-MM-yyy HH:mm:ss"];
    }

    self.tableView.tableFooterView = [UIView new];
    [self refresh:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source


- (IBAction)refresh:(id)sender
{
    if ( [sender isKindOfClass:UIRefreshControl.class] )
    {
        [(UIRefreshControl *)sender endRefreshing];
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *docPath = docPaths[ 0 ];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:docPath];

    NSMutableArray *items = [NSMutableArray new];
    NSString *filePath;
    while ( ( filePath = [ enumerator nextObject ] ) != nil )
    {
        if ( [filePath.pathExtension isEqualToString:@"mp4"] )
        {
            NSString *fullPath = [ docPath stringByAppendingPathComponent:filePath ];
            [items addObject:@{ kPathKey : fullPath }.mutableCopy];
        }
    }
    self.videoItems = items;
    [self.tableView reloadData];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( !self.headerView )
    {
        CGRect frame = self.view.frame;
        frame.size.height = kHeaderHeight;
        self.headerView = [[UIView alloc] initWithFrame:frame];

        self.videoPlayer = [[MPMoviePlayerController alloc] init];
        self.videoPlayer.controlStyle = MPMovieControlStyleDefault;
        self.videoPlayer.shouldAutoplay = NO;
        self.videoPlayer.repeatMode = MPMovieRepeatModeNone;
        [self.videoPlayer prepareToPlay];
        [self.videoPlayer.view setFrame:self.headerView.frame];
        [self.headerView addSubview:self.videoPlayer.view];

        [self.videoPlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self.headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videoItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVideoCell forIndexPath:indexPath];

    NSString *path = self.videoItems[ indexPath.row ][ kPathKey ];
    NSString *date = self.videoItems[ indexPath.row ][ kDateKey ];
    NSString *size = self.videoItems[ indexPath.row ][ kSizeKey ];
    NSString *duration = self.videoItems[ indexPath.row ][ kDurationKey ];

    if ( !date || !size )
    {
        NSError *error = nil;
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        date = [_fmt stringFromDate:dict.fileCreationDate];
        self.videoItems[ indexPath.row ][ kDateKey ] = date;
        size = [NSByteCountFormatter stringFromByteCount:dict.fileSize countStyle:NSByteCountFormatterCountStyleFile];
        self.videoItems[ indexPath.row ][ kSizeKey ] = size;
    }

    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString( @"Video %@", nil ), date];
    cell.detailTextLabel.text = size;

    if ( !duration )
    {
        __block UITableViewCell *_cell = cell;
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
        [asset loadValuesAsynchronouslyForKeys:@[kDurationKey] completionHandler:^{
             NSString *duration = [self stringFromDuration:CMTimeGetSeconds( asset.duration )];
             dispatch_async( dispatch_get_main_queue(), ^{
                                 self.videoItems[ indexPath.row ][ kDurationKey ] = duration;
                                 _cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", _cell.detailTextLabel.text, duration];
                             } );
         }];
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", size, duration];
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView.isDragging )
    {
        CALayer *layer = cell.layer;
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -1000;
        if ( scrollOrientation == UIImageOrientationDown )
        {
            rotationAndPerspectiveTransform = CATransform3DRotate( rotationAndPerspectiveTransform, M_PI * 0.5, 1.0f, 0.0f, 0.0f );
        }
        else
        {
            rotationAndPerspectiveTransform = CATransform3DRotate( rotationAndPerspectiveTransform, -M_PI * 0.5, 1.0f, 0.0f, 0.0f );
        }
        layer.transform = rotationAndPerspectiveTransform;

        [UIView animateWithDuration:1.0 animations:^{
             layer.transform = CATransform3DIdentity;
         }];
    }
    else
    {
        // 1. Setup the CATransform3D structure
        CATransform3D rotation;

        rotation = CATransform3DMakeRotation( (90.0 * M_PI) / 180, 0.0, 0.7, 0.4 );
        rotation.m34 = 1.0 / -600;


        // 2. Define the initial state (Before the animation)
        cell.layer.shadowColor = [[UIColor blackColor]CGColor];
        cell.layer.shadowOffset = CGSizeMake( 10, 10 );
        cell.alpha = 0;

        cell.layer.transform = rotation;
        cell.layer.anchorPoint = CGPointMake( 0, 0.5 );


        // 3. Define the final state (After the animation) and commit the animation
        [UIView beginAnimations:@"rotation" context:NULL];
        [UIView setAnimationDuration:0.8];
        cell.layer.transform = CATransform3DIdentity;
        cell.alpha = 1;
        cell.layer.shadowOffset = CGSizeMake( 0, 0 );
        [UIView commitAnimations];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollOrientation = scrollView.contentOffset.y > lastPos.y ? UIImageOrientationDown : UIImageOrientationUp;
    lastPos = scrollView.contentOffset;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString( @"More", nil );
}


- (void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [NSURL fileURLWithPath:self.videoItems[ indexPath.row][ kPathKey ]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];

    [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [self.tableView setEditing:NO animated:YES];
    }];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete )
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.videoItems[ indexPath.row ][ kPathKey ] error:&error];
        if ( !error )
        {
            [self.videoItems removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}


#pragma mark - Navigation


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *videoPath = self.videoItems[ indexPath.row ][ kPathKey ];

    self.videoPlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    [self.videoPlayer play];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}


- (NSString *)stringFromDuration:(long long)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = (int)(totalSeconds / 3600);

    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}


@end
