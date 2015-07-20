//
//  NoteNameViewController.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/9.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit


class NoteNameViewController:NameController {
    
    var defaultName = ""
    var delegate:NoteNameDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.title = NSBundle.getLocalStringFromBundle("Save", comment: "")
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        self.navigationItem.title = NSBundle.getLocalStringFromBundle("Name (No extension)", comment: "")
        self.textField.placeholder = NSBundle.getLocalStringFromBundle("Enter gknote name", comment: "")
        self.textField.text = defaultName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func onFinish(sender: AnyObject?) {
        self.name()
    }
    
    func name(){
        var fileName = self.textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if fileName.pathExtension != "gknote"{
            fileName.stringByAppendingPathExtension("gknote")
        }

        for data in self.list{
            if data.dir == FileData.dirs {
                continue
            }else{
                if data.fileName == fileName {
                    self.errorLabel.hidden = false
                    self.errorLabel.text = NSBundle.getLocalStringFromBundle("File has been exit", comment: "")
                    return
                }
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
           self.delegate.onNoteNamed(fileName)
        })
        
        
    }
    
}
protocol NoteNameDelegate{
    func onNoteNamed(fileName:String)

}