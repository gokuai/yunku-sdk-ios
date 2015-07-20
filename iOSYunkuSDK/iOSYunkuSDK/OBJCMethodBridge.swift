//
//  OBJCLocalStringConverter.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/15.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

@objc public class OBJCMethodBridge: NSObject {
    
    public class func getLocalString(key:String,comment:String) -> String{
        return NSBundle.getLocalStringFromBundle(key, comment: comment)
    }
    
    public class func getLocalImage(imageName:String)->UIImage{
        return UIImage.imageNameFromMyBundle(imageName)
    }
    
    public class func makeToast(message:String,view:UIView){
        view.makeToast(message: message)
    }
    
    public class func showProgress(control:UIViewController){
        
        DialogUtils.showProgresing(control)
    
    }
    
    public class func hideProgress(control:UIViewController){
        DialogUtils.hideProgresing(control)
    
    }
    
}
