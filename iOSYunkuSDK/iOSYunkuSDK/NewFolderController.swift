//
//  NewFolderController.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/1.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit

class NewFolderController: NameController{
    
    var delegate:NewFolderDelegate!
    var upFullPath = ""//上层文件夹的路径

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.title = NSBundle.getLocalStringFromBundle("Create", comment: "")
        
        self.navigationItem.title = NSBundle.getLocalStringFromBundle("New Folder", comment: "")
        self.textField.placeholder = NSBundle.getLocalStringFromBundle("Enter folder name", comment: "")

    }

    override func onFinish(sender:AnyObject?){
        self.newFolder()
    }
    
    func newFolder() {
        var folderName = self.textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //检验文件是否存在
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
        var appendingString = self.upFullPath.isEmpty ? "":"/"
        FileDataManager.sharedInstance?.addDir("\(self.upFullPath)\(appendingString)\(folderName)", delegate: self)
        self.highLightName = folderName
    }
    
    override func onHttpRequest(action: Action) {
     
        self.delegate.didCreateFolder(self.highLightName)
        
        super.onHttpRequest(action)
    }
    

}


protocol NewFolderDelegate{
    func didCreateFolder(fileName:String)
}



