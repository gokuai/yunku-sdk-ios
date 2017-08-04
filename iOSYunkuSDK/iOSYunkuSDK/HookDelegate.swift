//
//  HookCallback.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

@objc public protocol HookDelegate{
    
     func hookInvoke(_ type:HookType,fullPath:String) -> Bool

}

@objc public enum HookType:Int {
    case fileList = 0 ,download, upload,createDir,rename,delete
}
