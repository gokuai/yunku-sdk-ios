//
//  DialogUtils.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/2.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

class DialogUtils {
    
    class func showNetWorkNotAvailable (_ view:UIView){
        
        view.makeToast(message: Bundle.getLocalStringFromBundle("Network not available", comment: ""))
    }
    
    class func showTipDialog(_ message:String,okBtnString:String,delegate:UIAlertViewDelegate,tag:Int) {
        
        let alert = UIAlertView(title: Bundle.getLocalStringFromBundle("Tip", comment: ""), message: message, delegate: delegate,
            cancelButtonTitle: Bundle.getLocalStringFromBundle("Cancel", comment: ""), otherButtonTitles: okBtnString )
        
        alert.show()
    }
    
    class func showProgresing(_ controller:UIViewController) {
        controller.view.isUserInteractionEnabled = false
        controller.navigationController?.navigationBar.isUserInteractionEnabled = false
        controller.view.makeToastActivity()
    
    }
    
    class func hideProgresing(_ controller:UIViewController) {
        controller.view.isUserInteractionEnabled = true
        controller.navigationController?.navigationBar.isUserInteractionEnabled = true
        controller.view.hideToastActivity()

    }
    
}
