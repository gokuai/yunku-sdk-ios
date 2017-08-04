//
// Created by Brandon on 15/5/29.
// Copyright (c) 2015 Brandon. All rights reserved.
//

import Foundation

@objc class LogPrint: NSObject {

    fileprivate class func printLog<T>(_ log: T, logLevel: SDKLogLevel) {

        if SDKConfig.logPrint {

            if logLevel.rawValue >= SDKConfig.logLevel.rawValue {
                print("LogLevel:\(logLevel.description), \(log)")
            }

        }

    }


    class func error<T>(_ msg: T) {
        printLog(msg, logLevel: SDKLogLevel.error)
    }

    class func warning<T>(_ msg: T) {
        printLog(msg, logLevel: SDKLogLevel.warning)

    }

    class func info<T>(_ msg: T) {
        printLog(msg, logLevel: SDKLogLevel.info)
    }

}
