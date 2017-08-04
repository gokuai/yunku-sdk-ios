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
            self.navigationItem.title = Bundle.getLocalStringFromBundle("New Note", comment: "")
        }
        
        self.webView = UIWebView(frame: self.clientRect())
        self.webView.delegate = self
        self.edgesForExtendedLayout = UIRectEdge()//for toast
        self.view.addSubview(self.webView)
        
        let editorPath = Bundle.myResourceBundleInstance!.path(forResource: "index", ofType: "html", inDirectory: "ueditor")
        
        var htmlString = ""
        do {
             htmlString =  try String(contentsOfFile: editorPath!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        self.webView.loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: (editorPath?.stringByDeletingLastPathComponent)!))
        
        self.javascriptBridge = WebViewJavascriptBridge(for: self.webView, webViewDelegate: self, handler: {
            [unowned self](data, responseCallback) -> Void in
            
            if let dataObj = data as? String {
                if  dataObj == "ready"{
                    if !self.noteContent.isEmpty{
                        let content = "setContent('\(self.noteContent)');"
                        self.webView.stringByEvaluatingJavaScript(from: content)
                    }
                    self.webView.stringByEvaluatingJavaScript(from: "setFocus();")
                    
                }
                
            }
            }
            , resourceBundle: Bundle.myResourceBundleInstance)

        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Bundle.getLocalStringFromBundle("Save&Upload", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: "onSaveGknote:")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Bundle.getLocalStringFromBundle("Close", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: "onClose:")
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.webView = nil
    }
    
   
    //MARK:保存内容
    func onSaveGknote(_ sender:AnyObject){
        let html = self.webView.stringByEvaluatingJavaScript(from: "UE.getEditor('editor').getContent()")
        
        if !html!.isEmpty{
            if !(Reachability()?.isReachable)!{
                DialogUtils.showNetWorkNotAvailable(self.view)
                return
            }
            
            let sheet =  UIActionSheet(title: Bundle.getLocalStringFromBundle("Please choose operation type", comment: ""),
                delegate: self,
                cancelButtonTitle: Bundle.getLocalStringFromBundle("Cancel", comment: ""),
                destructiveButtonTitle: Bundle.getLocalStringFromBundle("Save&Upload", comment: ""))
            
            sheet.show(in: self.view)
            self.noteContent = html!
        
        }else{
            self.view.makeToast(message: Bundle.getLocalStringFromBundle("Please input content", comment: ""), duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
        }
    
    }
    
    let kTagConfirmTExit = 1
    let kTagSave = 2
    
    //MARK:关闭页面
    func onClose(_ sender:AnyObject){
        let html = self.webView.stringByEvaluatingJavaScript(from: "UE.getEditor('editor').getContent()")
        let contentHasChange = html != self.noteContent
        if contentHasChange {
            
            let alert = UIAlertView(title: Bundle.getLocalStringFromBundle("Tip", comment: ""),
                message: Bundle.getLocalStringFromBundle("Do you want to exit without saving", comment: ""),
                delegate: self,
                cancelButtonTitle: Bundle.getLocalStringFromBundle("Cancel", comment: ""),
                otherButtonTitles:Bundle.getLocalStringFromBundle("OK", comment: ""))
            
            alert.tag = kTagConfirmTExit
            alert.show()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == kTagConfirmTExit{
            if buttonIndex == 1{
                self.dismiss(animated: true, completion: nil)
            }
        
        }

    }
    

    //MARK:命名完成
    func onNoteNamed(_ fileName: String) {
        self.renameFileName = fileName
        self.onSaveText()
    }
    
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            if defaultName.isEmpty{
                let control = NoteNameViewController()
                control.delegate = self
                control.defaultName = Utils.formatGKnoteName(Date().timeIntervalSince1970)
                control.list = self.fileList
                let navC = UINavigationController(rootViewController: control)
                self.present(navC, animated: true, completion: nil)
            }else{
                self.renameFileName = self.defaultName
                self.onSaveText()
            }

        }

    }
    
    //MARK:保存文件
    func onSaveText(){
        DialogUtils.showProgresing(self)

        let gkNoteName = self.renameFileName
        let gkNoteSavePath = Utils.getUploadPath().stringByAppendingPathComponent(path: gkNoteName)
        
        if zipFolderName.isEmpty{
            zipFolderName = gkNoteName.stringByDeletingPathExtension
        }
        
        let zipFolderPath = Utils.getZipCachePath().stringByAppendingPathComponent(path: zipFolderName)
        
        if !FileManager.default.fileExists(atPath: zipFolderPath){
            
            do {
               try  FileManager.default.createDirectory(atPath: zipFolderPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
           
        }
        
        let indexPath = zipFolderPath.stringByAppendingPathComponent(path: "index.html")
        let resourcePath = zipFolderPath.stringByAppendingPathComponent(path: "resource")
        
        let contentData = self.noteContent.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            
            if contentData == nil {
                return
            }
            
            let writeSuccess = (try? contentData!.write(to: URL(fileURLWithPath: indexPath), options: [.atomic])) != nil
            
            if !FileManager.default.fileExists(atPath: resourcePath){
                
                do {
                    try  FileManager.default.createDirectory(atPath: resourcePath, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async(execute: {
                
                DialogUtils.hideProgresing(self)
                
                if writeSuccess {
                    Utils.compressToZipWithZipPath(gkNoteSavePath, sourcePaths: [indexPath,resourcePath], success: {
                        
                    FileUploadManager.sharedInstance?.upload(self.requestPath.stringByAppendingPathComponent(path: gkNoteName),data: LocalFileData(fileName: gkNoteName, localPath: gkNoteSavePath), view: self.view)
                    FileUploadManager.sharedInstance?.delegate = self
                        
                        }, fail: {
                            
                            self.view.makeToast(message: Bundle.getLocalStringFromBundle("Save text failed, please retry", comment: ""), duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
    
                    })
                    
                    
                }else{
                     self.view.makeToast(message: Bundle.getLocalStringFromBundle("Save text failed, please retry", comment: ""), duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
                    
                }

            })
        
        
        })
        
    }
    
    func onFileDidCreate(_ fileName: String) {
        
        self.dismiss(animated: true, completion: {() -> Void in
            self.delegate.onFileDidCreate(fileName)
        
        })

    }

}
 
