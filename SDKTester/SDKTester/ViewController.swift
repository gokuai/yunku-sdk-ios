//
//  ViewController.swift
//  SDKTester
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit
import iOSYunkuSDK

class ViewController: UIViewController,HookDelegate {

    @IBOutlet weak var TestBtn: UIButton!
    
    @IBAction func btnOnClick(sender: AnyObject) {
        
        //设置是否开启日志的等级
        SDKConfig.logLevel = SDKLogLevel.Info
        
        //设置是否开启日志
        SDKConfig.logPrint = true
        
        var ykVC = YKMainViewController()
        
        //设置显需要的功能
        var option = Option()
        option.canRename = true
        option.canUpload = true
        option.canDel = true
        ykVC.option = option
        
        ykVC.delegate = self
        
        var navC =  UINavigationController(rootViewController: ykVC)
        
        self.presentViewController(navC, animated: true, completion: nil)
        
        //navigation control push
//      self.navigationController?.pushViewController(YKMainViewController(), animated: true)
        
    }
    
    let forbiddenPath = "FilePath"
    let fileListAccess = true
    let downloadAccess = true
    let uploadAccess = true
    let createDirAccess = true
    let renameAccess = true
    let deleteAccess = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hookInvoke(type: HookType, fullPath: String) -> Bool {
        println("fullPath:\(fullPath)")
        
        if self.forbiddenPath == fullPath{
            var access = true
            
            switch(type){
            case .FileList:
                access = fileListAccess
            case .Download:
                access = downloadAccess
            case .Upload:
                access = uploadAccess
            case .CreateDir:
                access = createDirAccess
            case .Rename:
                access = renameAccess
            case .Delete:
                access = deleteAccess
            default:
                ()
            }
            
            if !access{
                UIAlertView(title: nil, message: "Hook：此操作不被允许", delegate: nil, cancelButtonTitle: "Cancel").show()
            }
            
            return access
        }

        return true
    }


}

