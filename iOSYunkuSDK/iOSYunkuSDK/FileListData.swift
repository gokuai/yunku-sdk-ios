//
//  FileListData.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

class FileListData:BaseData {
    
    static let keyCount = "count"
    static let keyList = "list"
    static let keyPermisson = "permisson"
    
    var count = 0
    var fileList:Array<FileData>!
    var parentPath = ""
    var mountId = 0
    
     override class func create(_ dic:Dictionary<String,AnyObject>) ->FileListData{
        
        let filelistData = FileListData()
        
       let returnResult =  ReturnResult.create(dic)
        var resultDic = returnResult.result
        filelistData.code = returnResult.code
        if returnResult.code == HTTPStatusCode.ok.rawValue{
            let list = resultDic?[keyList] as? NSArray
            filelistData.fileList = Array<FileData>()
//            for  obj:AnyObject in list! {
//                let fileData = FileData.create(obj as! Dictionary<String, AnyObject>)
//                filelistData.fileList.append(fileData)
//            }

        }else{
            filelistData.errorCode = resultDic?[keyErrorcode] as? Int
            filelistData.errorMsg = resultDic?[keyErrormsg] as? String
        
        }
        return filelistData
    
    }
    
    
}
