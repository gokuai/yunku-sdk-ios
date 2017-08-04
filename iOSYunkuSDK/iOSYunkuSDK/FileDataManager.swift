//
//  FileDataBaseManager.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

@objc open class FileDataManager: NSObject {

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
    open func registerHook (_ delegate:HookDelegate?){
        self.hooKDelegate = delegate
    }
    
    //MARK:撤销Hook注册
    open func unRegisterHook(){
        self.hooKDelegate = nil
    }
    
    //MARK:重命名
    func rename(_ fullPath:String,newName:String,delegate:RequestDelegate) {
        if(!(Reachability()?.isReachable)!){
            delegate.onNetUnable()
            return
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.rename, fullPath: fullPath) {
            delegate.onHookError(HookType.rename)
            return
        }
        
        // Add block to queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async{
            let parentPath = fullPath.stringByDeletingLastPathComponent
            let appendingString = parentPath.isEmpty ? "":"/"
            let newPath = "\(parentPath)\(appendingString)\(newName)"
            
            let result = self.fileManager?.move(fullPath, destFullPath: newPath, opName: self.opName)
            
            let data = BaseData.create(result!)
            DispatchQueue.main.async {
                
                if data.code == HTTPStatusCode.ok.rawValue {
                    delegate.onHttpRequest(Action.rename)
                }else{
                    delegate.onError(data.errorMsg)
                }
            }
        }
        
        
    }
    
    //MARK:文件删除
    func del(_ fullPath:String,delegate:RequestDelegate)  {
        if(!(Reachability()?.isReachable)!){
            delegate.onNetUnable()
            return
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.delete, fullPath: fullPath) {
            delegate.onHookError(HookType.delete)
            return
        }
        
        // Add block to queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async{
            let result = self.fileManager?.del(fullPath, opName: self.opName)
            
            let data = BaseData.create(result!)
            DispatchQueue.main.async {
                
                if data.code == HTTPStatusCode.ok.rawValue {
                    delegate.onHttpRequest(Action.delete)
                }else{
                    delegate.onError(data.errorMsg)
                }
            }
        }

    }
    
    func moveTo(){
        //TODO:移动
    }
    
    func copyTo(){
        //TODO:复制
    }
    
    
    //MARK:获取文件信息
    func  getFileInfoSync(_ fullPath:String) ->FileData {
        let resdic = self.fileManager?.getFileInfo(fullPath,type: NetType.default)
        if let dic = resdic {
            let returnRes = ReturnResult.create(dic)
            return FileData.create(returnRes.result)
        } else {
            return FileData.create(Dictionary<String,AnyObject>())
        }
    }
    
    //MARK:上传文件
    func addFile(_ fullPath:String,localPath:String,callBack:UploadCallBack) -> UploadManager? {
        if(!(Reachability()?.isReachable)!){
            return nil
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.upload, fullPath: fullPath) {
            callBack.onFail("", errorCode: 0, fullPath: fullPath, localPath: localPath)
            return nil
        }
        
        return self.fileManager?.uploadByBlock(localPath, fullPath: fullPath, opName: self.opName, opId: 0, overwrite: true, delegate: callBack)
    }
    
    //MARK:添加文件夹
    func addDir(_ fullPath:String,delegate:RequestDelegate) {
        if(!(Reachability()?.isReachable)!){
            delegate.onNetUnable()
            return
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.createDir, fullPath: fullPath) {
            delegate.onHookError(HookType.createDir)
            return
        }
        // Add block to queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async{
            let result = self.fileManager?.createFolder(fullPath,opName:self.opName)
            
            let data = BaseData.create(result!)
            DispatchQueue.main.async {
                
                if data.code == HTTPStatusCode.ok.rawValue {
                    delegate.onHttpRequest(Action.createFolder)
                }else{
                    delegate.onError(data.errorMsg)
                }
            }
        }
        
        
    }
    
    //MARK:获取文件列表
    func getFileList(_ start:Int,fullPath:String,delegate:FileListDataDelegate) {
        
        if(!(Reachability()?.isReachable)!){
            delegate.onNetUnable()
            return
        }
        
        if isHookRegisted() && !self.hooKDelegate!.hookInvoke(HookType.fileList, fullPath: fullPath) {
            delegate.onHookError(HookType.fileList)
            return
        }
        
        // Add block to queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async{
            let result = self.fileManager?.getFileList(start, fullPath: fullPath)
            
            let fileListData = FileListData.create(result!)
            
            DispatchQueue.main.async {
                
                if fileListData.code == HTTPStatusCode.ok.rawValue {
                    delegate.onHttpRequest(start,fullPath: fullPath,list: fileListData.fileList)
                    self.fullPath = fullPath
                    self.start = start
                }else {
                    delegate.onError(fileListData.errorMsg)
                }
                
            }
        }
        
//        dispatch_block_cancel(_block)
        
        
    }
    
    var fullPath = ""
    var start = 0
    static let pageSize = 100
    
    //MARK:获取更多的文件列表
    func getMoreList(_ delegate:FileListDataDelegate) {
        start += FileDataManager.pageSize
        
         getFileList(self.start, fullPath: self.fullPath, delegate: delegate)
        
    }
    
    //MARK:是否是当前根目录
    func isRootPath(_ fullPath:String) -> Bool{
        return fullPath == rootPath
    }
    
    //MARK:是否注册hook
    func isHookRegisted() -> Bool{
        return self.hooKDelegate != nil
    }
    
}

@objc enum Action:Int {
        case createFolder = 1, delete, move, copy, rename
}

protocol FileListDataDelegate:BaseDelegate{
    func onHttpRequest(_ start:Int,fullPath:String,list:Array<FileData>)
}


protocol RequestDelegate:BaseDelegate{
    func onHttpRequest(_ action:Action)
}

@objc protocol BaseDelegate{
    
    func onError(_ errorMsg:String)
    
    func onHookError(_ type:HookType)
    
    func onNetUnable()

}
