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
        
        self.navigationItem.rightBarButtonItem?.title = Bundle.getLocalStringFromBundle("Save", comment: "")
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        self.navigationItem.title = Bundle.getLocalStringFromBundle("Name (No extension)", comment: "")
        self.textField.placeholder = Bundle.getLocalStringFromBundle("Enter gknote name", comment: "")
        self.textField.text = defaultName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func onFinish(_ sender: AnyObject?) {
        self.name()
    }
    
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        let from = textField.beginningOfDocument
        let to = textField.position(from: from, offset: self.defaultName.stringByDeletingPathExtension.characters.count)
        textField.selectedTextRange = textField .textRange(from: from, to: to!)
    }
    
    func name(){
        let fileName = self.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if fileName.pathExtension != "gknote"{
            fileName.stringByAppendingPathExtension(ext: "gknote")
        }

        for data in self.list{
            if data.dir == FileData.dirs {
                continue
            }else{
                if data.fileName == fileName {
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = Bundle.getLocalStringFromBundle("File has been exit", comment: "")
                    return
                }
            }
        }
        
        self.dismiss(animated: true, completion: {() -> Void in
           self.delegate.onNoteNamed(fileName)
        })
        
        
    }
    
}
protocol NoteNameDelegate{
    func onNoteNamed(_ fileName:String)

}
