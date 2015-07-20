//
//  UIView+Rect.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/29.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

extension UIViewController{

    func clientRect() -> CGRect{
        var rect = UIScreen.mainScreen().bounds
        if((self.navigationController?.navigationBarHidden) != nil){
            rect.origin.y = 0
            
            if( Utils.getIOSVersion()>=7&&Utils.getIOSVersion() < 8){
                rect.size.height -= 64
            }else if(Utils.getIOSVersion() >= 8){
                
            }else {
                rect.size.height -= 44
            }
  
        }
        return rect
    }

}

