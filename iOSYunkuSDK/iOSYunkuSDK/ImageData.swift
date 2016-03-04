//
//  ImageData.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/14.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit

@objc public class ImageData: NSObject {
    
    public var fileName:String
    public var fullPath:String
    public var thumbBig:String
    public var fileHash:String
    public var thumbNail:String
    public var fileSize:UInt64
    
    public var thumbBigCachePath:String{
        return Utils.getThumbCachePath().stringByAppendingPathComponent("\(self.fileHash)_thumbbig")
    }
    
    public var localPath:String{
        return Utils.getFileCachePath().stringByAppendingPathComponent(self.fileHash)
    
    }
    
    public var localFileSize:UInt64{
        return Utils.getFileSizeWithPath(self.localPath)
    
    }
    
    public var thumbBigCacheSize:UInt64{
        return Utils.getFileSizeWithPath(self.thumbBigCachePath)
    }
    
    public var thumbNailCachePath:String{
        return Utils.getFileCachePath().stringByAppendingPathComponent(self.fileHash)
    }
    
    init (data:FileData){
        self.fileName = data.fileName
        self.fullPath = data.fullPath
        self.thumbBig = data.thumbBig
        self.fileHash = data.fileHash
        self.thumbNail = data.thumbNail
        self.fileSize = data.fileSize!
    }
    
    public func getFileUri(resopnse:((success:Bool,uri:String) -> Void)){
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            
            let data = FileDataManager.sharedInstance?.getFileInfoSync(self.fullPath)
            dispatch_async(dispatch_get_main_queue()) {
                if data != nil{
                    resopnse(success:true,uri: data!.uri)
                }else{
                    
                    resopnse(success: false, uri: "")
                }
                
            }
            
        }
        // Add block to queue
        dispatch_async( dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), block)
    }

}

@objc public protocol FileInfoDelegate{
    func onGetFileUrl(url:String)
    
    func onFail();
}
