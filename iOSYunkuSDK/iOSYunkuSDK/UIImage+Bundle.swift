//
//  UIImageExtension.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/30.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

extension UIImage{

    class func imageNameFromMyBundle(imgName:String) ->UIImage{
        let imgPath = NSBundle.myResourceBundleInstance?.pathForResource(imgName, ofType: "png", inDirectory: "Resources/Icons")
        return UIImage(contentsOfFile: imgPath!)!
    }


}