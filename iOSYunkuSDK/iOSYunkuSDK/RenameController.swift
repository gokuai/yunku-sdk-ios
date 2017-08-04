//
//  RenameController.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/2.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import Foundation


class RenameController: NameController{
    
    var filePath = ""
    var fileIndex = 0
    var delegate:RenameDelegate!
    
    var originalName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.title = Bundle.getLocalStringFromBundle("Rename", comment: "")
        
        self.navigationItem.title = Bundle.getLocalStringFromBundle("Rename", comment: "")
        self.textField.placeholder = Bundle.getLocalStringFromBundle("Enter new name", comment: "")
 
        self.filePath = self.list[self.fileIndex].fullPath
        self.originalName = self.filePath.lastPathComponent

        self.textField.text = self.originalName
        
    }
    
    override func textFieldValueChanged(_ sender: AnyObject) {
        let name = textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if name == self.originalName{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            super.textFieldValueChanged(sender)
        }
        
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        let from = textField.beginningOfDocument
        let to = textField.position(from: from, offset: self.originalName.stringByDeletingPathExtension.characters.count)
        textField.selectedTextRange = textField .textRange(from: from, to: to!)
    }
    
    
    override func onFinish(_ sender:AnyObject?){
        self.rename()
    }
    
    //MARK:重命名
    func rename() {
        let fileName = self.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        for data in self.list{
            if data.fileName == fileName {
                self.errorLabel.isHidden = false
                self.errorLabel.text = Bundle.getLocalStringFromBundle("File has been exit", comment: "")
                return
            }
        }
        
        DialogUtils.showProgresing(self)
        
        FileDataManager.sharedInstance?.rename(filePath, newName: fileName, delegate: self)
        self.highLightName = fileName
    }
    
    override func onHttpRequest(_ action: Action) {
  
        self.delegate.didRenamed(self.highLightName, index: self.fileIndex)
    
        super.onHttpRequest(action)
    }
    

 
}


protocol RenameDelegate{
    func didRenamed(_ newName:String,index:Int)
}
