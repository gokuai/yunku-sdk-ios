//
//  FGalleryPhoto.h
//  FGallery
//
//  Created by Grant Davis on 5/20/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol FGalleryPhotoDelegate;

@interface FGalleryPhoto : NSObject<NSURLConnectionDataDelegate> {
	
	// value which determines if the photo was initialized with local file paths or network paths.
	BOOL _useNetwork;
	
	BOOL _isThumbLoading;
	BOOL _hasThumbLoaded;
	
	BOOL _isFullsizeLoading;
	BOOL _hasFullsizeLoaded;
	
	NSMutableData *_thumbData;
	NSMutableData *_fullsizeData;
	
	NSURLConnection *_thumbConnection;
	NSURLConnection *_fullsizeConnection;
	
	NSString *_fullsizeUrl;
	
	UIImage *_thumbnail;
	UIImage *_fullsize;
	
	NSObject <FGalleryPhotoDelegate> *__weak _delegate;

}



-(id)initWithImageData:(id)imageData delegate:(NSObject<FGalleryPhotoDelegate>*)delegate index:(NSUInteger)imageIndex;

- (void)loadFullsize;

- (void)unloadFullsize;

@property (readonly) BOOL isFullsizeLoading;
@property (readonly) BOOL hasFullsizeLoaded;

@property (nonatomic,readonly) UIImage *fullsize;

@property (nonatomic,weak) NSObject<FGalleryPhotoDelegate> *delegate;

@property (nonatomic) NSInteger tag;

-(void)cancelLoad;

@end


@protocol FGalleryPhotoDelegate

@required
- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadFullsize:(UIImage*)image;
- (void)galleryPhoto:(FGalleryPhoto*)photo didWithError:(NSString*)message;

@optional
- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadFullsizeFromUrl:(NSString*)url;
- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadFullsizeFromPath:(NSString*)path;
- (void)galleryPhoto:(FGalleryPhoto*)photo setFullsizeDownloadProgress:(float)progress;

@end
