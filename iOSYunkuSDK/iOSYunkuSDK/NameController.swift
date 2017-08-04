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
  
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:  Bundle.getLocalStringFromBundle("Close", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: "onClose:")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Bundle.getLocalStringFromBundle("Finish", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: "onFinish:")
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let frame = self.clientRect()
        self.textField = UITextField(frame: CGRect(x: 10, y: 100.0, width: frame.width - 20, height: 48))
        self.textField.leftViewMode = UITextFieldViewMode.always
        self.textField.leftView = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 25))
        self.textField.clearButtonMode = UITextFieldViewMode.whileEditing
        self.textField.autocapitalizationType = UITextAutocapitalizationType.none
        self.textField.becomeFirstResponder()
        self.textField.borderStyle = UITextBorderStyle.roundedRect
        self.textField.backgroundColor = UIColor.white
        self.textField.delegate = self
        self.textField.font = UIFont.systemFont(ofSize: 14)
        self.textField.addTarget(self, action: #selector(NameController.textFieldValueChanged(_:)), for: UIControlEvents.editingChanged)
        
        self.errorLabel = UILabel(frame: CGRect(x: 10, y: 150, width: frame.width - 20, height: 32))
        self.errorLabel.font = UIFont.systemFont(ofSize: 14)
        self.errorLabel.textColor = UIColor.red
        self.edgesForExtendedLayout = UIRectEdge()//for toast
        
        self.view.addSubview(self.textField)
        self.view.addSubview(self.errorLabel)
        
    }
    
    //MARK:文字发生改变
    func textFieldValueChanged(_ sender:AnyObject){
        let name = textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let isContainSepcial = Utils.isContainSepcial(name)
        let isValid = Utils.isVaildName(name)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = !name.isEmpty && !isContainSepcial && isValid
        
        self.errorLabel.isHidden = !isContainSepcial && isValid
        
        if isContainSepcial {
            errorLabel.text = Bundle.getLocalStringFromBundle("File name contains sepical code", comment: "")
        }
        
        if !isValid{
            errorLabel.text = Bundle.getLocalStringFromBundle("File name star with \".\" or end with \".\" is invalid ", comment: "")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.textField = nil
        self.list = nil
    }
    
    func onHttpRequest(_ action: Action) {
        DialogUtils.hideProgresing(self)
        //        self.delegate.hightLightName(highLightName)
        self.dismiss(animated: true, completion: nil)
    }
    
    func onError(_ errorMsg:String){
        DialogUtils.hideProgresing(self)
        self.view.makeToast(message: errorMsg, duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
    }
    
    func onHookError(_ type:HookType){
        DialogUtils.hideProgresing(self)
    }
    
    func onNetUnable(){
        DialogUtils.hideProgresing(self)
        DialogUtils.showNetWorkNotAvailable(self.view)
    }
    
    
    func onClose(_ sender:AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    func onFinish(_ sender:AnyObject?){

    }
    
}

protocol NeedHighLightNameDelegate{
    func hightLightName(_ fileName:String)
}
