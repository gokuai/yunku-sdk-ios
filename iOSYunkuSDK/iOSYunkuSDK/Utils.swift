//
//  Utils.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/29.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Utils{
    
    fileprivate static let imgType = ["png", "gif", "jpeg", "jpg", "bmp"]
    fileprivate static let programType = ["ipa", "exe", "pxl", "apk", "bat", "com"]
    fileprivate static let compressType = ["iso", "tar", "rar", "gz", "cab","zip"]
    fileprivate static let videoType = ["3gp", "asf", "avi", "m4v", "mpg", "flv","mkv", "mov", "mp4",
        "mpeg", "mpg", "rm", "rmvb", "ts", "wmv","3gp", "avi"]
    
    fileprivate static let musicType = ["flac", "m4a", "mp3", "ogg", "aac", "ape","wma", "wav"]
    fileprivate static let textType = ["odt", "txt"]
    
    fileprivate static let printType = ["doc", "docx", "xls", "xlsx", "ppt", "pptx","pdf", "txt", "html",
        "htm", "xml", "xhtml", "rtf","csv"]
    
    //TODO:添加预览类型的文件
    fileprivate static let previewType = ["doc","docx","docm","csv","pdf","ppt","pptm","pptx","pps","ppsm","ppsx","pot","potm","potx","odt","ods","odp","xml","txt","rtf","js","asp","aspx","php","jsp","html","htmlx","h","cpp","m","mp3","mp4","m4a","m4v","mov","wav","gknote"]
    
    fileprivate static let docType = "doc"
    fileprivate static let xlsType = "xls"
    fileprivate static let pptType = "ppt"
    fileprivate static let gknoteType = "gknote"
    fileprivate static let pdfType = "pdf"
    
    fileprivate static let resourceFormat = "ic_%@"
    
    fileprivate static let fileListTimeFormat = "YYYY-MM-dd HH:mm"
    fileprivate static let generateFileFormat = "YYYYMMdd_HHmmss"
    
    fileprivate static let documentTypes = ["jpg":"public.jpeg","jpeg":"public.jpeg","png":"public.png","gif":"com.compuserve.gif",
    "bmp":"com.microsoft.bmp",
    "ipa":"com.apple.application-​bundle",
    "pxl":"com.apple.application-​bundle",
    "txt":"public.plain-text",
    "rtf":"public.rtf",
    "html":"public.html",
    "htm":"public.html",
    "xml":"public.xml",
    "tar":"public.tar-archive",
    "gz":"org.gnu.gnu-zip-archive",
    "tif":"public.tiff",
    "mov":"com.apple.quicktime-movie",
    "avi":"public.avi",
    "mpg":"public.mpeg",
    "mp4":"public.mpeg-4",
    "3gp":"public.3gpp",
    "mp3":"public.mp3",
    "m4a":"public.mpeg-4-audio",
    "zip":"com.pkware.zip-archive",
    "pdf":"com.adobe.pdf",
    "wav":"com.microsoft.waveform-​audio",
    "asf":"com.microsoft.advanced-​systems-format",
    "wmv":"com.microsoft.windows-​media-wmv",
    "wma":"com.microsoft.windows-​media-wma",
    "doc":"com.microsoft.word.doc",
    "xls":"com.microsoft.excel.xls",
    "docx":"com.microsoft.word.doc",
    "xlsx":"com.microsoft.excel.xls",
    "ppt":"com.microsoft.powerpoint.​ppt",
    "pptx":"com.microsoft.powerpoint.​ppt"]
    
    class func getIOSVersion() -> Float {
        
        return (UIDevice.current.systemVersion as NSString).floatValue

    }
    
    //MARK:格式化文件大小
    class func formatSize(_ fileSize:UInt64?) -> String {
        if fileSize == nil {
            return "0.0 B"
        }
        
        if fileSize > 1073741824 {
            return String(format: "%.2f G",Double((fileSize! / UInt64(1073741824))))
        }
        
        if fileSize > 1048576 {
            return String(format: "%.1f M",Double((fileSize! / UInt64(1048576))))
        }
        
        if fileSize > 1024 {
            return String(format: "%.1f K",Double((fileSize! / UInt64(1024))))
        }
        
        return String(format: "%.1f B", Double((fileSize!)))

    }
   
    //MARK:格式化文件时间
    class func formatTime(_ seconds:TimeInterval,format:String) ->String{
        let date = Date(timeIntervalSince1970: seconds)
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: date)
    }
    
    //MARK:格式化图片的格式
    class func formatImageNameFromAssetLibrary(_ seconds:TimeInterval) -> String{
         return "IMG_\(Utils.formatTime(seconds, format: Utils.generateFileFormat)).jpg"
    }
    
    //MARK:新 gknote 名称
    class func formatGKnoteName(_ seconds:TimeInterval) -> String {
        return "Note_\(Utils.formatTime(seconds, format: Utils.generateFileFormat)).gknote"
    }
    
    //MARK:格式化文件的时间格式
    class func formatFileTime(_ seconds:TimeInterval) ->String {
        return Utils.formatTime(seconds, format: Utils.fileListTimeFormat)
    }
    
    //MARK:判断是否是图片类型的文件
    class func isImageType(_ fileName:String) ->Bool{
        let ext = fileName.pathExtension.lowercased()
        return Utils.imgType.contains(ext)
    
    }
    
    class func isVideoType(_ fileName:String) ->Bool{
        let ext = fileName.pathExtension.lowercased()
        return Utils.videoType.contains(ext)
    }
    
    class func isAudioType(_ fileName:String) ->Bool{
        let ext = fileName.pathExtension.lowercased()
        return Utils.musicType.contains(ext)
    }
    
    //MARK:判断是否是预览类型的文件
    class func isPreviewType(_ fileName:String) ->Bool {
        let ext = fileName.pathExtension.lowercased()
        return Utils.previewType.contains(ext)
    }
    
    class func isGknoteType(_ fileName:String) ->Bool{
        return fileName.pathExtension == gknoteType
    }
    
    class func isPrintType(_ fileName: String) ->Bool{
        return Utils.previewType.contains(fileName.pathExtension.lowercased())
    }
    
    
    
    //MARK:获取文件对应类型的图标文件名称
    class func getImageIcon(_ fileName:String,dir:Int) ->String{
        
        if dir == FileData.dirs {
            return String(format: Utils.resourceFormat, "dir")
        }else{
            
            let ext = fileName.pathExtension.lowercased()
            if Utils.imgType.contains(ext) {
                
                return String(format: Utils.resourceFormat, "img")
                
            }else if Utils.programType.contains( ext){
                
                return String(format: Utils.resourceFormat, "program")
                
            }else if Utils.compressType.contains( ext){
                return String(format: Utils.resourceFormat, "compress")
                
            }else if Utils.videoType.contains(ext){
                return String(format: Utils.resourceFormat, "video")
                
            }else if Utils.musicType.contains( ext){
                return String(format: Utils.resourceFormat, "music")
                
            }else if Utils.textType.contains( ext){
                return String(format: Utils.resourceFormat, "words_file")
                
            }else if let _ = ext.range(of: docType) {
                return String(format: Utils.resourceFormat, "doc")
                
            }else if let _ =  ext.range(of: xlsType)  {
                return String(format: Utils.resourceFormat, "xls")
                
            }else if let _ =  ext.range(of: pptType) {
                return String(format: Utils.resourceFormat, "ppt")
                
            }else if let _ =  ext.range(of: pdfType) {
                return String(format: Utils.resourceFormat, "pdf")
                
            }else if ext == Utils.gknoteType {
                
                return String(format: Utils.resourceFormat, "gknote")
            }else {
                return String(format: Utils.resourceFormat, "other")
            }
            
        }
    }
    
    class func isVaildName(_ filename:String) -> Bool {
        
        if let range = filename.range(of: ".") {
            if range.lowerBound == filename.startIndex{
                return false
            } else if range.upperBound == filename.endIndex{
                return false
            }

        }
        return true
    }
    
    
    //MARK:判断文件名是否合法
    class func isContainSepcial(_ fileName:String) -> Bool {
        
        if let _ = fileName.range(of: "\\"){
            return true
        }
        
        if let _ = fileName.range(of: ":"){
            return true
        }
        
        if let _ = fileName.range(of: "<"){
            return true
        }
        
        if let _ = fileName.range(of: "|"){
            return true
        }
        
        if let _ = fileName.range(of: "\""){
            return true
        }
        
        if let _ = fileName.range(of: "/"){
            return true
        }
        
        if let _ = fileName.range(of: "*"){
            return true
        }
        
        if let _ = fileName.range(of: "?"){
            return true
        }
        
        if containsEmoji(fileName){
            return true
        }
        return false
    
    }
    
    //MARK:检查是否含有表情符号
    class func containsEmoji(_ text: String) -> Bool {
        var containsEmoji = false
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F:
                // Emoticons
                containsEmoji = true
            case 0x1F300...0x1F5FF:
                // Misc Symbols and Pictographs
                containsEmoji = true
            case 0x1F680...0x1F6FF:
                // Transport and Map
                containsEmoji = true
            case 0x2600...0x26FF:
                // Misc symbols, not all emoji
                containsEmoji = true
            case 0x2700...0x27BF:
                // Dingbats, not all emoji
                containsEmoji = true
            default: ()
            }
        }
        return containsEmoji
    }
    
    //MARK:是否能访问相机
    class func canAcessCamera() -> Bool  {
        if Utils.getIOSVersion() >= 7 {
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted {
                return false
            }
        }
        return true
    }
    
    //MARK:是否能访问相册
    class func canAccessPhotos() -> Bool  {
        if Utils.getIOSVersion() >= 6 {
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted {
                return false
            }
        }
        return true
    }
    
    //MARK:把图片数据放置缓存目录
    class func saveImageToCache(_ image:UIImage,fileName:String) ->String{
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] 
        let imageCachePath = cachePath.stringByAppendingPathComponent(path: SDKConfig.imageCachePath)
        let destinationPath = imageCachePath.stringByAppendingPathComponent(path: fileName)
        
        if !FileManager.default.fileExists(atPath: imageCachePath) {
            
            do{
                try  FileManager.default.createDirectory(atPath: imageCachePath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            
           
        }
        
        try? UIImageJPEGRepresentation(image,1.0)!.write(to: URL(fileURLWithPath: destinationPath), options: [.atomic])
        return destinationPath
    }
    
    //MARK:获取文件上传的路径
    class func getUploadPath() ->String {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] 
        let destinationPath = cachePath.stringByAppendingPathComponent(path: "UploadCache")
        if !FileManager.default.fileExists(atPath: destinationPath) {
            
            do{
                try  FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return destinationPath
    }
    
    //MARK:获取zipCache 路径
    class func getZipCachePath() -> String {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] 
        let destinationPath = cachePath.stringByAppendingPathComponent(path: "Zips")
        if !FileManager.default.fileExists(atPath: destinationPath) {
            
            do{
                try  FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            
        }
        return destinationPath
    }
    
    //MARK:获取FileCache 路径
    class func getFileCachePath() -> String{
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] 
        let destinationPath = cachePath.stringByAppendingPathComponent(path: "FileCache")
        if !FileManager.default.fileExists(atPath: destinationPath) {
            do{
                try  FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return destinationPath
    }
    
    class func getThumbCachePath() -> String {
        
        let cachePath = Utils.getFileCachePath()
        let destinationPath = cachePath.stringByAppendingPathComponent(path: "Thumbnail")
        if !FileManager.default.fileExists(atPath: destinationPath) {
            do{
                try  FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return destinationPath
    }
    
    //MARK:获取assets-library: 中的图片数据
    class func getImageFromPath(_ path: String) -> UIImage? {
        let assetsLibrary = ALAssetsLibrary()
        let url = URL(string: path)!
        
        var image: UIImage?
        var loadError: NSError?
        assetsLibrary.asset(for: url, resultBlock: { (asset) -> Void in
            image = UIImage(cgImage: asset!.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
            }, failureBlock: { (error) -> Void in
                loadError = error;
        } as! ALAssetsLibraryAccessFailureBlock)
        
        
        if (loadError != nil) {
            return image
        } else {
            return nil
        }
    }
    
    //MARK:压缩文件
    class func compressToZipWithZipPath(_ zipPath:String,sourcePaths:Array<String>,success:@escaping (() -> Void),fail:@escaping (() -> Void)){
        
        let path = URL(fileURLWithPath: zipPath)
        
 
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            
            var archive:ZZArchive!
            var isSuccess = true
            do{
                archive = try ZZArchive(url: path, options: [ ZZOpenOptionsCreateIfMissingKey : true ])
            }catch _ as NSError{
                isSuccess = false
            }
            
            var list = Array<ZZArchiveEntry> ()
            
            for pathString in sourcePaths {
                let fileName = pathString.lastPathComponent
                var isDir : ObjCBool = false
                if FileManager.default.fileExists(atPath: pathString, isDirectory:&isDir) {
                    if isDir.boolValue {
                        list.append(ZZArchiveEntry(directoryName: fileName))
                    } else {
                        list.append(ZZArchiveEntry(fileName: fileName, compress: true, dataBlock: { (err) -> Data! in
                            
                            return (try? Data(contentsOf: URL(fileURLWithPath: pathString)))
                            
                        }))

                    }
                }
                
                if !isSuccess{
                    break
                }
            }
            
            if isSuccess{
                
                do {
                
                    try archive.updateEntries(list)
                }catch _ as NSError{
                    isSuccess = false
                }
            }
            
            if isSuccess{
                DispatchQueue.main.async(execute: success)
            }else{
                DispatchQueue.main.async(execute: fail)
            }
        })

    }
    
    //MARK:解压zip
    class func unZipWithSource(_ sourcePath:String,targetFileName:String,success:@escaping (() -> Void),fail:@escaping (() -> Void)) {
        
//        var err: NSError? = NSError()
        let path = URL(fileURLWithPath: sourcePath)

 
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            var isSuccess = true
            do {
                
                _ = sourcePath
                let unzipTo = Utils.getZipCachePath().stringByAppendingPathComponent(path: targetFileName)
                let archive = try ZZArchive(url:(fileURLWithPath:path) as! URL)
                let list = archive.entries
                
                for entry  in list!{
                    
                    let zzArchive = entry as! ZZArchiveEntry
                    var data:Data
                    
                    data = try zzArchive.newData()
                    let destpath = "\(unzipTo)/\(zzArchive.fileName)"
                    try? data.write(to: URL(fileURLWithPath: destpath), options: [])
                    
                    
                }
                
            }catch let error as NSError{
                print("\(error.userInfo); \(error.localizedDescription)")
                isSuccess = false

            }
            
            if isSuccess {
                DispatchQueue.main.async(execute: success)
            }else{
                DispatchQueue.main.async(execute: fail)
            }
            
        })
    }
    
    //MARK:获取文件大小
    class func getFileSizeWithPath(_ path:String) -> UInt64! {
        let handler =  FileHandle(forReadingAtPath: path)
        let length = handler?.seekToEndOfFile()
        handler?.closeFile()
        return length
    }
    
    class func replaceStrBySearchStr(_ body: String, search: String, replace: String) -> String{
        var substr = (body as NSString).range(of: search)
        
        
        let bodyMutable = NSMutableString(string: body)
        var location = -1
        while (substr.location != NSNotFound) {
            if (location == substr.location) {
                break;
            }
            bodyMutable.replaceCharacters(in: substr, with: replace)
            substr = bodyMutable.range(of: search)
            location = substr.location;
        }
        return bodyMutable as String;
    }
    
    
    class func getDocumentUTIType(_ ext: String)->String{
        let type = ext.lowercased()
        if let ret = documentTypes[type]{
            return ret
        } else {
            return "public.content"
        }
    }
    
    class func getFileNameWithoutExt(_ fileName: String)->String{
        var fname: NSString = fileName as NSString
        let ext: NSString = fname.pathExtension as NSString
        if (ext.length != 0) {
            fname = fname.substring(to: fname.length - ext.length - 1) as NSString
        }
        return fname as String
    }

}
