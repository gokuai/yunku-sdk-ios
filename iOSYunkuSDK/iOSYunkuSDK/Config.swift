//
//  Config.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

@objc public class SDKConfig :NSObject{
    
    //如果想打印日志，则在外部调用设置为true
    public static var logPrint = false {
        didSet{
            YunkuSwiftSDK.Config.logPrint = logPrint
        }
    
    }
    //设定输入日志的等级
    public static var logLevel = SDKLogLevel.Error {
        didSet{
            switch logLevel {
            case SDKLogLevel.Error:
                YunkuSwiftSDK.Config.logLevel = YunkuSwiftSDK.LogLevel.Error
                
            case SDKLogLevel.Info:
                YunkuSwiftSDK.Config.logLevel = YunkuSwiftSDK.LogLevel.Info
                
            case SDKLogLevel.Warning:
                YunkuSwiftSDK.Config.logLevel = YunkuSwiftSDK.LogLevel.Warning
                
            }
        }

    }
    

    //===========================================
    //MARK:以下参数需要开发者赋值

    public static var orgClientId = ""
    public static var orgClientSecret = ""
    public static var orgRootPath = ""
    public static var orgRootTitle = ""
    public static var orgOptName = ""

    //===========================================


    static let imageCachePath = "ImageCache"
    static let httpReferer = "www.gokuai.com"
    static let urlHost = "yunku.gokuai.com"

    static let  fileThumbnailFormat = "http://\(urlHost)/index/thumb?hash=%@&filehash=%@&type=%@&mount_id=%@"
    
}

//MARK:日志等级

@objc public enum SDKLogLevel: Int {
    case Info = 0, Warning, Error
    
    var description: String {
        switch self {
        case .Info: return "info";
        case .Warning: return "warning";
        case .Error: return "error";
        }
    }
    
}

