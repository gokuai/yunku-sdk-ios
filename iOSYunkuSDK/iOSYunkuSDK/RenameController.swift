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
    
    var originalName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.title = NSBundle.getLocalStringFromBundle("Rename", comment: "")
        
        self.navigationItem.title = NSBundle.getLocalStringFromBundle("Rename", comment: "")
        self.textField.placeholder = NSBundle.getLocalStringFromBundle("Enter new name", comment: "")
 
        self.filePath = self.list[self.fileIndex].fullPath
        self.originalName = self.filePath.lastPathComponent

        self.textField.text = self.originalName
        
    }
    
    override func textFieldValueChanged(sender: AnyObject) {
        var name = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if name == self.originalName{
            self.navigationItem.rightBarButtonItem?.enabled = false
        }else{
            super.textFieldValueChanged(sender)
        }
        
    }
    
    override func textFieldDidBeginEditing(textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        var from = textField.beginningOfDocument
        var to = textField.positionFromPosition(from, offset: count(self.originalName.stringByDeletingPathExtension))
        textField.selectedTextRange = textField .textRangeFromPosition(from, toPosition: to)
    }
    
    
    override func onFinish(sender:AnyObject?){
        self.rename()
    }
    
    //MARK:重命名
    func rename() {
        var fileName = self.textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        for data in self.list{
            if data.fileName == fileName {
                self.errorLabel.hidden = false
                self.errorLabel.text = NSBundle.getLocalStringFromBundle("File has been exit", comment: "")
                return
            }
        }
        
        DialogUtils.showProgresing(self)
        
        FileDataManager.sharedInstance?.rename(filePath, newName: fileName, delegate: self)
        self.highLightName = fileName
    }
    
    override func onHttpRequest(action: Action) {
  
        self.delegate.didRenamed(self.highLightName, index: self.fileIndex)
    
        super.onHttpRequest(action)
    }
 
}


protocol RenameDelegate{
    func didRenamed(newName:String,index:Int)
}
