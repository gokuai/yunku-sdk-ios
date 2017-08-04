//
//  FileUploadManager.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/3.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

@objc open class FileUploadManager: NSObject,UIAlertViewDelegate,UploadCallBack,ProgressDialogDelegate{
    

    
    fileprivate var uploadController:ProgressDialogViewController!
    fileprivate var manger:UploadManager!
    var delegate:FileUploadManagerDelegate!
    
    class var sharedInstance : FileUploadManager? {
        struct Static {
            static let instance : FileUploadManager = FileUploadManager()
        }
        
        return Static.instance
    }
    
    override init(){
        super.init()
        
        self.uploadController = ProgressDialogViewController()
        self.uploadController.delegate = self
    
    }
    
    //上传文件
    func upload(_ fullPath:String,data:LocalFileData,view:UIView){
       
        self.manger = FileDataManager.sharedInstance?.addFile(fullPath, localPath: data.localPath, callBack: self)
        self.uploadController.showInView(view, fileName: data.fileName,message:Bundle.getLocalStringFromBundle("Uploading", comment: ""), animated: true)

    }
    
    public func onSuccess(_ fileHash: String, fullPath: String, localPath: String) {
        self.uploadController.removeAnimate()
        if self.delegate != nil {
            self.delegate.onFileDidCreate(fullPath.lastPathComponent)
        }
    }
    
    public func onProgress(_ percent: Float, fullPath: String) {
        self.uploadController.setProgress(percent,animated:true)
    }
    
    public func onFail(_ errorMsg: String?, errorCode: Int, fullPath: String, localPath: String) {
        self.uploadController.setMessage(errorMsg!)
    }

    
    
//    public func onSuccess(fileHash: String) {
//        self.uploadController.removeAnimate()
//        if self.delegate != nil {
//            //self.delegate.onFileDidCreate(fullPath.lastPathComponent)
//        }
//    }
    

    
    func onDialogCacnel() {
        self.uploadController.removeAnimate()
        self.manger.stop()
    }
    
}

 protocol FileUploadManagerDelegate{
    func onFileDidCreate(_ fileName:String)
}

