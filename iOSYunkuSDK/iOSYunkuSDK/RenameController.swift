//
//  RenameController.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/2.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation


class RenameController: NameController {
    
    var filePath = ""
    var fileIndex = 0
    var delegate:RenameDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.title = NSBundle.getLocalStringFromBundle("Rename", comment: "")
        
        self.navigationItem.title = NSBundle.getLocalStringFromBundle("Rename", comment: "")
        self.textField.placeholder = NSBundle.getLocalStringFromBundle("Enter new name", comment: "")
        
        self.filePath = self.list[self.fileIndex].fullPath
        
    }
    
    
    override func onFinish(sender:AnyObject?){
        self.rename()
    }
    
    //MARK:重命名
    func rename() {
        var folderName = self.textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        for data in self.list{
            if data.dir != FileData.dirs {
                continue
            }else{
                if data.fileName == folderName {
                    self.errorLabel.hidden = false
                    self.errorLabel.text = NSBundle.getLocalStringFromBundle("File has been exit", comment: "")
                    return
                }
            }
        }
        
        DialogUtils.showProgresing(self)
        
        FileDataManager.sharedInstance?.rename(filePath, newName: folderName, delegate: self)
        self.highLightName = folderName
    }
    
    override func onHttpRequest(action: Action) {
  
        self.delegate.didRenamed(self.highLightName, index: self.fileIndex)
    
        super.onHttpRequest(action)
    }
 
}


protocol RenameDelegate{
    func didRenamed(newName:String,index:Int)
}
