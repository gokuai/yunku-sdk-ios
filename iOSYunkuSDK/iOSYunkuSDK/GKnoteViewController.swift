//
//  GKnoteViewController.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/8.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit


class  GKnoteViewController :UIViewController,UIWebViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,NoteNameDelegate,FileUploadManagerDelegate {
    
    var defaultName = ""
    var renameFileName = ""
    var noteContent = ""
    var zipFolderName = ""
    var requestPath = ""
    var javascriptBridge:WebViewJavascriptBridge!
    var webView:UIWebView!
    var fileList:Array<FileData>!
    var delegate: FileUploadManagerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadContent()
    }
    
    func loadContent(){
        
        if !defaultName.isEmpty{
            self.navigationItem.title = defaultName
        }else{
            self.navigationItem.title = NSBundle.getLocalStringFromBundle("New Note", comment: "")
        }
        
        self.webView = UIWebView(frame: self.clientRect())
        self.webView.delegate = self
        self.edgesForExtendedLayout = .None//for toast
        self.view.addSubview(self.webView)
        
        var editorPath = NSBundle.myResourceBundleInstance!.pathForResource("index", ofType: "html", inDirectory: "ueditor")
        var htmlString = String(contentsOfFile: editorPath!, encoding: NSUTF8StringEncoding, error: nil)
        
        self.webView.loadHTMLString(htmlString, baseURL: NSURL(fileURLWithPath: (editorPath?.stringByDeletingLastPathComponent)!))
        
        self.javascriptBridge = WebViewJavascriptBridge(forWebView: self.webView, webViewDelegate: self, handler: {
            [unowned self](data, responseCallback) -> Void in
            
            if let dataObj = data as? String {
                if  dataObj == "ready"{
                    if !self.noteContent.isEmpty{
                        var content = "setContent('\(self.noteContent)');"
                        self.webView.stringByEvaluatingJavaScriptFromString(content)
                    }
                    self.webView.stringByEvaluatingJavaScriptFromString("setFocus();")
                    
                }
                
            }
            }
            , resourceBundle: NSBundle.myResourceBundleInstance)

        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSBundle.getLocalStringFromBundle("Save&Upload", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: "onSaveGknote:")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSBundle.getLocalStringFromBundle("Close", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: "onClose:")
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.webView = nil
    }
    
   
    //MARK:保存内容
    func onSaveGknote(sender:AnyObject){
        var html = self.webView.stringByEvaluatingJavaScriptFromString("UE.getEditor('editor').getContent()")
        
        if !html!.isEmpty{
            if !Reachability.isConnectedToNetwork(){
                DialogUtils.showNetWorkNotAvailable(self.view)
                return
            }
            
            var sheet =  UIActionSheet(title: NSBundle.getLocalStringFromBundle("Please choose operation type", comment: ""),
                delegate: self,
                cancelButtonTitle: NSBundle.getLocalStringFromBundle("Cancel", comment: ""),
                destructiveButtonTitle: NSBundle.getLocalStringFromBundle("Save&Upload", comment: ""))
            
            sheet.showInView(self.view)
            self.noteContent = html!
        
        }else{
            self.view.makeToast(message: NSBundle.getLocalStringFromBundle("Please input content", comment: ""), duration: HRToastDefaultDuration, position: HRToastPositionTop)
        }
    
    }
    
    let kTagConfirmTExit = 1
    let kTagSave = 2
    
    //MARK:关闭页面
    func onClose(sender:AnyObject){
        var html = self.webView.stringByEvaluatingJavaScriptFromString("UE.getEditor('editor').getContent()")
        var contentHasChange = html != self.noteContent
        if contentHasChange {
            
            var alert = UIAlertView(title: NSBundle.getLocalStringFromBundle("Tip", comment: ""),
                message: NSBundle.getLocalStringFromBundle("Do you want to exit without saving", comment: ""),
                delegate: self,
                cancelButtonTitle: NSBundle.getLocalStringFromBundle("Cancel", comment: ""),
                otherButtonTitles:NSBundle.getLocalStringFromBundle("OK", comment: ""))
            
            alert.tag = kTagConfirmTExit
            alert.show()
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == kTagConfirmTExit{
            if buttonIndex == 1{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        
        }

    }
    

    //MARK:命名完成
    func onNoteNamed(fileName: String) {
        self.renameFileName = fileName
        self.onSaveText()
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            if defaultName.isEmpty{
                var control = NoteNameViewController()
                control.delegate = self
                control.defaultName = Utils.formatGKnoteName(NSDate.new().timeIntervalSince1970)
                control.list = self.fileList
                var navC = UINavigationController(rootViewController: control)
                self.presentViewController(navC, animated: true, completion: nil)
            }else{
                self.renameFileName = self.defaultName
                self.onSaveText()
            }

        }

    }
    
    //MARK:保存文件
    func onSaveText(){
        DialogUtils.showProgresing(self)

        var gkNoteName = self.renameFileName
        var gkNoteSavePath = Utils.getUploadPath().stringByAppendingPathComponent(gkNoteName)
        
        if zipFolderName.isEmpty{
            zipFolderName = gkNoteName.stringByDeletingPathExtension
        }
        
        var zipFolderPath = Utils.getZipCachePath().stringByAppendingPathComponent(zipFolderName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(zipFolderPath){
            NSFileManager.defaultManager().createDirectoryAtPath(zipFolderPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        var indexPath = zipFolderPath.stringByAppendingPathComponent("index.html")
        var resourcePath = zipFolderPath.stringByAppendingPathComponent("resource")
        
        var contentData = self.noteContent.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            if contentData == nil {
                return
            }
            
            var writeSuccess = contentData!.writeToFile(indexPath, atomically: true)
            
            if !NSFileManager.defaultManager().fileExistsAtPath(resourcePath){
                NSFileManager.defaultManager().createDirectoryAtPath(resourcePath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                DialogUtils.hideProgresing(self)
                
                if writeSuccess {
                    Utils.compressToZipWithZipPath(gkNoteSavePath, sourcePaths: [indexPath,resourcePath], success: {
                        
                    FileUploadManager.sharedInstance?.upload(self.requestPath.stringByAppendingPathComponent(gkNoteName),data: LocalFileData(fileName: gkNoteName, localPath: gkNoteSavePath), view: self.view)
                    FileUploadManager.sharedInstance?.delegate = self
                        
                        }, fail: {
                            
                            self.view.makeToast(message: NSBundle.getLocalStringFromBundle("Save text failed, please retry", comment: ""), duration: HRToastDefaultDuration, position: HRToastPositionTop)
    
                    })
                    
                    
                }else{
                     self.view.makeToast(message: NSBundle.getLocalStringFromBundle("Save text failed, please retry", comment: ""), duration: HRToastDefaultDuration, position: HRToastPositionTop)
                    
                }

            })
        
        
        })
        
    }
    
    func onFileDidCreate(fileName: String) {
        
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.delegate.onFileDidCreate(fileName)
        
        })

    }

}
 
