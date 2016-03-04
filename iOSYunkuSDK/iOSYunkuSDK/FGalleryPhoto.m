//
//  FGalleryPhoto.m
//  FGallery
//
//  Created by Grant Davis on 5/20/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "FGalleryPhoto.h"
#import "ObjcUtils.h"
#import <iOSYunkuSDK/iOSYunkuSDK-Swift.h>

#define kTagThumb   1000
#define kTagFull    2000

@interface FGalleryPhoto (Private)

// delegate notifying methods
- (void)willLoadFullsizeFromUrl;
- (void)willLoadFullsizeFromPath;
- (void)didLoadFullsize;
- (void)didLoadWithError:(NSString*)message;

// loading local images with threading
- (void)loadFullsizeInThread;

// cleanup
- (void)killThumbnailLoadObjects;
@end


@implementation FGalleryPhoto
{
    ImageData *_imageData;
    unsigned long long _totalSize;
    NSInteger _responseCode;

}

@synthesize delegate = _delegate;
@synthesize isFullsizeLoading = _isFullsizeLoading;
@synthesize hasFullsizeLoaded = _hasFullsizeLoaded;

-(id)initWithImageData:(id)imageData delegate:(NSObject<FGalleryPhotoDelegate>*)delegate index:(NSUInteger)imageIndex {
    self = [super init];
    _imageData = imageData;
    _delegate = delegate;
    _tag = imageIndex;
    return  self;
}

-(void)cancelLoad
{

    if (_fullsizeConnection) {
        [_fullsizeConnection cancel];
        _fullsizeConnection = nil;
    }
}

- (void)loadFullsize{

    if( _isFullsizeLoading || _hasFullsizeLoaded ) return;
    
    NSString *fileUrl = _imageData.thumbBigCachePath;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileUrl]) {
        
        [self willLoadFullsizeFromPath];
        
        _isFullsizeLoading = YES;
        _fullsizeUrl = fileUrl;
        
        // spawn a new thread to load from disk
        [NSThread detachNewThreadSelector:@selector(loadFullsizeInThread) toTarget:self withObject:nil];
        
    } else {
        // notify delegate
        [self willLoadFullsizeFromUrl];
        
        _isFullsizeLoading = YES;
        
        NSURL *url = [NSURL URLWithString:_imageData.thumbBig];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        _fullsizeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        [_fullsizeConnection start];
        _fullsizeData = [[NSMutableData alloc] init];
        
    }

}


- (void)loadFullsizeInThread
{
	@autoreleasepool {
        
    _fullsize = [UIImage imageWithContentsOfFile:_fullsizeUrl];
	_hasFullsizeLoaded = YES;
	_isFullsizeLoading = NO;

	[self performSelectorOnMainThread:@selector(didLoadFullsize) withObject:nil waitUntilDone:YES];
	
	}
}


- (void)unloadFullsize
{
	[_fullsizeConnection cancel];
	[self killFullsizeLoadObjects];
	
	_isFullsizeLoading = NO;
	_hasFullsizeLoaded = NO;
	
	_fullsize = nil;
}

- (void)unloadThumbnail
{
	[_thumbConnection cancel];
	[self killThumbnailLoadObjects];
	
	_isThumbLoading = NO;
	_hasThumbLoaded = NO;
	
	_thumbnail = nil;
}



#pragma mark -
#pragma mark ASIProgressDelegate

- (void)setProgress:(float)newProgress {
    if (_delegate==nil) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(galleryPhoto:setFullsizeDownloadProgress:)]) {
        [_delegate galleryPhoto:self setFullsizeDownloadProgress:newProgress];
    }
}


#pragma mark -
#pragma mark NSURL Delegate Methods


- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	
    if( conn == _fullsizeConnection ){
        
        _responseCode =  [(NSHTTPURLResponse *)response statusCode];
        if (_responseCode == 200) {
            [_fullsizeData setLength:0];
            
             NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            _totalSize = [(NSNumber*)[headers valueForKey:@"Content-Length"]longLongValue];
            
        }else{

            [self didLoadWithError: [OBJCMethodBridge getLocalString:@"加载失败" comment:@""]];
 
        }
        
    }
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}



- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    if( conn == _fullsizeConnection ){
        if (_responseCode == 200) {
            
            [_fullsizeData appendData:data];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            if (_totalSize>0) {
                [self setProgress:(float) _fullsizeData.length/(float)_totalSize];
            }

        }else{
            NSDictionary * errorDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",errorDic);
            
        }
    
    }

}



- (void)connectionDidFinishLoading:(NSURLConnection *)conn {

    if( conn == _fullsizeConnection ){
         _isFullsizeLoading = NO;
        
        if (_responseCode == 200) {
            _hasFullsizeLoaded = YES;
            
            // create new image with data
            _fullsize = [[UIImage alloc] initWithData:_fullsizeData];
            
            NSString *saveFullsizePath = _imageData.thumbBigCachePath;
            BOOL writeResult = [_fullsizeData writeToFile:saveFullsizePath atomically: NO];
            if (writeResult) {
                if ([ObjcUtils getFileSizeWithPath:saveFullsizePath] > 1024) {
                    //                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_FINISH object:nil];
                } else {
                    [[NSFileManager defaultManager] removeItemAtPath:saveFullsizePath error:nil];
                    //                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"打开失败，请关闭后重试", nil)];
                    
                }
            }
            // cleanup
            [self killFullsizeLoadObjects];
            
            // notify delegate
            if( _delegate )
                [self didLoadFullsize];

        }
        
    }
    
    // turn off data indicator
    if( !_isFullsizeLoading && !_isThumbLoading ) 
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark Delegate Notification Methods


- (void)willLoadFullsizeFromUrl{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadFullsizeFromUrl:)])
		[_delegate galleryPhoto:self willLoadFullsizeFromUrl:_fullsizeUrl];
}


- (void)willLoadFullsizeFromPath{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadFullsizeFromPath:)])
		[_delegate galleryPhoto:self willLoadFullsizeFromPath:_fullsizeUrl];
}


- (void)didLoadFullsize{
	if([_delegate respondsToSelector:@selector(galleryPhoto:didLoadFullsize:)])
		[_delegate galleryPhoto:self didLoadFullsize:_fullsize];
}

-(void)didLoadWithError:(NSString*)message{
    if([_delegate respondsToSelector:@selector(galleryPhoto:didWithError:)])
        [_delegate galleryPhoto:self didWithError:message];

}


#pragma mark -
#pragma mark Memory Management


- (void)killThumbnailLoadObjects{
	_thumbConnection = nil;
	_thumbData = nil;
}



- (void)killFullsizeLoadObjects{
	_fullsizeConnection = nil;
	_fullsizeData = nil;
}



- (void)dealloc{
	_delegate = nil;
	
	[_fullsizeConnection cancel];
	[_thumbConnection cancel];
	[self killFullsizeLoadObjects];
	[self killThumbnailLoadObjects];
	
	_fullsizeUrl = nil;
	
    [self cancelLoad];
	
}


@end
