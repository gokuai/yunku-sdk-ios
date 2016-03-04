//
//  NameController.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/1.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit

class NameController: UIViewController , UITextFieldDelegate,RequestDelegate {
    
    var textField:UITextField!
    var errorLabel:UILabel!
    
//    var delegate:NeedHighLightNameDelegate!
    var list:Array<FileData>!
    var highLightName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 202.0/225.0, green: 202.0/225.0, blue: 202.0/225.0, alpha: 1.0)
  
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:  NSBundle.getLocalStringFromBundle("Close", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: "onClose:")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSBundle.getLocalStringFromBundle("Finish", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: "onFinish:")
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        let frame = self.clientRect()
        self.textField = UITextField(frame: CGRectMake(10, 100.0, frame.width - 20, 48))
        self.textField.leftViewMode = UITextFieldViewMode.Always
        self.textField.leftView = UILabel(frame: CGRectMake(0, 0, 10, 25))
        self.textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.textField.autocapitalizationType = UITextAutocapitalizationType.None
        self.textField.becomeFirstResponder()
        self.textField.borderStyle = UITextBorderStyle.RoundedRect
        self.textField.backgroundColor = UIColor.whiteColor()
        self.textField.delegate = self
        self.textField.font = UIFont.systemFontOfSize(14)
        self.textField.addTarget(self, action: "textFieldValueChanged:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.errorLabel = UILabel(frame: CGRectMake(10, 150, frame.width - 20, 32))
        self.errorLabel.font = UIFont.systemFontOfSize(14)
        self.errorLabel.textColor = UIColor.redColor()
        self.edgesForExtendedLayout = .None//for toast
        
        self.view.addSubview(self.textField)
        self.view.addSubview(self.errorLabel)
        
    }
    
    //MARK:文字发生改变
    func textFieldValueChanged(sender:AnyObject){
        let name = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let isContainSepcial = Utils.isContainSepcial(name)
        let isValid = Utils.isVaildName(name)
        
        self.navigationItem.rightBarButtonItem?.enabled = !name.isEmpty && !isContainSepcial && isValid
        
        self.errorLabel.hidden = !isContainSepcial && isValid
        
        if isContainSepcial {
            errorLabel.text = NSBundle.getLocalStringFromBundle("File name contains sepical code", comment: "")
        }
        
        if !isValid{
            errorLabel.text = NSBundle.getLocalStringFromBundle("File name star with \".\" or end with \".\" is invalid ", comment: "")
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.textField = nil
        self.list = nil
    }
    
    
    func onHttpRequest(action: Action) {
        DialogUtils.hideProgresing(self)
//        self.delegate.hightLightName(highLightName)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func onError(errorMsg:String){
        DialogUtils.hideProgresing(self)
        self.view.makeToast(message: errorMsg, duration: HRToastDefaultDuration, position: HRToastPositionTop)
    }
    
    func onHookError(type:HookType){
        DialogUtils.hideProgresing(self)
    }
    
    func onNetUnable(){
        DialogUtils.hideProgresing(self)
        DialogUtils.showNetWorkNotAvailable(self.view)
    }
    
    
    func onClose(sender:AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onFinish(sender:AnyObject?){

    }
    
}

protocol NeedHighLightNameDelegate{
    func hightLightName(fileName:String)
}