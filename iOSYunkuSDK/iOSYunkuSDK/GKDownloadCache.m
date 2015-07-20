//
//  GKDownloadCache.m
//  iOSYunkuSDK
//
//  Created by wqc on 15/7/14.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

#import "GKDownloadCache.h"
#import <CommonCrypto/CommonCrypto.h>

static dispatch_queue_t _syncQueue = NULL;

static dispatch_queue_t gkdownloadcache_sync_queue(){
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.goukuai.downloadcache.sync", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

static dispatch_queue_t gkdownloadcache_processing_queue(){
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.goukuai.downloadcache.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

static NSString *const GKDownloadCache_DefaultPath = @"GKDownloadCache";
static NSString *const GKDownloadCache_SessionCacheFolder = @"SessionStore";
static NSString *const GKDownloadCache_PermanentCacheFolder = @"PermanentStore";

typedef NS_ENUM(NSUInteger, GKCacheStorageType) {
    GKCacheStorageTypeSession = 0,
    GKCacheStorageTypePermanent
};


@implementation GKDownloadCache

@synthesize storagePath = _storagePath;

+(instancetype)shareInstance{
    static GKDownloadCache *cacheInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheInstance = [[[self class] alloc] init];
        _syncQueue = dispatch_queue_create("com.gkdownloadcache.syncqueue", DISPATCH_QUEUE_CONCURRENT);
        //_syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [cacheInstance setStoragePath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:GKDownloadCache_DefaultPath ] ];
        
    });
    return cacheInstance;
}

+(void)clearAll{
    NSString *cacheFolder = [[[self class] shareInstance] storagePath];
    if (cacheFolder != nil && cacheFolder.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = nil;
            [[NSFileManager defaultManager] removeItemAtPath:cacheFolder error:&err];
        });
    }
}

+(NSString*)keyForURL:(NSURL*)url{
    NSString *urlstring = [url absoluteString];
    if (urlstring.length <= 0) {
        return nil;
    }
    
    if ([[urlstring substringFromIndex:urlstring.length-1] isEqualToString:@"/"]) {
        urlstring = [urlstring substringToIndex:urlstring.length-1];
    }
    
    const char* cStr = [urlstring UTF8String];
    unsigned char result[16] = {0};
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}


-(NSString*)storagePath{
    NSLog(@"getstorage thread: %@",[NSThread currentThread]);
    __block NSString *path;
    dispatch_sync(_syncQueue, ^{
        path = _storagePath;
    });
    return path;
}

-(void)setStoragePath:(NSString *)storagePath{
    NSLog(@"setStoragepath thread: %@",[NSThread currentThread]);
    dispatch_block_t block = ^{
        _storagePath = [storagePath copy];
        [self clearCacheForType:GKCacheStorageTypeSession];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *dirs = @[storagePath,[storagePath stringByAppendingPathComponent:GKDownloadCache_SessionCacheFolder],[storagePath stringByAppendingPathComponent:GKDownloadCache_PermanentCacheFolder]];
        
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BOOL bDir = NO;
            BOOL bExist = [fileManager fileExistsAtPath:obj isDirectory:&bDir];
            NSError *err = nil;
            if (bExist && !bDir) {
                return;
            } else if (!bExist) {
                [fileManager createDirectoryAtPath:obj withIntermediateDirectories:NO attributes:nil error:&err];
                if (err) {
                    
                }
            }
        }];
    };
    //dispatch_async(_syncQueue, block);
    dispatch_barrier_sync(_syncQueue, block);
    
    //dispatch_barrier_async 必须用在自己创建的并行queue上
}

-(void)clearCacheForType:(GKCacheStorageType)type{
    if(!_storagePath || _storagePath.length <= 0) return;
    NSString *path = [_storagePath stringByAppendingPathComponent:(type == GKCacheStorageTypeSession ? GKDownloadCache_SessionCacheFolder : GKDownloadCache_PermanentCacheFolder)];
    
    dispatch_block_t block = ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL isDir = NO;
        BOOL bExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
        
        if (!bExist || !isDir) {
            return;
        }
        
        NSError *err = nil;
        NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:path error:&err];
        if (err) {
            return;
        }
        
        for (NSString *file in cacheFiles) {
            [fileManager removeItemAtPath:file error:&err];
        }
    };
    
    dispatch_barrier_async(_syncQueue, block);
}

-(NSString*)pathToFile:(NSString*)file{
    if (!_storagePath) {
        return nil;
    }
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dataPath = [[_storagePath stringByAppendingPathComponent:GKDownloadCache_SessionCacheFolder] stringByAppendingPathComponent:file];
    if ([fileManager fileExistsAtPath:dataPath]) {
        return dataPath;
    }
    
    dataPath = [[_storagePath stringByAppendingPathComponent:GKDownloadCache_PermanentCacheFolder] stringByAppendingPathComponent:file];
    if ([fileManager fileExistsAtPath:dataPath]) {
        return dataPath;
    }
    
    return nil;
}

-(NSString*)pathToCacheResponseDataForURL:(NSURL*)url{
    NSString *ext = [url.path pathExtension];
    
    if (!ext.length) {
        ext = @"html";
    }
    
    return [[self pathToFile:[[self class] keyForURL:url]] stringByAppendingPathExtension:ext];
    
}

-(NSData*)cachedDataForURL:(NSURL*)url{
    NSString *path = [self pathToCacheResponseDataForURL:url];
    if (path) {
        return [NSData dataWithContentsOfFile:path];
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
