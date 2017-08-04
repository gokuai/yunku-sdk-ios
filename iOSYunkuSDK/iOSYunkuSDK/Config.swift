//
//  Config.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

@objc open class SDKConfig :NSObject{
    
    //如果想打印日志，则在外部调用设置为true
    open static var logPrint = false {
        didSet{
            YunkuSwiftSDK.Config.logPrint = logPrint
        }
    
    }
    //设定输入日志的等级
    open static var logLevel = SDKLogLevel.error {
        didSet{
            switch logLevel {
            case SDKLogLevel.error:
                YunkuSwiftSDK.Config.logLevel = YunkuSwiftSDK.LogLevel.error
                
            case SDKLogLevel.info:
                YunkuSwiftSDK.Config.logLevel = YunkuSwiftSDK.LogLevel.info
                
            case SDKLogLevel.warning:
                YunkuSwiftSDK.Config.logLevel = YunkuSwiftSDK.LogLevel.warning
                
            }
        }

    }
    

    //===========================================
    //MARK:以下参数需要开发者赋值

    open static var orgClientId = ""
    open static var orgClientSecret = ""
    open static var orgRootPath = ""
    open static var orgRootTitle = ""

    open static var orgOptName = ""

    //===========================================


    static let imageCachePath = "ImageCache"
    static let httpReferer = "www.gokuai.com"
    static let urlHost = "yunku.gokuai.com"

    static let  fileThumbnailFormat = "http://\(urlHost)/index/thumb?hash=%@&filehash=%@&type=%@&mount_id=%@"
    
}

//MARK:日志等级

@objc public enum SDKLogLevel: Int {
    case info = 0, warning, error
    
    var description: String {
        switch self {
        case .info: return "info";
        case .warning: return "warning";
        case .error: return "error";
        }
    }
    
}

