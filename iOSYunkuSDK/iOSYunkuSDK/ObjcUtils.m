//
//  ObjcUtils.m
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/14.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

#import "ObjcUtils.h"

@implementation ObjcUtils

+ (NSString *)replaceStrBySearchStr:(NSString *)body search:(NSString *)search replace:(NSString *)replace {
    NSRange substr = [body rangeOfString:search];
    NSMutableString *bodyMutable = [NSMutableString stringWithString:body];
    NSInteger location = -1;
    while (substr.location != NSNotFound) {
        if (location == substr.location) {
            break;
        }
        [bodyMutable replaceCharactersInRange:substr withString:replace];
        substr = [bodyMutable rangeOfString:search];
        location = substr.location;
    }
    return bodyMutable;
}


+ (long long)getFileSizeWithPath:(NSString *)path {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    long long fileLength = [fileHandle seekToEndOfFile];
    [fileHandle closeFile];
    return fileLength;
}


+ (NSString *)getDocumentUTIType:(NSString *)fileType {
    NSString *UTI;
    if ([fileType isEqualToString:@"jpg"]) {
        UTI = @"public.jpeg";
    } else if ([fileType isEqualToString:@"jpeg"]) {
        UTI = @"public.jpeg";
    } else if ([fileType isEqualToString:@"png"]) {
        UTI = @"public.png";
    } else if ([fileType isEqualToString:@"gif"]) {
        UTI = @"com.compuserve.gif";
    } else if ([fileType isEqualToString:@"bmp"]) {
        UTI = @"com.microsoft.bmp";
    } else if ([fileType isEqualToString:@"ipa"]) {
        UTI = @"com.apple.application-​bundle";
    } else if ([fileType isEqualToString:@"pxl"]) {
        UTI = @"com.apple.application-​bundle";
    } else if ([fileType isEqualToString:@"txt"]) {
        UTI = @"public.plain-text";
    } else if ([fileType isEqualToString:@"rtf"]) {
        UTI = @"public.rtf";
    } else if ([fileType isEqualToString:@"html"]) {
        UTI = @"public.html";
    } else if ([fileType isEqualToString:@"htm"]) {
        UTI = @"public.html";
    } else if ([fileType isEqualToString:@"xml"]) {
        UTI = @"public.xml";
    } else if ([fileType isEqualToString:@"tar"]) {
        UTI = @"public.tar-archive";
    } else if ([fileType isEqualToString:@"gz"]) {
        UTI = @"org.gnu.gnu-zip-archive";
    } else if ([fileType isEqualToString:@"tif"]) {
        UTI = @"public.tiff";
    } else if ([fileType isEqualToString:@"mov"]) {
        UTI = @"com.apple.quicktime-movie";
    } else if ([fileType isEqualToString:@"avi"]) {
        UTI = @"public.avi";
    } else if ([fileType isEqualToString:@"mpg"]) {
        UTI = @"public.mpeg";
    } else if ([fileType isEqualToString:@"mp4"]) {
        UTI = @"public.mpeg-4";
    } else if ([fileType isEqualToString:@"3gp"]) {
        UTI = @"public.3gpp";
    } else if ([fileType isEqualToString:@"mp3"]) {
        UTI = @"public.mp3";
    } else if ([fileType isEqualToString:@"m4a"]) {
        UTI = @"public.mpeg-4-audio";
    } else if ([fileType isEqualToString:@"zip"]) {
        UTI = @"com.pkware.zip-archive";
    } else if ([fileType isEqualToString:@"pdf"]) {
        UTI = @"com.adobe.pdf";
    } else if ([fileType isEqualToString:@"wav"]) {
        UTI = @"com.microsoft.waveform-​audio";
    } else if ([fileType isEqualToString:@"asf"]) {
        UTI = @"com.microsoft.advanced-​systems-format";
    } else if ([fileType isEqualToString:@"wmv"]) {
        UTI = @"com.microsoft.windows-​media-wmv";
    } else if ([fileType isEqualToString:@"wma"]) {
        UTI = @"com.microsoft.windows-​media-wma";
    } else if ([fileType isEqualToString:@"doc"]) {
        UTI = @"com.microsoft.word.doc";
    } else if ([fileType isEqualToString:@"docx"]) {
        UTI = @"com.microsoft.word.doc";
    } else if ([fileType isEqualToString:@"xls"]) {
        UTI = @"com.microsoft.excel.xls";
    } else if ([fileType isEqualToString:@"xlsx"]) {
        UTI = @"com.microsoft.excel.xls";
    } else if ([fileType isEqualToString:@"ppt"]) {
        UTI = @"com.microsoft.powerpoint.​ppt";
    } else if ([fileType isEqualToString:@"pptx"]) {
        UTI = @"com.microsoft.powerpoint.​ppt";
    } else {
        UTI = @"public.content";
    }
    return UTI;
}


@end
