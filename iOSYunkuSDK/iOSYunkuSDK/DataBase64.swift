//
//  DataBase64.swift
//  iOSYunkuSDK
//
//  Created by wqc on 15/7/6.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

extension NSData{
    class func base64Decoded(str: String) -> NSData? {
        var retData: NSData? = nil
        let lookup: [CChar] = [99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
            99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
            99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
            52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
            99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
            15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
            99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
            41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99]
        var inputData: NSData? = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        if inputData == nil {
            return nil
        }
        let inputLength: Int = inputData!.length
        if inputLength <= 0 {
            return nil
        }
        
        var inputBytes = inputData!.bytes
        let maxOutputLength: Int = (inputLength/4+1)*3
        var outputData: NSMutableData! = NSMutableData(capacity: maxOutputLength)
        var outputBytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(outputData.mutableBytes)
        var accumulator: Int = 0
        var outputLength: Int = 0
        var accumulated: [CUnsignedChar] = [0,0,0,0]
        
        for i in 0 ..< inputLength {
            var decoded: CUnsignedChar = CUnsignedChar(lookup[Int(inputBytes[i]) & 0x7f])
            if decoded != 99 {
                accumulated[accumulator] = decoded
                if accumulator == 3 {
                    
                    outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                    outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                    outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];

                }
                accumulator = (accumulator+1) % 4
            }
        }
        
        if (accumulator > 0) {
            outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4)
        }
        if (accumulator > 1) {
            outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2)
        }
        if (accumulator > 2) {
            outputLength++
        }
        outputData.length = outputLength
        
        return outputLength>0 ? outputData : nil
    }
    
    func base64Encoded()->String?{
        let str:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        var lookup = Array<CUnsignedChar>()
        for ch in str.utf8{
            lookup += [ch]
        }
        let inputLength = self.length
        let inputBytes: UnsafePointer<CUnsignedChar> = UnsafePointer<CUnsignedChar>(self.bytes)
        let maxOutputLength: Int = (inputLength / 3 + 1) * 4;
        var outputBytes: UnsafeMutablePointer<CUnsignedChar> = UnsafeMutablePointer<CUnsignedChar>(malloc(maxOutputLength))
        var outputLength = 0;
        var i: Int = 0
        for i = 0;i<(inputLength - 2);i += 3{
            outputBytes[outputLength++] = lookup[Int((inputBytes[i] & 0xFC) >> 2)]
            outputBytes[outputLength++] = lookup[Int(((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4))]
            outputBytes[outputLength++] = lookup[Int(((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6))]
            outputBytes[outputLength++] = lookup[Int(inputBytes[i + 2] & 0x3F)]
        }
        if (i == inputLength - 2)
        {
            outputBytes[outputLength++] = lookup[Int((inputBytes[i] & 0xFC) >> 2)]
            outputBytes[outputLength++] = lookup[Int(((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4))]
            outputBytes[outputLength++] = lookup[Int((inputBytes[i + 1] & 0x0F) << 2)]
            outputBytes[outputLength++] = Character("=").CodeValue!
            
        }
        else if (i == inputLength - 1)
        {
            outputBytes[outputLength++] = lookup[Int((inputBytes[i] & 0xFC) >> 2)]
            outputBytes[outputLength++] = lookup[Int((inputBytes[i] & 0x03) << 4)]
            outputBytes[outputLength++] = Character("=").CodeValue!
            outputBytes[outputLength++] = Character("=").CodeValue!
        }
        outputBytes = UnsafeMutablePointer<CUnsignedChar>(realloc(outputBytes, outputLength))
        let result = NSString(bytesNoCopy: outputBytes, length: outputLength, encoding: NSASCIIStringEncoding, freeWhenDone: true)
        
        if outputLength >= 4{
            free(outputBytes)
            return result as? String
        }
        
        free(outputBytes)
        return nil
    }
}