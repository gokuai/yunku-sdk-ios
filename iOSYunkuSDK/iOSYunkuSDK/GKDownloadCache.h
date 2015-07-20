//
//  GKDownloadCache.h
//  iOSYunkuSDK
//
//  Created by wqc on 15/7/14.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKDownloadCache : NSObject

+(instancetype)shareInstance;

+(void)clearAll;

@property(nonatomic,copy) NSString *storagePath;


-(NSString*)storagePath;
-(void)setStoragePath:(NSString *)storagePath;

@end
