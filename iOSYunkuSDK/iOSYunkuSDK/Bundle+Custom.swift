//
//  Bundle+Custom.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/30.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation

extension Bundle{
    
    class var myResourceBundleInstance : Bundle? {
        struct Static {
            static let instance : Bundle = Bundle(url: Bundle.main.url(forResource: "iOSYunkuSDK", withExtension: "bundle")!)!
        }
        
        return Static.instance
    }
   

    class var myLanguageInstance : Bundle? {
 
        struct Static {
            static let instance : Bundle =  Bundle.getBundle()
        }
        return Static.instance
       
    }
    
    fileprivate class func getBundle() ->Bundle{
        
        let language = Locale.preferredLanguages[0]
        
        var bundle = Bundle(path: (Bundle.myResourceBundleInstance?.path(forResource: language, ofType:"lproj"))!)
        
        if bundle == nil {
            bundle = myResourceBundleInstance
        }
        return bundle!
    
    }
    
    public class func getLocalStringFromBundle(_ key:String,comment:String) ->String{
        return NSLocalizedString(key, tableName: nil, bundle: Bundle.myResourceBundleInstance!, value: "", comment: comment)
    
    }

}
