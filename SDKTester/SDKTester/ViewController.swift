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
    
    @IBAction func btnOnClick(_ sender: AnyObject) {
        
        //设置是否开启日志的等级
        SDKConfig.logLevel = SDKLogLevel.info
        
        //设置是否开启日志
        SDKConfig.logPrint = true
        
        let ykVC = YKMainViewController()
        
        //设置显需要的功能
        let option = Option()
        option.canRename = true
        option.canUpload = true
        option.canDel = true
        ykVC.option = option
        
        ykVC.delegate = self
        
        let navC =  UINavigationController(rootViewController: ykVC)
        
        self.present(navC, animated: true, completion: nil)
        
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
    
    func hookInvoke(_ type: HookType, fullPath: String) -> Bool {
        print("fullPath:\(fullPath)")
        
        if self.forbiddenPath == fullPath{
            var access = true
            
            switch(type){
            case .fileList:
                access = fileListAccess
            case .download:
                access = downloadAccess
            case .upload:
                access = uploadAccess
            case .createDir:
                access = createDirAccess
            case .rename:
                access = renameAccess
            case .delete:
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

