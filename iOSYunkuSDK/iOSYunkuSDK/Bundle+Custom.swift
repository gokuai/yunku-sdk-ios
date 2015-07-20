//
//  Bundle+Custom.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/30.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

extension NSBundle{
    
    class var myResourceBundleInstance : NSBundle? {
        struct Static {
            static let instance : NSBundle = NSBundle(URL: NSBundle.mainBundle().URLForResource("iOSYunkuSDK", withExtension: "bundle")!)!
        }
        
        return Static.instance
    }
   

    class var myLanguageInstance : NSBundle? {
 
        struct Static {
            static let instance : NSBundle =  NSBundle.getBundle()
        }
        return Static.instance
       
    }
    
    private class func getBundle() ->NSBundle{
        
        var language = NSLocale.preferredLanguages()[0].description
        
        var bundle = NSBundle(path: (NSBundle.myResourceBundleInstance?.pathForResource(language, ofType:"lproj"))!)
        
        if bundle == nil {
            bundle = myResourceBundleInstance
        }
        return bundle!
    
    }
    
    public class func getLocalStringFromBundle(key:String,comment:String) ->String{
        return NSLocalizedString(key, tableName: nil, bundle: NSBundle.myResourceBundleInstance!, value: "", comment: comment)
    
    }

}