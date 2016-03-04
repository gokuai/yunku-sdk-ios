//
//  DialogUtils.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/2.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

class DialogUtils {
    
    class func showNetWorkNotAvailable (view:UIView){
        
        view.makeToast(message: NSBundle.getLocalStringFromBundle("Network not available", comment: ""))
    }
    
    class func showTipDialog(message:String,okBtnString:String,delegate:UIAlertViewDelegate,tag:Int) {
        
        let alert = UIAlertView(title: NSBundle.getLocalStringFromBundle("Tip", comment: ""), message: message, delegate: delegate,
            cancelButtonTitle: NSBundle.getLocalStringFromBundle("Cancel", comment: ""), otherButtonTitles: okBtnString )
        
        alert.show()
    }
    
    class func showProgresing(controller:UIViewController) {
        controller.view.userInteractionEnabled = false
        controller.navigationController?.navigationBar.userInteractionEnabled = false
        controller.view.makeToastActivity()
    
    }
    
    class func hideProgresing(controller:UIViewController) {
        controller.view.userInteractionEnabled = true
        controller.navigationController?.navigationBar.userInteractionEnabled = true
        controller.view.hideToastActivity()

    }
    
}
