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

class Utils{
    
    private static let imgType = ["png", "gif", "jpeg", "jpg", "bmp"]
    private static let programType = ["ipa", "exe", "pxl", "apk", "bat", "com"]
    private static let compressType = ["iso", "tar", "rar", "gz", "cab","zip"]
    private static let videoType = ["3gp", "asf", "avi", "m4v", "mpg", "flv","mkv", "mov", "mp4",
        "mpeg", "mpg", "rm", "rmvb", "ts", "wmv","3gp", "avi"]
    
    private static let musicType = ["flac", "m4a", "mp3", "ogg", "aac", "ape","wma", "wav"]
    private static let textType = ["odt", "txt"]
    
    private static let printType = ["doc", "docx", "xls", "xlsx", "ppt", "pptx","pdf", "txt", "html",
        "htm", "xml", "xhtml", "rtf","csv"]
    
    //TODO:添加预览类型的文件
    private static let previewType = ["doc","docx","docm","csv","pdf","ppt","pptm","pptx","pps","ppsm","ppsx","pot","potm","potx","odt","ods","odp","xml","txt","rtf","js","asp","aspx","php","jsp","html","htmlx","h","cpp","m","mp3","mp4","m4a","m4v","mov","wav","gknote"]
    
    private static let docType = "doc"
    private static let xlsType = "xls"
    private static let pptType = "ppt"
    private static let gknoteType = "gknote"
    private static let pdfType = "pdf"
    
    private static let resourceFormat = "ic_%@"
    
    private static let fileListTimeFormat = "YYYY-MM-dd HH:mm"
    private static let generateFileFormat = "YYYYMMdd_HHmmss"
    
    private static let documentTypes = ["jpg":"public.jpeg","jpeg":"public.jpeg","png":"public.png","gif":"com.compuserve.gif",
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
        
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue

    }
    
    //MARK:格式化文件大小
    class func formatSize(fileSize:UInt64?) -> String {
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
    class func formatTime(seconds:NSTimeInterval,format:String) ->String{
        let date = NSDate(timeIntervalSince1970: seconds)
        let formater = NSDateFormatter()
        formater.dateFormat = format
        return formater.stringFromDate(date)
    }
    
    //MARK:格式化图片的格式
    class func formatImageNameFromAssetLibrary(seconds:NSTimeInterval) -> String{
         return "IMG_\(Utils.formatTime(seconds, format: Utils.generateFileFormat)).jpg"
    }
    
    //MARK:新 gknote 名称
    class func formatGKnoteName(seconds:NSTimeInterval) -> String {
        return "Note_\(Utils.formatTime(seconds, format: Utils.generateFileFormat)).gknote"
    }
    
    //MARK:格式化文件的时间格式
    class func formatFileTime(seconds:NSTimeInterval) ->String {
        return Utils.formatTime(seconds, format: Utils.fileListTimeFormat)
    }
    
    //MARK:判断是否是图片类型的文件
    class func isImageType(fileName:String) ->Bool{
        let ext = fileName.pathExtension.lowercaseString
        return Utils.imgType.contains(ext)
    
    }
    
    class func isVideoType(fileName:String) ->Bool{
        let ext = fileName.pathExtension.lowercaseString
        return Utils.videoType.contains(ext)
    }
    
    class func isAudioType(fileName:String) ->Bool{
        let ext = fileName.pathExtension.lowercaseString
        return Utils.musicType.contains(ext)
    }
    
    //MARK:判断是否是预览类型的文件
    class func isPreviewType(fileName:String) ->Bool {
        let ext = fileName.pathExtension.lowercaseString
        return Utils.previewType.contains(ext)
    }
    
    class func isGknoteType(fileName:String) ->Bool{
        return fileName.pathExtension == gknoteType
    }
    
    class func isPrintType(fileName: String) ->Bool{
        return Utils.previewType.contains(fileName.pathExtension.lowercaseString)
    }
    
    
    
    //MARK:获取文件对应类型的图标文件名称
    class func getImageIcon(fileName:String,dir:Int) ->String{
        
        if dir == FileData.dirs {
            return String(format: Utils.resourceFormat, "dir")
        }else{
            
            let ext = fileName.pathExtension.lowercaseString
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
                
            }else if let _ = ext.rangeOfString(docType) {
                return String(format: Utils.resourceFormat, "doc")
                
            }else if let _ =  ext.rangeOfString(xlsType)  {
                return String(format: Utils.resourceFormat, "xls")
                
            }else if let _ =  ext.rangeOfString(pptType) {
                return String(format: Utils.resourceFormat, "ppt")
                
            }else if let _ =  ext.rangeOfString(pdfType) {
                return String(format: Utils.resourceFormat, "pdf")
                
            }else if ext == Utils.gknoteType {
                
                return String(format: Utils.resourceFormat, "gknote")
            }else {
                return String(format: Utils.resourceFormat, "other")
            }
            
        }
    }
    
    class func isVaildName(filename:String) -> Bool {
        
        if let range = filename.rangeOfString(".") {
            if range.startIndex == filename.startIndex{
                return false
            } else if range.endIndex == filename.endIndex{
                return false
            }

        }
        return true
    }
    
    
    //MARK:判断文件名是否合法
    class func isContainSepcial(fileName:String) -> Bool {
        
        if let _ = fileName.rangeOfString("\\"){
            return true
        }
        
        if let _ = fileName.rangeOfString(":"){
            return true
        }
        
        if let _ = fileName.rangeOfString("<"){
            return true
        }
        
        if let _ = fileName.rangeOfString("|"){
            return true
        }
        
        if let _ = fileName.rangeOfString("\""){
            return true
        }
        
        if let _ = fileName.rangeOfString("/"){
            return true
        }
        
        if let _ = fileName.rangeOfString("*"){
            return true
        }
        
        if let _ = fileName.rangeOfString("?"){
            return true
        }
        
        if containsEmoji(fileName){
            return true
        }
        return false
    
    }
    
    //MARK:检查是否含有表情符号
    class func containsEmoji(text: String) -> Bool {
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
            let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            if authStatus == AVAuthorizationStatus.Denied || authStatus == AVAuthorizationStatus.Restricted {
                return false
            }
        }
        return true
    }
    
    //MARK:是否能访问相册
    class func canAccessPhotos() -> Bool  {
        if Utils.getIOSVersion() >= 6 {
            let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            if authStatus == AVAuthorizationStatus.Denied || authStatus == AVAuthorizationStatus.Restricted {
                return false
            }
        }
        return true
    }
    
    //MARK:把图片数据放置缓存目录
    class func saveImageToCache(image:UIImage,fileName:String) ->String{
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] 
        let imageCachePath = cachePath.stringByAppendingPathComponent(SDKConfig.imageCachePath)
        let destinationPath = imageCachePath.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(imageCachePath) {
            
            do{
                try  NSFileManager.defaultManager().createDirectoryAtPath(imageCachePath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            
           
        }
        
        UIImageJPEGRepresentation(image,1.0)!.writeToFile(destinationPath, atomically: true)
        return destinationPath
    }
    
    //MARK:获取文件上传的路径
    class func getUploadPath() ->String {
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] 
        let destinationPath = cachePath.stringByAppendingPathComponent("UploadCache")
        if !NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
            
            do{
                try  NSFileManager.defaultManager().createDirectoryAtPath(destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return destinationPath
    }
    
    //MARK:获取zipCache 路径
    class func getZipCachePath() -> String {
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] 
        let destinationPath = cachePath.stringByAppendingPathComponent("Zips")
        if !NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
            
            do{
                try  NSFileManager.defaultManager().createDirectoryAtPath(destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            
        }
        return destinationPath
    }
    
    //MARK:获取FileCache 路径
    class func getFileCachePath() -> String{
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] 
        let destinationPath = cachePath.stringByAppendingPathComponent("FileCache")
        if !NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
            do{
                try  NSFileManager.defaultManager().createDirectoryAtPath(destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return destinationPath
    }
    
    class func getThumbCachePath() -> String {
        
        let cachePath = Utils.getFileCachePath()
        let destinationPath = cachePath.stringByAppendingPathComponent("Thumbnail")
        if !NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
            do{
                try  NSFileManager.defaultManager().createDirectoryAtPath(destinationPath, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return destinationPath
    }
    
    //MARK:获取assets-library: 中的图片数据
    class func getImageFromPath(path: String) -> UIImage? {
        let assetsLibrary = ALAssetsLibrary()
        let url = NSURL(string: path)!
        
        var image: UIImage?
        var loadError: NSError?
        assetsLibrary.assetForURL(url, resultBlock: { (asset) -> Void in
            image = UIImage(CGImage: asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
            }, failureBlock: { (error) -> Void in
                loadError = error;
        })
        
        
        if (loadError != nil) {
            return image
        } else {
            return nil
        }
    }
    
    //MARK:压缩文件
    class func compressToZipWithZipPath(zipPath:String,sourcePaths:Array<String>,success:(() -> Void),fail:(() -> Void)){
        
        let path = NSURL.fileURLWithPath(zipPath)
        
 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            var archive:ZZArchive!
            var isSuccess = true
            do{
                archive = try ZZArchive(URL: path, options: [ ZZOpenOptionsCreateIfMissingKey : true ])
            }catch _ as NSError{
                isSuccess = false
            }
            
            var list = Array<ZZArchiveEntry> ()
            
            for pathString in sourcePaths {
                let fileName = pathString.lastPathComponent
                var isDir : ObjCBool = false
                if NSFileManager.defaultManager().fileExistsAtPath(pathString, isDirectory:&isDir) {
                    if isDir {
                        list.append(ZZArchiveEntry(directoryName: fileName))
                    } else {
                        list.append(ZZArchiveEntry(fileName: fileName, compress: true, dataBlock: { (err) -> NSData! in
                            
                            return NSData(contentsOfFile: pathString)
                            
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
                dispatch_async(dispatch_get_main_queue(), success)
            }else{
                dispatch_async(dispatch_get_main_queue(), fail)
            }
        })

    }
    
    //MARK:解压zip
    class func unZipWithSource(sourcePath:String,targetFileName:String,success:(() -> Void),fail:(() -> Void)) {
        
//        var err: NSError? = NSError()
        let path = NSURL.fileURLWithPath(sourcePath)

 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var isSuccess = true
            do {
                
                _ = sourcePath
                let unzipTo = Utils.getZipCachePath().stringByAppendingPathComponent(targetFileName)
                let archive = try ZZArchive(URL:(fileURLWithPath:path))
                let list = archive.entries
                
                for entry  in list{
                    
                    let zzArchive = entry as! ZZArchiveEntry
                    var data:NSData
                    
                    data = try zzArchive.newData()
                    let destpath = "\(unzipTo)/\(zzArchive.fileName)"
                    data.writeToFile(destpath, atomically: false)
                    
                    
                }
                
            }catch let error as NSError{
                print("\(error.userInfo); \(error.localizedDescription)")
                isSuccess = false

            }
            
            if isSuccess {
                dispatch_async(dispatch_get_main_queue(), success)
            }else{
                dispatch_async(dispatch_get_main_queue(), fail)
            }
            
        })
    }
    
    //MARK:获取文件大小
    class func getFileSizeWithPath(path:String) -> UInt64! {
        let handler =  NSFileHandle(forReadingAtPath: path)
        let length = handler?.seekToEndOfFile()
        handler?.closeFile()
        return length
    }
    
    class func replaceStrBySearchStr(body: String, search: String, replace: String) -> String{
        var substr = (body as NSString).rangeOfString(search)
        
        
        let bodyMutable = NSMutableString(string: body)
        var location = -1
        while (substr.location != NSNotFound) {
            if (location == substr.location) {
                break;
            }
            bodyMutable.replaceCharactersInRange(substr, withString: replace)
            substr = bodyMutable.rangeOfString(search)
            location = substr.location;
        }
        return bodyMutable as String;
    }
    
    
    class func getDocumentUTIType(ext: String)->String{
        let type = ext.lowercaseString
        if let ret = documentTypes[type]{
            return ret
        } else {
            return "public.content"
        }
    }
    
    class func getFileNameWithoutExt(fileName: String)->String{
        var fname: NSString = fileName
        let ext: NSString = fname.pathExtension
        if (ext.length != 0) {
            fname = fname.substringToIndex(fname.length - ext.length - 1)
        }
        return fname as String
    }

}
