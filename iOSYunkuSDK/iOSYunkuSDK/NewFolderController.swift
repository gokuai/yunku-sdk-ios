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
        
        self.navigationItem.rightBarButtonItem?.title = Bundle.getLocalStringFromBundle("Create", comment: "")
        
        self.navigationItem.title = Bundle.getLocalStringFromBundle("New Folder", comment: "")
        self.textField.placeholder = Bundle.getLocalStringFromBundle("Enter folder name", comment: "")

    }

    override func onFinish(_ sender:AnyObject?){
        self.newFolder()
    }
    
    func newFolder() {
        let folderName = self.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //检验文件是否存在
        for data in self.list{
            if data.dir != FileData.dirs {
                continue
            }else{
                if data.fileName == folderName {
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = Bundle.getLocalStringFromBundle("File has been exit", comment: "")
                    return
                }
            }
        }
        
        DialogUtils.showProgresing(self)
        let appendingString = self.upFullPath.isEmpty ? "":"/"
        FileDataManager.sharedInstance?.addDir("\(self.upFullPath)\(appendingString)\(folderName)", delegate: self)
        self.highLightName = folderName
    }
    
    override func onHttpRequest(_ action: Action) {
     
        self.delegate.didCreateFolder(self.highLightName)
        
        super.onHttpRequest(action)
    }
    

}


protocol NewFolderDelegate{
    func didCreateFolder(_ fileName:String)
}



