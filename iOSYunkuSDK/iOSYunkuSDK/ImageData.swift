//
//  ImageData.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/14.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit

@objc open class ImageData: NSObject {
    
    open var fileName:String
    open var fullPath:String
    open var thumbBig:String
    open var fileHash:String
    open var thumbNail:String
    open var fileSize:UInt64
    
    open var thumbBigCachePath:String{
        return Utils.getThumbCachePath().stringByAppendingPathComponent(path: "\(self.fileHash)_thumbbig")
    }
    
    open var localPath:String{
        return Utils.getFileCachePath().stringByAppendingPathComponent(path: self.fileHash)
    
    }
    
    open var localFileSize:UInt64{
        return Utils.getFileSizeWithPath(self.localPath)
    
    }
    
    open var thumbBigCacheSize:UInt64{
        return Utils.getFileSizeWithPath(self.thumbBigCachePath)
    }
    
    open var thumbNailCachePath:String{
        return Utils.getFileCachePath().stringByAppendingPathComponent(path: self.fileHash)
    }
    
    init (data:FileData){
        self.fileName = data.fileName
        self.fullPath = data.fullPath
        self.thumbBig = data.thumbBig
        self.fileHash = data.fileHash
        self.thumbNail = data.thumbNail
        self.fileSize = data.fileSize!
    }
    
    open func getFileUri(_ resopnse:@escaping ((_ success:Bool,_ uri:String) -> Void)){

        // Add block to queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async{
            let data = FileDataManager.sharedInstance?.getFileInfoSync(self.fullPath)
            DispatchQueue.main.async {
                if data != nil{
                    resopnse(true,data!.uri)
                }else{
                    
                    resopnse(false, "")
                }
                
            }
        }
    }

}

@objc public protocol FileInfoDelegate{
    func onGetFileUrl(_ url:String)
    
    func onFail();
}
