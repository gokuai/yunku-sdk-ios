//
//  BaseData.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import YunkuSwiftSDK

class BaseData:NSObject {
    
    var code: Int! = 0
    var errorMsg: String! = ""
    var errorCode :Int! = 0
    
    static let keyErrorcode = "error_code"
    static let keyErrormsg = "error_msg"
    static let keyCode = "code"
    
    class func create(_ dic:Dictionary<String,AnyObject>) ->BaseData {
        let data = BaseData()

        let returnResult = ReturnResult.create(dic)
        var returnDic = returnResult.result
        data.code = returnResult.code
        if data.code == HTTPStatusCode.ok.rawValue {

        }else {
            
            data.errorCode = returnDic?[keyErrorcode] as? Int
            data.errorMsg = returnDic?[keyErrormsg] as? String
        }
        
        return data


    }
        
}
