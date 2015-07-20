//
//  ObjcUtils.h
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/14.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjcUtils : NSObject

+ (NSString *)replaceStrBySearchStr:(NSString *)body search:(NSString *)search replace:(NSString *)replace;
+ (NSString *)getDocumentUTIType:(NSString *)fileType;
+ (long long)getFileSizeWithPath:(NSString*)path;


@end
