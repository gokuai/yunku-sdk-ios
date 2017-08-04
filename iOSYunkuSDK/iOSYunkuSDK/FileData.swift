//
//  FileData.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

class FileData:BaseData{

    static let dirs = 1

    static let keyHash = "hash"
    static let keyFilename = "filename"
    static let keyFilehash = "filehash"
    static let keyFilesize = "filesize"
    static let keyFullpath = "fullpath"
    static let keyDir = "dir"
    static let keyLastdateline = "last_dateline"
    static let keyLastmemberid = "last_member_id"
    static let keyLastmembername = "last_member_name"
    static let keyPreview = "preview"
    static let keyMountid = "mount_id"
    static let keyVersion = "version"
    static let keyUri = "uri"
    static let keyUris = "uris"
    static let keyCreateId = "create_member_id"
    static let keyCreateTime = "create_dateline"
    static let keyCreateName = "create_member_name"
    static let keyLock = "lock"
    static let keyThumbnail = "thumbnail"
    static let keyMountId = "mount_id"
    
    var uuidHash:String! = ""
    var fileName:String! = ""
    var fileHash:String! = ""
    var fileSize:UInt64? = 0
    var fullPath:String! = ""
    var dir:Int! = 0
    var lastDateline:Int! = 0
    var lastMemberId:Int! = 0
    var lastMemberName:String! = ""
    var preview:String! = ""
    var version:String! = ""
    var uri:String! = ""
    var createId:Int! = 0
    var createTime:Int! = 0
    var createName:String! = ""
    var lock:Int! = 0
    var mountId:Int! = 0
    
    var isFoot:Bool = false
    
    var icons:String! {
        return Utils.getImageIcon(self.fileName, dir: self.dir)
    }
    
    class func createFooter() -> FileData {
        let data = FileData()
        data.isFoot = true
        return data
    }
    
    var thumbNail:String! 
    
    var thumbBig:String{
        get{
            return "\(self.thumbNail)&big=1"
        }
    }
    
    override class func create(_ dic:Dictionary<String,AnyObject>)->FileData {
        let data = FileData()

        data.uuidHash = dic[keyHash] as? String
        data.fileName = dic[keyFilename] as? String
        data.fileHash = dic[keyFilehash] as? String
        
        let fileSize = dic[keyFilesize] as? Double //直接转 UInt64会失败
        if fileSize != nil {
           data.fileSize = UInt64(fileSize!)
        }
        data.fullPath = dic[keyFullpath] as? String
        data.dir = dic[keyDir] as? Int
        data.lastDateline = dic[keyLastdateline] as? Int
        data.lastMemberName = dic[keyLastmembername] as? String
        data.preview = dic[keyPreview] as? String
        data.version = dic[keyVersion] as? String
        data.uri = dic[keyUri] as? String
        data.createId = dic[keyCreateId] as? Int
        data.createName = dic[keyCreateName] as? String
        data.createTime = dic[keyCreateTime] as? Int
        data.thumbNail = dic[keyThumbnail] as? String
        return data
    }
    
    
    

}

