//
//  FileDataBaseManager.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

@objc public class FileDataManager: NSObject {

    var rootPath = SDKConfig.orgRootPath
    var opName = SDKConfig.orgOptName
    var hooKDelegate :HookDelegate?
    var fileManager:EntFileManager?
    
    
     override init(){
        if SDKConfig.orgClientId.isEmpty&&SDKConfig.orgClientSecret.isEmpty{
            print("You need set orgClientId and orgClientSecret in AppDelegate.swift")
            return
        }
        
        self.fileManager = EntFileManager(orgClientId: SDKConfig.orgClientId, orgClientSecret: SDKConfig.orgClientSecret)
        
    }
    
    class var sharedInstance : FileDataManager? {
        struct Static {
            static let instance : FileDataManager = FileDataManager()
        }
        return Static.instance
    }

    //MARK:注册hook
    public func registerHook (delegate:HookDelegate?){
        self.hooKDelegate = delegate
    }
    
    //MARK:撤销Hook注册
    public func unRegisterHook(){
        self.hooKDelegate = nil
    }
    
    //MARK:重命名
    func rename(fullPath:String,newName:String,delegate:RequestDelegate) -> dispatch_block_t?{
        if(!Reachability.isConnectedToNetwork()){
            delegate.onNetUnable()
            return nil
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.Rename, fullPath: fullPath) {
            delegate.onHookError(HookType.Rename)
            return nil
        }
        
        
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            
            let parentPath = fullPath.stringByDeletingLastPathComponent
            let appendingString = parentPath.isEmpty ? "":"/"
            let newPath = "\(parentPath)\(appendingString)\(newName)"
            
            let result = self.fileManager?.move(fullPath, destFullPath: newPath, opName: self.opName)
            
            let data = BaseData.create(result!)
            dispatch_async(dispatch_get_main_queue()) {
                
                if data.code == HTTPStatusCode.OK.rawValue {
                    delegate.onHttpRequest(Action.Rename)
                }else{
                    delegate.onError(data.errorMsg)
                }
            }
            
        }
        // Add block to queue
        dispatch_async( dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), block)
        
        return block
    }
    
    //MARK:文件删除
    func del(fullPath:String,delegate:RequestDelegate) -> dispatch_block_t? {
        if(!Reachability.isConnectedToNetwork()){
            delegate.onNetUnable()
            return nil
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.Delete, fullPath: fullPath) {
            delegate.onHookError(HookType.Delete)
            return nil
        }
        
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            let result = self.fileManager?.del(fullPath, opName: self.opName)
            
            let data = BaseData.create(result!)
            dispatch_async(dispatch_get_main_queue()) {
                
                if data.code == HTTPStatusCode.OK.rawValue {
                    delegate.onHttpRequest(Action.Delete)
                }else{
                    delegate.onError(data.errorMsg)
                }
            }
            
        }
        // Add block to queue
        dispatch_async( dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), block)
        
        return block
    }
    
    func moveTo(){
        //TODO:移动
    }
    
    func copyTo(){
        //TODO:复制
    }
    
    
    //MARK:获取文件信息
    func  getFileInfoSync(fullPath:String) ->FileData {
        let resdic = self.fileManager?.getFileInfo(fullPath,type: NetType.Default)
        if let dic = resdic {
            let returnRes = ReturnResult.create(dic)
            return FileData.create(returnRes.result)
        } else {
            return FileData.create(Dictionary<String,AnyObject>())
        }
    }
    
    //MARK:上传文件
    func addFile(fullPath:String,localPath:String,callBack:UploadCallBack) -> UploadManager? {
        if(!Reachability.isConnectedToNetwork()){
            return nil
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.Upload, fullPath: fullPath) {
            callBack.onFail("")
            return nil
        }
        
        return self.fileManager?.uploadByBlock(localPath, fullPath: fullPath, opName: self.opName, opId: 0, overwrite: true, delegate: callBack)
    }
    
    //MARK:添加文件夹
    func addDir(fullPath:String,delegate:RequestDelegate) -> dispatch_block_t?{
        if(!Reachability.isConnectedToNetwork()){
            delegate.onNetUnable()
            return nil
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.CreateDir, fullPath: fullPath) {
            delegate.onHookError(HookType.CreateDir)
            return nil
        }
        
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            
            let result = self.fileManager?.createFolder(fullPath,opName:self.opName)
            
            let data = BaseData.create(result!)
            dispatch_async(dispatch_get_main_queue()) {
                
                if data.code == HTTPStatusCode.OK.rawValue {
                    delegate.onHttpRequest(Action.CreateFolder)
                }else{
                    delegate.onError(data.errorMsg)
                }
            }
            
        }
        // Add block to queue
        dispatch_async( dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), block)

        return block
        
    }
    
    //MARK:获取文件列表
    func getFileList(start:Int,fullPath:String,delegate:FileListDataDelegate) -> dispatch_block_t? {
        
        if(!Reachability.isConnectedToNetwork()){
            delegate.onNetUnable()
            return nil
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.FileList, fullPath: fullPath) {
            delegate.onHookError(HookType.FileList)
            return nil
        }
        
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            
            let result = self.fileManager?.getFileList(start, fullPath: fullPath)
            
            let fileListData = FileListData.create(result!)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if fileListData.code == HTTPStatusCode.OK.rawValue {
                    delegate.onHttpRequest(start,fullPath: fullPath,list: fileListData.fileList)
                    self.fullPath = fullPath
                    self.start = start
                }else {
                    delegate.onError(fileListData.errorMsg)
                }
      
            }
            
        }
        // Add block to queue
         dispatch_async( dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), block)
        
//        dispatch_block_cancel(_block)
        
        return block
    }
    
    var fullPath = ""
    var start = 0
    static let pageSize = 100
    
    //MARK:获取更多的文件列表
    func getMoreList(delegate:FileListDataDelegate) -> dispatch_block_t? {
        start += FileDataManager.pageSize
        
        return getFileList(self.start, fullPath: self.fullPath, delegate: delegate)
        
    }
    
    //MARK:是否是当前根目录
    func isRootPath(fullPath:String) -> Bool{
        return fullPath == rootPath
    }
    
    //MARK:是否注册hook
    func isHookRegisted() -> Bool{
        return self.hooKDelegate != nil
    }
    
}

@objc enum Action:Int {
        case CreateFolder = 1, Delete, Move, Copy, Rename
}

protocol FileListDataDelegate:BaseDelegate{
    func onHttpRequest(start:Int,fullPath:String,list:Array<FileData>)
}


protocol RequestDelegate:BaseDelegate{
    func onHttpRequest(action:Action)
}

@objc protocol BaseDelegate{
    
    func onError(errorMsg:String)
    
    func onHookError(type:HookType)
    
    func onNetUnable()

}
