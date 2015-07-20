//
//  FileViewController.swift
//  iOSYunkuSDK
//
//  Created by wqc on 15/7/2.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit
import YunkuSwiftSDK
import MediaPlayer

func RGBA(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat=1.0)->UIColor{
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

@objc protocol FileViewControllerDelegate{
    optional func closeFileViewController()
}

class FileViewController:UIViewController,UIWebViewDelegate,UIGestureRecognizerDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate,NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate,FileUploadManagerDelegate {
    
    static let kIconWidth: CGFloat = 64.0
    static let URL_DOC_PREVIEW  = "doc.gokuai.com"
    
    enum FailedType {
        case NotSupport,FailToConvert,NoNet,UNZipErr
    }
    
    enum DOWNLOAD_TYPE{
        case DIRECTLY_ORIGINAL
        case PREVIEW_FILE
        case ORIGINAL_AFTER_PREIVEW
    }
    
    
    //MARK: life cycle
    init(fullpath: String, filename: String, dir: Int, filehash: String?, localpath: String?, filesize: UInt64?){
        self.fileFullPath = fullpath
        self.fileDir = dir
        if let path = localpath {
            self.fileLocalPath = localpath
        }
        self.fileName = filename
        if let len = filesize {
            self.fileSize = len
        }
        if let hash = filehash {
            self.fileHash  = hash
        }
        self.localFilePath = Utils.getFileCachePath().stringByAppendingPathComponent("\(self.fileHash!).\(self.fileName!.pathExtension)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.title = self.fileName
        
        self.navigationItem.rightBarButtonItem = self.moreBarBtn
        
        
        var newBackButton = UIBarButtonItem(title: NSBundle.getLocalStringFromBundle("Back", comment: ""),
            style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = newBackButton
        self.actBtns.append(self.btnDetail)
        
        self.view.addSubview(self.webView)
        self.view.addSubview(self.loadingPad)
        self.view.addSubview(self.toolBar)
        self.toolBar.hidden = true
        
        if self.fileName.pathExtension.isEmpty {
            self.showFailedInfo(FailedType.NotSupport)
            return
        }
        
        self.needConvert = !Utils.isPreviewType(self.fileName)
        
        if needConvert{
            localFilePath = Utils.getFileCachePath().stringByAppendingPathComponent("\(fileHash!)_preview.pdf");
        }

        if NSFileManager.defaultManager().fileExistsAtPath(localFilePath!) {
            self.webView.hidden = false
            self.loadingPad.hidden = true
            self.toolBar.hidden = false
            
            self.openFileWithPath(localFilePath!)
            
        } else {
            self.webView.hidden = true
            self.loadingPad.hidden = false
            self.progressView.hidden = false
            
            if self.needConvert {
                self.fetchPreviewURL()
            } else {
                self.fetchDownloadURL()
            }
        }
        
    }
    
    override func shouldAutorotate() -> Bool {
        if Utils.isVideoType(self.fileName){
            return true
        }
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return  Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        var invalidRect = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-self.toolBar.frame.height)
        self.moviePlayerController?.view.frame = invalidRect
    }
    
    
    deinit{
        println("fileviewcontroller deinit")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    //MARK: event handle
    func onClose() {
        
        self.moviePlayerController?.stop()
        
        self.session?.invalidateAndCancel()
        self.session = nil
        
        self.socketio?.close(fast: true)
        self.socketio = nil
    }
    
    
    func onMore(sender: AnyObject) {
        let point = CGPointMake(self.clientRect().width - 20, self.navigationController!.navigationBar.frame.origin.y+self.navigationController!.navigationBar.frame.size.height+5);
        let pop = PopoverView(point: point, btns: self.actBtns)
        pop.show()
    }
    
    func onBtnDetail(btn: UIButton) {
        if let v = btn.superview as? PopoverView{
            v.dismiss(false)
        }
        
        if let info = self.fileInfoData{
            self.showDetailInfo(info)
        } else {
            dispatch_async(dispatch_get_main_queue()){
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if result != nil {
                    self.fileInfoData = result
                    self.showDetailInfo(self.fileInfoData!)
                }
            }
        }
    }
    
    func onBtnEdit(btn: UIButton){
        if let v = btn.superview as? PopoverView{
            v.dismiss(false)
        }
        
        if self.fileName.pathExtension.lowercaseString == "gknote"{
            let controller = GKnoteViewController()
            controller.noteContent = self.gknoteContent!
            controller.defaultName = self.fileName
            controller.requestPath = self.fileFullPath.stringByDeletingLastPathComponent
            controller.zipFolderName = Utils.getFileNameWithoutExt(self.fileName)
            controller.delegate = self
            var gknoteNc = UINavigationController(rootViewController: controller)
            self.presentViewController(gknoteNc, animated: true, completion: nil)
        }
    }
    
    func onBtnPrint(btn: UIButton){
        if let v = btn.superview as? PopoverView{
            v.dismiss(false)
        }
        
        let p = UIPrintInteractionController.sharedPrintController()
        
        if let printInteraction = p {
            // width 和height 按自己定义即可，比如说A4大小
            let pdfWidth: Float = 595.0
            let pdfHeight: Float = 842.0
            
            let myRenderer = MyPrintPageRender()
            let viewFormatter: UIViewPrintFormatter = self.webView.viewPrintFormatter()
            myRenderer.addPrintFormatter(viewFormatter, startingAtPageAtIndex: 0)
            
            let pdfData = myRenderer.convertUIWebViewToPDFsaveWidth(pdfWidth, saveHeight: pdfHeight)
            
            //      [pdfData writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"textpdf.pdf"] atomically:YES];
            if UIPrintInteractionController.canPrintData(pdfData) { // Check first
    
                var printInfo = UIPrintInfo.printInfo()
                
                printInfo.duplex = UIPrintInfoDuplex.LongEdge
                printInfo.outputType = UIPrintInfoOutputType.General
                printInfo.jobName = self.fileName
                
                printInteraction.printInfo = printInfo
                printInteraction.printingItem = pdfData
                printInteraction.showsPageRange = true
                
                printInteraction.presentAnimated(true, completionHandler: { (pic, completed, err) -> Void in
                    
                })
                
            }
        }
        
    }
    
    func onAction(){
        self.localFilePath = Utils.getFileCachePath().stringByAppendingPathComponent("\(self.fileHash!).\(self.fileName!.pathExtension)")
        if !NSFileManager.defaultManager().fileExistsAtPath(self.localFilePath!){
            self.needAction = true
            if self.failToPreview{
                self.infoLabel.text = NSBundle.getLocalStringFromBundle("Downloading...", comment: "")
                self.infoLabel.textColor = RGBA(100, 100, 100)
                self.fetchDownloadURL()
            } else {
                if self.needConvert{
                    self.startDownloadingAct()
                } else {
                    self.startDownloading()
                }
            }
        } else {
            self.openActMenu()
        }
    }
    
    func gesAction(recognize:UITapGestureRecognizer){
        
    }
    

    //MARK: custom method
    func showFailedInfo(type: FailedType){
        var info: String!
        switch type {
        case .NotSupport:
            info = NSBundle.getLocalStringFromBundle("Unsupport to preview", comment: "")
        case .FailToConvert:
            info = NSBundle.getLocalStringFromBundle("Convert error", comment: "")
        case .NoNet:
            info = NSBundle.getLocalStringFromBundle("Network error", comment: "")
        case .UNZipErr:
            info = NSBundle.getLocalStringFromBundle("Unzip error", comment: "")
        }
        self.progressView.hidden = true
        self.loadingPad.hidden = false
        self.infoLabel.text = info
        self.infoLabel.textColor = UIColor.redColor()
        self.toolBar.hidden = false
        self.failToPreview = true
        self.isLoading = false
    }
    
    func openFileWithPath(localPath: String) ->Bool{
        if isDetailShowing {
            self.maskTap()
        }
        
        self.loadingPad.hidden = true
        
        if Utils.isImageType(localPath){
            var htmlStr: String = "<div style=\"width:100%; height:100%; position:absolute; left:0; top:0; text-align:center; font-size:0;\"><span style=\"vertical-align:middle; display:inline-block; height:100%;\"></span><img src=\"\(localPath)\" style=\"width:980px;vertical-align:middle;\"  /></div>"
            self.webView.opaque = false
            self.webView.backgroundColor = UIColor.blackColor()
            self.webView.hidden = false
            self.webView.loadHTMLString(htmlStr, baseURL: NSURL(fileURLWithPath: Utils.getFileCachePath()))
        } else {
            
            if Utils.isVideoType(localPath){
                self.webView.hidden = true
                
                if !localPath.isEmpty && NSFileManager.defaultManager().fileExistsAtPath(localPath){
                    dispatch_async(dispatch_get_main_queue()){[weak self] in
                        self?.playMovieFile(NSURL(fileURLWithPath: localPath)!)
                    }
                }
            } else if Utils.isAudioType(localPath){
                self.webView.hidden = true
                
                if !localPath.isEmpty && NSFileManager.defaultManager().fileExistsAtPath(localPath){
                    dispatch_async(dispatch_get_main_queue()){[weak self] in
                        self?.playMovieFile(NSURL(fileURLWithPath: localPath)!)
                    }
                }
                
            } else if localPath.pathExtension.lowercaseString == "txt"{
                if fileSize > 1*1024*1024{
                    self.webView.hidden = true
                    self.loadingPad.hidden = false
                    self.infoLabel.text = NSBundle.getLocalStringFromBundle("The size of this file is too larage to preview", comment: "")
                    self.infoLabel.textColor = UIColor.redColor()
                    self.progressView.hidden = true
                } else {
                    self.webView.hidden = false
                    self.viewTxtFile(localPath)
                }
                
            } else if localPath.pathExtension.lowercaseString == "gknote"{
                self.showGknoteContent()
            } else {
                let url = NSURL(fileURLWithPath: localPath)
                self.webView.hidden = false
                self.webView.loadRequest(NSURLRequest(URL: url!))
            }
            
        }
        
        return true
    }
    
    func showGknoteContent(){
        self.webView.hidden = false
        let zipPath: String = Utils.getZipCachePath().stringByAppendingPathComponent(self.fileName)
        if NSFileManager.defaultManager().fileExistsAtPath(zipPath){
            NSFileManager.defaultManager().removeItemAtPath(zipPath, error: nil)
        }
        if NSFileManager.defaultManager().copyItemAtPath(self.localFilePath!, toPath: zipPath, error: nil){
            let dirname = Utils.getFileNameWithoutExt(self.fileName)
            let zipfolder = Utils.getZipCachePath().stringByAppendingPathComponent(dirname)
            NSFileManager.defaultManager().createDirectoryAtPath(zipfolder, withIntermediateDirectories: false, attributes: nil, error: nil)
            Utils.unZipWithSource(zipPath, targetFileName: dirname, success: { () -> Void in
                let indexPath = zipfolder.stringByAppendingPathComponent("index.html")
                self.gknoteContent = String(contentsOfFile: indexPath, encoding: NSUTF8StringEncoding, error: nil)
                let viewerPath = NSBundle.myResourceBundleInstance?.pathForResource("viewer", ofType: "html", inDirectory: "ueditor")
                let viewString = String(contentsOfFile: viewerPath!, encoding: NSUTF8StringEncoding, error: nil)
                
                self.webView.loadHTMLString(Utils.replaceStrBySearchStr(viewString!, search: "${content}", replace: self.gknoteContent!), baseURL: NSURL(fileURLWithPath: zipfolder))
                
                }, fail: { () -> Void in
                    self.showFailedInfo(FailedType.UNZipErr)
            })
        } else {
            self.showFailedInfo(FailedType.UNZipErr)
        }
    }
    
    func viewTxtFile(path: String){
        var usedEncoding: NSStringEncoding = 0
        var body = NSString(contentsOfFile: path, usedEncoding: &usedEncoding, error: nil)
        if body == nil {
            usedEncoding = 0x80000632
            body = NSString(contentsOfFile: path, usedEncoding: &usedEncoding, error: nil)
        }
        if body == nil {
            usedEncoding = 0x80000631
            body = NSString(contentsOfFile: path, usedEncoding: &usedEncoding, error: nil)
        }
        
        if body != nil {
            let tx =  Utils.replaceStrBySearchStr(String(body!), search: "\n", replace: "<br />")
            self.webView.loadHTMLString("<font size=50>\(tx)</font>", baseURL: nil)
        } else {
            let url = NSURL(fileURLWithPath: path)
            self.webView.loadRequest( NSURLRequest(URL: url!))
        }
    }
    
    
    func fetchPreviewURL(){
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
            if let url = result?.uri {
                dispatch_sync(dispatch_get_main_queue()){
                    self.fileInfoData = result
                    self.convertURL = url
                    self.progressView.setProgress(0.05, animated: true)
                }
                if !url.isEmpty {
                    self.connectSocketIO()
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.showFailedInfo(FailedType.FailToConvert)
                }
            }
            
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), block)
        
    }
    
    func fetchDownloadURL(){
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
            if let url = result?.uri {
                dispatch_async(dispatch_get_main_queue()){
                    self.fileInfoData = result
                    self.downloadURL = url
                    if !url.isEmpty{
                        self.webView.hidden = true
                        self.loadingPad.hidden = false
                        self.progressView.hidden = false
                        self.progressView.setProgress(0.2, animated: true)
                        self.nowDownloadType = DOWNLOAD_TYPE.DIRECTLY_ORIGINAL
                        self.startDownloading()
                    }
                };
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.showFailedInfo(FailedType.NoNet)
                }
            }
        };
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), block)
        
    }
    
    func openActMenu(){
        var newLocalPath = Utils.replaceStrBySearchStr(self.localFilePath!, search: self.localFilePath!.lastPathComponent, replace: self.fileName)
        if NSFileManager.defaultManager().fileExistsAtPath(newLocalPath){
            self.docController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: newLocalPath)!)
            self.isCopyFile = true
        } else {
            if NSFileManager.defaultManager().copyItemAtPath(localFilePath!, toPath: newLocalPath, error: nil){
                self.docController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: newLocalPath)!)
                self.isCopyFile = true
            } else {
                self.docController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: self.localFilePath!)!)
                self.isCopyFile = false
            }
        }
        
        self.docController?.delegate = self
        self.docController?.UTI = Utils.getDocumentUTIType(self.fileName.pathExtension)
        self.docController?.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
        
    }
    
    func connectSocketIO(){
        var arr: [String : String?] = ["url":self.convertURL,"filehash":self.fileHash,"ext":self.fileFullPath.pathExtension]
    
        let sign: String = SignAbility.generateSign(arr, clientSecret: "6c01aefe6ff8f26b51139bf8f808dad582a7a864", encode: false)
        
        let socketurl = "doc.gokuai.com:5030"
        
        var param = ["url":self.convertURL!,"filehash":self.fileHash!,"ext":self.fileName.pathExtension,"sign":sign]
        
        if self.socketio == nil {
            self.socketio = SocketIOClient(socketURL: socketurl, options: ["connectParams":param])
        }
        
        self.socketio!.on("progress"){[weak self] data, ack in
            var previewErr = false
            if let ret = data?[0] as? NSDictionary {
                if let pro = ret.valueForKey("progress") as? Float {
                    if NSThread.isMainThread(){
                        self?.progressView.setProgress(0.05+(pro/100.00)*0.15, animated: true)
                    } else {
                        dispatch_sync(dispatch_get_main_queue()){
                            self?.progressView.setProgress(0.05+(pro/100.00)*0.15, animated: true)
                        }
                    }
                    
                    if pro >= 100.0{
                        if let downloadurl = ret.valueForKey("url") as? String {
                            self?.socketio?.close(fast: true)
                            self?.socketio = nil
                            self?.downloadURL = downloadurl
                            self?.nowDownloadType = DOWNLOAD_TYPE.PREVIEW_FILE
                            dispatch_async(dispatch_get_main_queue()){
                                self?.webView.hidden = true
                                self?.loadingPad.hidden = false
                                self?.progressView.hidden = false
                                self?.startDownloading()
                            }
                            previewErr = false
                            return
                        } else {
                            previewErr = true
                        }
                    }
                } else {
                    previewErr = true
                }
            } else {
                previewErr = true
            }
            
            
            if previewErr {
                self?.socketio?.close(fast: true)
                self?.socketio = nil
                self?.showFailedInfo(FailedType.FailToConvert)
            }
            
        }
        
        self.socketio!.on("err"){[weak self] data, ack in
            var notSupport = false
            if let ret = data?[0] as? NSDictionary {
                if let code = ret.valueForKey("error_code") as? Int {
                    if code == 403{
                        notSupport = true
                    }
                }
            }
            self?.socketio?.close(fast: true)
            self?.socketio = nil
            self?.showFailedInfo(notSupport ? FailedType.NotSupport : FailedType.FailToConvert )
        }
        
        
        self.socketio?.connect()
    }
    
    func startDownloading(){
        println("start download the original file")
        
        if let url = self.downloadURL {
            self.recieveBytes = 0
            self.isLoading = true
            
            if self.session == nil {
                let sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.fileviewcontrollersession.yunkusdk")
                sessionConfig.discretionary = true
                self.session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
            }
            
            var req = NSMutableURLRequest(URL: NSURL(string: self.downloadURL!)!)
            req.HTTPMethod = "GET"
            req.HTTPShouldHandleCookies = false
            req.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
            req.addValue("client-gokuai", forHTTPHeaderField: "User-Agent")
            
            var downTask = self.session?.downloadTaskWithRequest(req)
            downTask?.resume()
        }
    }
    
    func startDownloadingAct(){
        
        self.recieveBytes = 0
        self.nowDownloadType = DOWNLOAD_TYPE.ORIGINAL_AFTER_PREIVEW
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
            if let url = result?.uri {
                dispatch_async(dispatch_get_main_queue()){
                    self.downloadURL = url
                    if !url.isEmpty{
                        //self.alertViewWithProgressbar = AGAlertViewWithProgressbar(title: nil, message: NSBundle.getLocalStringFromBundle("正在加载...", comment: ""), delegate: self, cancelButtonTitle: NSBundle.getLocalStringFromBundle("取消", comment: ""))
                        
                        self.alertViewWithProgressbar = AGAlertViewWithProgressbar(title: nil, message: NSBundle.getLocalStringFromBundle("Loading", comment: ""), andDelegate: self)
                        self.alertViewWithProgressbar?.cancelButtonTitle = NSBundle.getLocalStringFromBundle("Cancel", comment: "")
                        
                        self.alertViewWithProgressbar?.show()
                        
                        self.startDownloading()
                    }
                };
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.showFailedInfo(FailedType.NoNet)
                }
            }
        }
    }
    
    
    //MARK: movie player
    func playMovieFile(movieFileURL: NSURL){
        self.createAndPlayMovieForURL(movieFileURL, sourceType: MPMovieSourceType.File)
    }
    
    private func createAndPlayMovieForURL(movieURL: NSURL,sourceType: MPMovieSourceType){
        let player = MPMoviePlayerController(contentURL: movieURL)
        if player != nil{
            self.moviePlayerController = player
            
            self.installMovieNotificationObservers()
            
            player.contentURL = movieURL
            player.movieSourceType = sourceType  //在播放前设置source type会使加载过程更快
            
            self.applyUserSettingToMoviePlayer()
            
            var invalidRect = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-self.toolBar.frame.height)
            
            player.view.frame = invalidRect
            
            self.view.addSubview(player.view)
            
            player.play()
        }
    }
    
    private func installMovieNotificationObservers(){
        if let player = self.moviePlayerController{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: player)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayBackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaIsPreparedToPlayDidChange:", name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: player)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayBackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: player)
            
        }
    }
    
    private func uninstallMovieNotificationObservers(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerLoadStateDidChangeNotification, object: self.moviePlayerController)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayerController)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: self.moviePlayerController)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackStateDidChangeNotification, object: self.moviePlayerController)
    }
    
    private func applyUserSettingToMoviePlayer(){
        if let player = self.moviePlayerController{
            player.scalingMode = MPMovieScalingMode.AspectFit
            player.controlStyle = MPMovieControlStyle.Embedded
            player.repeatMode = MPMovieRepeatMode.None
            player.backgroundView.backgroundColor = RGBA(30, 35, 40)
            player.allowsAirPlay = true
        }
    }
    
    private func removeMoviePlayer(){
        if let player = self.moviePlayerController{
            player.view.removeFromSuperview()
            self.uninstallMovieNotificationObservers()
        }
    }
    
    func showDetailInfo(data: FileData){
        self.isDetailShowing = true
        let timeC = "\(Utils.formatFileTime(NSTimeInterval(data.createTime)))"
        let strCreate = "\(data.createName) 创建于 \(timeC))"
        let timeM =  "\(Utils.formatFileTime(NSTimeInterval(data.lastDateline)))"
        let strModify = "\(data.lastMemberName) 最后修改于 \(timeM)"
        
        let strSize = "大小: \(data.fileSize!)"
        let strLocation="位置: \(data.fullPath)"
        
        let win = UIApplication.sharedApplication().keyWindow
        
        maskV = UIControl(frame: UIScreen.mainScreen().bounds)
        maskV.backgroundColor = UIColor.blackColor()
        maskV.alpha = 0.3
        maskV.addTarget(self, action: "maskTap", forControlEvents: UIControlEvents.TouchDown)
        
        win?.addSubview(maskV)
        
        let rc = self.view.convertRect(self.view.bounds, toView: win)

        detailPad = UIView(frame: CGRectMake(0, rc.origin.y, self.view.frame.width, 270))
        //detailPad = UIView(frame: CGRectMake((self.view.frame.size.width-280)/2, 130, 280, 270))
        detailPad!.backgroundColor = UIColor.whiteColor()
        win?.addSubview(detailPad!)

        let imgvFolderV = UIImageView(frame: CGRectMake((detailPad!.frame.size.width-88)/2, 20, 90, 90))
        imgvFolderV.image = UIImage.imageNameFromMyBundle(Utils.getImageIcon(data.fileName, dir: data.dir))
        detailPad!.addSubview(imgvFolderV)
        
        let filenamel = UILabel(frame: CGRectMake(0, imgvFolderV.frame.origin.y+imgvFolderV.frame.size.height+15, detailPad!.frame.size.width, 20))
        filenamel.text = data.fileName
        filenamel.backgroundColor = UIColor.clearColor()
        filenamel.font = UIFont.systemFontOfSize(16)
        filenamel.textColor = UIColor.blackColor()
        filenamel.textAlignment = NSTextAlignment.Center
        detailPad!.addSubview(filenamel)
        
        let timecl = UILabel(frame: CGRectMake(0, filenamel.frame.origin.y+filenamel.frame.size.height+5, detailPad!.frame.size.width, 20))
        timecl.text = strCreate
        timecl.backgroundColor = UIColor.clearColor()
        timecl.font = UIFont.systemFontOfSize(13)
        timecl.textColor = UIColor.grayColor()
        timecl.textAlignment = NSTextAlignment.Center
        detailPad!.addSubview(timecl)
        let timeml = UILabel(frame: CGRectMake(0, timecl.frame.origin.y+timecl.frame.size.height+5, detailPad!.frame.size.width, 20))
        timeml.text = strModify;
        timeml.backgroundColor = UIColor.clearColor()
        timeml.font = UIFont.systemFontOfSize(13)
        timeml.textColor = UIColor.grayColor()
        timeml.textAlignment = NSTextAlignment.Center
        detailPad!.addSubview(timeml)
        let sizel = UILabel(frame: CGRectMake(0, timeml.frame.origin.y+timeml.frame.size.height+5, detailPad!.frame.size.width, 20))
        sizel.text = strSize;
        sizel.backgroundColor = UIColor.clearColor()
        sizel.font = UIFont.systemFontOfSize(13)
        sizel.textColor = UIColor.grayColor()
        sizel.textAlignment = NSTextAlignment.Center
        detailPad!.addSubview(sizel)
        let locl = UILabel(frame: CGRectMake(0, sizel.frame.origin.y+sizel.frame.size.height+5, detailPad!.frame.size.width, 20))
        locl.text = strLocation
        locl.backgroundColor = UIColor.clearColor()
        locl.font = UIFont.systemFontOfSize(13)
        locl.textColor = UIColor.grayColor()
        locl.textAlignment = NSTextAlignment.Center
        detailPad!.addSubview(locl)
    }
    
    func maskTap(){
        maskV.removeFromSuperview()
        detailPad!.removeFromSuperview()
        isDetailShowing = false
    }
    
    //MARK: Movie Notification Handlers
    func moviePlayBackDidFinish(notification: NSNotification){
        if let dic = notification.userInfo{
            var reason: NSNumber? = dic[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? NSNumber
            if reason != nil{
                if reason!.integerValue == 0 {
                    //MPMovieFinishReason.PlaybackEnded
                    
                } else if reason!.integerValue == 1{
                    //MPMovieFinishReason.PlaybackError
                    self.removeMoviePlayer()
                } else if reason!.integerValue == 2{
                    //MPMovieFinishReason.UserExited
                    self.removeMoviePlayer()
                }
            }
        }
    }
    
    func loadStateDidChange(notification: NSNotification){
        let player: MPMoviePlayerController? = notification.object as? MPMoviePlayerController
        let loadState = player?.loadState
    }
    
    func moviePlayBackStateDidChange(notification: NSNotification){
        let player: MPMoviePlayerController? = notification.object as? MPMoviePlayerController
        if player != nil {
            let playState = player!.playbackState
        }
        
    }
    
    func mediaIsPreparedToPlayDidChange(notification: NSNotification){
        
    }

    
    //MARK: delegate
    
    //MARK: UIWebView Delegate
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        if self.fileName.pathExtension.lowercaseString == "gknote"{
            self.actBtns.append(self.btnEdit)
        }
        
        if Utils.isPrintType(self.fileName){
            self.actBtns.append(self.btnPrint)
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.alertViewWithProgressbar?.hide()
        self.alertViewWithProgressbar = nil
        
        self.isLoading = false
        self.downloadURL = nil
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionController(controller: UIDocumentInteractionController, willBeginSendingToApplication application: String) {
        
    }
    
    func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String) {
        
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(controller: UIDocumentInteractionController) {
        if self.isCopyFile{
            NSFileManager.defaultManager().removeItemAtURL(controller.URL, error: nil)
        }
    }
    
    //MARK: NSURLSessionDelegate
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
    }
    
    //MARK: NSURLSessionTaskDelegate
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        completionHandler(request)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        UIApplication.sharedApplication().idleTimerDisabled = false
        self.isLoading = false
        self.toolBar.hidden = false
        
        self.alertViewWithProgressbar?.hide()
        
        if error != nil {
            self.showFailedInfo(FailedType.NoNet)
        } else {
            if !NSFileManager.defaultManager().fileExistsAtPath(self.localFilePath!){
                self.showFailedInfo(FailedType.NoNet)
            } else {
                self.loadingPad.hidden = true
                
                if !self.needAction{
                    self.openFileWithPath(self.localFilePath!)
                } else {
                    self.openActMenu()
                }
            }
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
    }
    
    //MARK: NSURLSessionDownloadDelegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let destPos = NSURL(fileURLWithPath: self.localFilePath!)
        var err: NSError? = nil
        NSFileManager.defaultManager().copyItemAtURL(location, toURL: destPos!, error: &err)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        self.recieveBytes = totalBytesWritten
        
        if self.nowDownloadType == DOWNLOAD_TYPE.ORIGINAL_AFTER_PREIVEW{
            var p: Float = Float(totalBytesWritten)*1.0/Float(fileSize)*1.0
            self.alertViewWithProgressbar?.progress = UInt(p * 100)
            if (p >= 1.000000) {
                self.alertViewWithProgressbar?.hide()
            }
            
        } else {
            var p: Float = 0
            if self.nowDownloadType == DOWNLOAD_TYPE.PREVIEW_FILE{
                self.infoLabel.text = "\(Utils.formatSize(UInt64(recieveBytes))), 共\(Utils.formatSize(UInt64(totalBytesExpectedToWrite)))"
                
                p = 0.2+(Float(totalBytesWritten)*1.0/Float(totalBytesExpectedToWrite)*1.0)*0.8
            } else {
                p = 0.2+(Float(totalBytesWritten)*1.0/Float(fileSize)*1.0)*0.8
            }
            self.progressView.setProgress(p, animated: true)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func onFileDidCreate(fileName: String) {
        DialogUtils.showProgresing(self)
        self.uploadDelegate.onFileDidCreate(fileName)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    //MARK: property
    lazy var webView:UIWebView = {
        let rc = self.view.bounds
       let webv = UIWebView(frame: CGRectMake(0, 0, rc.width, rc.height))
        webv.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        webv.hidden = true
        webv.delegate = self
        webv.scalesPageToFit = true
        webv.backgroundColor = UIColor.whiteColor()
        //let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"gesAction" )
        //singleTap.delegate = self
        //webv.addGestureRecognizer(singleTap)
        return webv
    }()

    
    
    lazy var moreBarBtn:UIBarButtonItem = {
        return UIBarButtonItem(title: NSBundle.getLocalStringFromBundle("More", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: "onMore:")
    }()
    
    lazy var toolBar:UIToolbar = {
        let rc = self.view.bounds
       var bar = UIToolbar(frame: CGRectMake(0, rc.height-44.0, rc.width, 44.0))
        bar.barStyle = UIBarStyle.Default
        bar.translucent = false
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let actbtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "onAction")
        bar.items = [space,actbtn,space]
        bar.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin;
        return bar
    }()
    
    lazy var actBtns: [UIButton] = {
        return [UIButton]()
    }()
    
    var fileFullPath: String!
    var fileDir: Int! = 0
    var fileLocalPath: String? = ""
    var fileName: String! = ""
    var fileSize: UInt64 = 0
    var fileHash: String? = ""
    
    var localFilePath: String? = ""
    
    
    lazy var loadingPad: UIView = {
        let rc: CGRect = self.view.bounds
        let v = UIView(frame: CGRectMake(0, (CGRectGetHeight(rc)-150)/2-40, CGRectGetWidth(rc), 150))
        v.backgroundColor = UIColor.clearColor()
        v.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let imgv: UIImageView = UIImageView(frame: CGRectMake((CGRectGetWidth(rc)-kIconWidth)/2, 0, kIconWidth, kIconWidth))
        imgv.image = UIImage.imageNameFromMyBundle(Utils.getImageIcon(self.fileName, dir: self.fileDir))
        self.iconView = imgv
        v.addSubview(imgv)
        
        let infoText: UILabel = UILabel(frame: CGRectMake(10.0, CGRectGetMaxY(imgv.frame)+6.0, rc.size.width-20.0, 20.0))
        infoText.font = UIFont.systemFontOfSize(12.0)
        infoText.textColor = RGBA(100, 100, 100)
        infoText.textAlignment = NSTextAlignment.Center
        infoText.text = NSBundle.getLocalStringFromBundle("Beginning to preview", comment:"")
        self.infoLabel = infoText
        v.addSubview(infoText)
        
        let p: UIProgressView = UIProgressView(frame: CGRectMake((CGRectGetWidth(rc)-150)/2, CGRectGetMaxY(infoText.frame)+10, 150.0, 10.0))
        p.progressViewStyle = UIProgressViewStyle.Default
        p.progress = 0.0
        self.progressView=p
        v.addSubview(p)
        
        return v
    }()
    
    var iconView: UIImageView!
    var infoLabel: UILabel!
    var progressView: UIProgressView!
    
    lazy var btnDetail: UIButton = {
       let btn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        btn.frame = CGRectMake(0, 0, 100, 20)
        btn.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        btn.setTitle(NSBundle.getLocalStringFromBundle("Detail", comment: ""), forState: UIControlState.Normal)
        btn.addTarget(self, action: Selector("onBtnDetail:"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    lazy var btnPrint: UIButton = {
        let btn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        btn.frame = CGRectMake(0, 0, 100, 20)
        btn.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        btn.setTitle(NSBundle.getLocalStringFromBundle("Print", comment: ""), forState: UIControlState.Normal)
        btn.addTarget(self, action: Selector("onBtnPrint:"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    lazy var btnEdit: UIButton = {
        let btn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        btn.frame = CGRectMake(0, 0, 100, 20)
        btn.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        btn.setTitle(NSBundle.getLocalStringFromBundle("Edit", comment: ""), forState: UIControlState.Normal)
        btn.addTarget(self, action: Selector("onBtnEdit:"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
        }()
    
    override func viewWillDisappear(animated: Bool) {
        if self.navigationController?.viewControllers.last as? FileViewController != self{
            self.onClose()
        }
        super.viewWillDisappear(animated)
    }

    var needConvert: Bool = false
    
    var convertURL: String?
    var downloadURL: String?
    
    var nowDownloadType: DOWNLOAD_TYPE?
    
    var socketio: SocketIOClient?
    
    var isLoading = false
    var recieveBytes: Int64 = 0
    
    var needAction: Bool = false
    
    var failToPreview: Bool = false;
    
    var alertViewWithProgressbar: AGAlertViewWithProgressbar? = nil
    
    var docController: UIDocumentInteractionController? = nil
    var isCopyFile: Bool = true
    
    var needFresh: Bool = false
    
    weak var delegate: FileViewControllerDelegate! = nil
    
    var session: NSURLSession? = nil
    
    var moviePlayerController: MPMoviePlayerController? = nil
    
    
    var gkZipName: String? = nil
    var gknoteContent: String? = nil
    
    var fileInfoData: FileData? = nil
    var isDetailShowing: Bool = false
    
    var detailPad: UIView? = nil
    var maskV: UIControl! = nil
    var uploadDelegate:FileUploadManagerDelegate!
    
}



