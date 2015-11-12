//
//  MotionJpegImageView.mm
//  VideoTest
//
//  Created by Matthew Eagar on 10/3/11.
//  Copyright 2011 ThinkFlood Inc. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "MotionJpegImageView.h"
#import "MotionJpegImageView+Recording.h"
#import "Base64.h"

#pragma mark - Constants

#define END_MARKER_BYTES { 0xFF, 0xD9 }

static NSData *_endMarkerData = nil;

#pragma mark - Private Method Declarations

@interface MotionJpegImageView ()

- (void)cleanupConnection;

@end

#pragma mark - Implementation

@implementation MotionJpegImageView

@synthesize url = _url;
@dynamic isPlaying;

- (BOOL)isPlaying
{
    return !(_connection == nil);
}


#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if ( self )
    {
        _url = nil;
        _receivedData = nil;

        if ( _endMarkerData == nil )
        {
            uint8_t endMarker[2] = END_MARKER_BYTES;
            _endMarkerData = [[NSData alloc] initWithBytes:endMarker length:2];
        }

        self.contentMode = UIViewContentModeScaleAspectFit;
    }

    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];

    if ( _endMarkerData == nil )
    {
        uint8_t endMarker[2] = END_MARKER_BYTES;
        _endMarkerData = [[NSData alloc] initWithBytes:endMarker length:2];
    }

    self.contentMode = UIViewContentModeScaleAspectFit;
    ASM.audioListener = self;
}


#pragma mark - Overrides

- (void)dealloc
{
    if ( _connection )
    {
        [_connection cancel];
        [self cleanupConnection];
    }
}


#pragma mark - Public Methods

- (void)play
{
    if ( _connection )
    {
        // continue
    }
    else if ( _url )
    {
        self.imageSize = CGSizeZero;
        // create a plaintext string in the format username:password
        NSString *loginString = [NSString stringWithFormat:@"%@:%@", self.userName, self.password];

        // employ the Base64 encoding above to encode the authentication tokens
        NSString *encodedLoginData = [Base64 encode:[loginString dataUsingEncoding:NSUTF8StringEncoding]];

        // create the contents of the header
        NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", encodedLoginData];



        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:10];

        // add the header to the request.  Here's the $$$!!!
        [request addValue:authHeader forHTTPHeaderField:@"Authorization"];


        _connection = [[NSURLConnection alloc] initWithRequest:request
                                                      delegate:self];
    }
}


- (void)pause
{
    if ( _connection )
    {
        [_connection cancel];
        [self cleanupConnection];
    }
}


- (void)clear
{
    self.image = nil;
}


- (void)stop
{
    [self pause];
    [self clear];
}


#pragma mark - Private Methods

- (void)cleanupConnection
{
    if ( _connection )
    {
        _connection = nil;
    }

    if ( _receivedData )
    {
        _receivedData = nil;
    }
}


#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _receivedData = [NSMutableData new];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];

    NSRange endRange = [_receivedData rangeOfData:_endMarkerData
                                          options:0
                                            range:NSMakeRange( 0, _receivedData.length )];

    long long endLocation = endRange.location + endRange.length;
    if ( _receivedData.length >= endLocation )
    {
        NSData *imageData = [_receivedData subdataWithRange:NSMakeRange( 0, endLocation )];
        UIImage *receivedImage = [UIImage imageWithData:imageData];
        if ( receivedImage )
        {
            // NSLog(@"%fx%f", receivedImage.size.width, receivedImage.size.height);
            self.image = receivedImage;
            if ( CGSizeEqualToSize( self.imageSize, CGSizeZero ) )
            {
                self.imageSize = receivedImage.size;
            }
            if ( self.isRecording )
            {
                dispatch_async( self.recordQueue, ^{
                    [self pushFrame:receivedImage];
                } );
            }
        }
        _receivedData = [NSMutableData new];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cleanupConnection];
}


- (void)connection:(NSURLConnection *)connection
    didFailWithError:(NSError *)error
{
    [self cleanupConnection];
    [self play];
}


@end