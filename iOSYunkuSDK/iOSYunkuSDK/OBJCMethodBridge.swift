//
//  OBJCLocalStringConverter.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/15.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

@objc open class OBJCMethodBridge: NSObject {
    
    open class func getLocalString(_ key:String,comment:String) -> String{
        return Bundle.getLocalStringFromBundle(key, comment: comment)
    }
    
    open class func getLocalImage(_ imageName:String)->UIImage{
        return UIImage.imageNameFromMyBundle(imageName)
    }
    
    open class func makeToast(_ message:String,view:UIView){
        view.makeToast(message: message, duration: HRToastDefaultDuration, position: HRToastPositionCenter as AnyObject)
    }
    
    open class func showProgress(_ control:UIViewController){
        
        DialogUtils.showProgresing(control)
    
    }
    
    open class func hideProgress(_ control:UIViewController){
        DialogUtils.hideProgresing(control)
    
    }
    
}
