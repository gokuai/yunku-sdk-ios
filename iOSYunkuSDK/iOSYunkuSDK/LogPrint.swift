//
// Created by Brandon on 15/5/29.
// Copyright (c) 2015 Brandon. All rights reserved.
//

import Foundation

@objc class LogPrint: NSObject {

    private class func printLog<T>(log: T, logLevel: SDKLogLevel) {

        if SDKConfig.logPrint {

            if logLevel.rawValue >= SDKConfig.logLevel.rawValue {
                print("LogLevel:\(logLevel.description), \(log)")
            }

        }

    }


    class func error<T>(msg: T) {
        printLog(msg, logLevel: SDKLogLevel.Error)
    }

    class func warning<T>(msg: T) {
        printLog(msg, logLevel: SDKLogLevel.Warning)

    }

    class func info<T>(msg: T) {
        printLog(msg, logLevel: SDKLogLevel.Info)
    }

}
