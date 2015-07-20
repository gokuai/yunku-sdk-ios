//
//  NSStringExpend.swift
//  iOSYunkuSDK
//
//  Created by wqc on 15/7/6.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

extension Character{
    var CodeValue: UInt8? {
        let s = String(self)
        let sutf8 = s.utf8
        var code: UInt8?
        for c in  sutf8{
            code = c
            break
        }
        return code
    }
}

extension String{
    func urlEncode()->String{
        let escapeChars = [";" , "/" , "?" , ":" ,
        "@" , "&" , "=" , "+" ,   "$" , "," ,
        "!", "'", "(", ")", "*"];
        let replaceChars = ["%3B" , "%2F", "%3F" , "%3A" ,
        "%40" , "%26" , "%3D" , "%2B" , "%24" , "%2C" ,
        "%21", "%27", "%28", "%29", "%2A"];
        
        let len = escapeChars.count
        
       var temp: NSMutableString = NSMutableString(string: self.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        for i in 0..<len{
            temp.replaceOccurrencesOfString(escapeChars[i], withString: replaceChars[i], options: NSStringCompareOptions.LiteralSearch, range: NSMakeRange(0, temp.length))
        }
        
        
        let outStr: String = temp as String
        
        return outStr;
    }
    
}


