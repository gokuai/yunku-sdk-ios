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

func RGBA(_ r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat=1.0)->UIColor{
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

@objc protocol FileViewControllerDelegate{
    @objc optional func closeFileViewController()
}

class FileViewController:UIViewController,UIWebViewDelegate,UIGestureRecognizerDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate,URLSessionDelegate,URLSessionDataDelegate,URLSessionDownloadDelegate,FileUploadManagerDelegate {
    
    static let kIconWidth: CGFloat = 64.0
    static let URL_DOC_PREVIEW  = "doc.gokuai.com"
    
    enum FailedType {
        case notSupport,failToConvert,noNet,unZipErr
    }
    
    enum DOWNLOAD_TYPE{
        case directly_ORIGINAL
        case preview_FILE
        case original_AFTER_PREIVEW
    }
    
    
    //MARK: life cycle
    init(fullpath: String, filename: String, dir: Int, filehash: String?, localpath: String?, filesize: UInt64?){
        self.fileFullPath = fullpath
        self.fileDir = dir
        if let _ = localpath {
            self.fileLocalPath = localpath
        }
        self.fileName = filename
        if let len = filesize {
            self.fileSize = len
        }
        if let hash = filehash {
            self.fileHash  = hash
        }
        self.localFilePath = Utils.getFileCachePath().stringByAppendingPathComponent(path: "\(self.fileHash!).\(self.fileName!.pathExtension)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
        self.edgesForExtendedLayout = UIRectEdge()
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = self.fileName
        
        self.navigationItem.rightBarButtonItem = self.moreBarBtn
        
        
        let newBackButton = UIBarButtonItem(title: Bundle.getLocalStringFromBundle("Back", comment: ""),
            style: UIBarButtonItemStyle.plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = newBackButton
        self.actBtns.append(self.btnDetail)
        
        self.view.addSubview(self.webView)
        self.view.addSubview(self.loadingPad)
        self.view.addSubview(self.toolBar)
        self.toolBar.isHidden = true
        
        if self.fileName.pathExtension.isEmpty {
            self.showFailedInfo(FailedType.notSupport)
            return
        }
        
        self.needConvert = !Utils.isPreviewType(self.fileName)
        
        if needConvert{
            localFilePath = Utils.getFileCachePath().stringByAppendingPathComponent(path: "\(fileHash!)_preview.pdf");
        }

        if FileManager.default.fileExists(atPath: localFilePath!) {
            self.webView.isHidden = false
            self.loadingPad.isHidden = true
            self.toolBar.isHidden = false
            
            self.openFileWithPath(localFilePath!)
            
        } else {
            self.webView.isHidden = true
            self.loadingPad.isHidden = false
            self.progressView.isHidden = false
            
            if self.needConvert {
                self.fetchPreviewURL()
            } else {
                self.fetchDownloadURL()
            }
        }
        
    }
    
    override var shouldAutorotate : Bool {
        if Utils.isVideoType(self.fileName){
            return true
        }
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return  UIInterfaceOrientationMask.all
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let invalidRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height-self.toolBar.frame.height)
        self.moviePlayerController?.view.frame = invalidRect
    }
    
    
    deinit{
        print("fileviewcontroller deinit")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //MARK: event handle
    func onClose() {
        
        self.moviePlayerController?.stop()
        
        self.session?.invalidateAndCancel()
        self.session = nil
        
        self.socketio?.disconnect()
        self.socketio = nil
    }
    
    
    func onMore(_ sender: AnyObject) {
        let point = CGPoint(x: self.clientRect().width - 20, y: self.navigationController!.navigationBar.frame.origin.y+self.navigationController!.navigationBar.frame.size.height+5);
        let pop = PopoverView(point: point, btns: self.actBtns)
        pop?.show()
    }
    
    func onBtnDetail(_ btn: UIButton) {
        if let v = btn.superview as? PopoverView{
            v.dismiss(false)
        }
        
        if let info = self.fileInfoData{
            self.showDetailInfo(info)
        } else {
            DispatchQueue.main.async{
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if result != nil {
                    self.fileInfoData = result
                    self.showDetailInfo(self.fileInfoData!)
                }
            }
        }
    }
    
    func onBtnEdit(_ btn: UIButton){
        if let v = btn.superview as? PopoverView{
            v.dismiss(false)
        }
        
        if self.fileName.pathExtension.lowercased() == "gknote"{
            let controller = GKnoteViewController()
            controller.noteContent = self.gknoteContent!
            controller.defaultName = self.fileName
            controller.requestPath = self.fileFullPath.stringByDeletingLastPathComponent
            controller.zipFolderName = Utils.getFileNameWithoutExt(self.fileName)
            controller.delegate = self
            let gknoteNc = UINavigationController(rootViewController: controller)
            self.present(gknoteNc, animated: true, completion: nil)
        }
    }
    
    func onBtnPrint(_ btn: UIButton){
        if let v = btn.superview as? PopoverView{
            v.dismiss(false)
        }
        
        let p = UIPrintInteractionController.shared
        
        if let printInteraction:UIPrintInteractionController = p {
            // width 和height 按自己定义即可，比如说A4大小
            let pdfWidth: Float = 595.0
            let pdfHeight: Float = 842.0
            
            let myRenderer = MyPrintPageRender()
            let viewFormatter: UIViewPrintFormatter = self.webView.viewPrintFormatter()
            myRenderer.addPrintFormatter(viewFormatter, startingAtPageAt: 0)
            
            let pdfData = myRenderer.convertUIWebView(toPDFsaveWidth: pdfWidth, saveHeight: pdfHeight)
            
            //      [pdfData writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"textpdf.pdf"] atomically:YES];
            if UIPrintInteractionController.canPrint(pdfData!) { // Check first
    
                let printInfo = UIPrintInfo.printInfo()
                
                printInfo.duplex = UIPrintInfoDuplex.longEdge
                printInfo.outputType = UIPrintInfoOutputType.general
                printInfo.jobName = self.fileName
                
                printInteraction.printInfo = printInfo
                printInteraction.printingItem = pdfData
                printInteraction.showsPageRange = true
                
                printInteraction.present(animated: true, completionHandler: { (pic, completed, err) -> Void in
                    
                })
                
            }
        }
        
    }
    
    func onAction(){
        self.localFilePath = Utils.getFileCachePath().stringByAppendingPathComponent(path: "\(self.fileHash!).\(self.fileName!.pathExtension)")
        if !FileManager.default.fileExists(atPath: self.localFilePath!){
            self.needAction = true
            if self.failToPreview{
                self.infoLabel.text = Bundle.getLocalStringFromBundle("Downloading...", comment: "")
                self.infoLabel.textColor = RGBA(100, g: 100, b: 100)
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
    
    func gesAction(_ recognize:UITapGestureRecognizer){
        
    }
    

    //MARK: custom method
    func showFailedInfo(_ type: FailedType){
        var info: String!
        switch type {
        case .notSupport:
            info = Bundle.getLocalStringFromBundle("Unsupport to preview", comment: "")
        case .failToConvert:
            info = Bundle.getLocalStringFromBundle("Convert error", comment: "")
        case .noNet:
            info = Bundle.getLocalStringFromBundle("Network error", comment: "")
        case .unZipErr:
            info = Bundle.getLocalStringFromBundle("Unzip error", comment: "")
        }
        self.progressView.isHidden = true
        self.loadingPad.isHidden = false
        self.infoLabel.text = info
        self.infoLabel.textColor = UIColor.red
        self.toolBar.isHidden = false
        self.failToPreview = true
        self.isLoading = false
    }
    
    func openFileWithPath(_ localPath: String) ->Bool{
        if isDetailShowing {
            self.maskTap()
        }
        
        self.loadingPad.isHidden = true
        
        if Utils.isImageType(localPath){
            let htmlStr: String = "<div style=\"width:100%; height:100%; position:absolute; left:0; top:0; text-align:center; font-size:0;\"><span style=\"vertical-align:middle; display:inline-block; height:100%;\"></span><img src=\"\(localPath)\" style=\"width:980px;vertical-align:middle;\"  /></div>"
            self.webView.isOpaque = false
            self.webView.backgroundColor = UIColor.black
            self.webView.isHidden = false
            self.webView.loadHTMLString(htmlStr, baseURL: URL(fileURLWithPath: Utils.getFileCachePath()))
        } else {
            
            if Utils.isVideoType(localPath){
                self.webView.isHidden = true
                
                if !localPath.isEmpty && FileManager.default.fileExists(atPath: localPath){
                    DispatchQueue.main.async{[weak self] in
                        self?.playMovieFile(URL(fileURLWithPath: localPath))
                    }
                }
            } else if Utils.isAudioType(localPath){
                self.webView.isHidden = true
                
                if !localPath.isEmpty && FileManager.default.fileExists(atPath: localPath){
                    DispatchQueue.main.async{[weak self] in
                        self?.playMovieFile(URL(fileURLWithPath: localPath))
                    }
                }
                
            } else if localPath.pathExtension.lowercased() == "txt"{
                if fileSize > 1*1024*1024{
                    self.webView.isHidden = true
                    self.loadingPad.isHidden = false
                    self.infoLabel.text = Bundle.getLocalStringFromBundle("The size of this file is too larage to preview", comment: "")
                    self.infoLabel.textColor = UIColor.red
                    self.progressView.isHidden = true
                } else {
                    self.webView.isHidden = false
                    self.viewTxtFile(localPath)
                }
                
            } else if localPath.pathExtension.lowercased() == "gknote"{
                self.showGknoteContent()
            } else {
                let url = URL(fileURLWithPath: localPath)
                self.webView.isHidden = false
                self.webView.loadRequest(URLRequest(url: url))
            }
            
        }
        
        return true
    }
    
    func showGknoteContent(){
        self.webView.isHidden = false
        let zipPath: String = Utils.getZipCachePath().stringByAppendingPathComponent(path: self.fileName)
        if FileManager.default.fileExists(atPath: zipPath){
            do{
                try FileManager.default.removeItem(atPath: zipPath)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        do{
            
            try FileManager.default.copyItem(atPath: self.localFilePath!, toPath: zipPath)
                let dirname = Utils.getFileNameWithoutExt(self.fileName)
                let zipfolder = Utils.getZipCachePath().stringByAppendingPathComponent(path: dirname)
                try FileManager.default.createDirectory(atPath: zipfolder, withIntermediateDirectories: false, attributes: nil)
                Utils.unZipWithSource(zipPath, targetFileName: dirname, success: { () -> Void in
                    let indexPath = zipfolder.stringByAppendingPathComponent(path: "index.html")
                    let viewerPath = Bundle.myResourceBundleInstance?.path(forResource: "viewer", ofType: "html", inDirectory: "ueditor")
                    var viewString:String? = nil
                    do {
                        
                        self.gknoteContent = try String(contentsOfFile: indexPath, encoding: String.Encoding.utf8)
                        viewString = try String(contentsOfFile: viewerPath!, encoding: String.Encoding.utf8)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                    self.webView.loadHTMLString(Utils.replaceStrBySearchStr(viewString!, search: "${content}", replace: self.gknoteContent!), baseURL: URL(fileURLWithPath: zipfolder))
                    
                    }, fail: { () -> Void in
                        self.showFailedInfo(FailedType.unZipErr)
                })
            
        }catch _ as NSError{
            self.showFailedInfo(FailedType.unZipErr)
        }
        
    }
    
    func viewTxtFile(_ path: String){
        var usedEncoding: String.Encoding = String.Encoding(rawValue: 0)
        var body:NSString! = nil
        do {
            body = try NSString(contentsOfFile: path, usedEncoding: &usedEncoding.rawValue)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if body == nil {
            usedEncoding = String.Encoding(rawValue: 0x80000632)
            do {
                body = try NSString(contentsOfFile: path, usedEncoding: &usedEncoding.rawValue)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        if body == nil {
            usedEncoding = String.Encoding(rawValue: 0x80000631)
            do {
                body = try NSString(contentsOfFile: path, usedEncoding: &usedEncoding.rawValue)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        if body != nil {
            let tx =  Utils.replaceStrBySearchStr(String(body), search: "\n", replace: "<br />")
            self.webView.loadHTMLString("<font size=50>\(tx)</font>", baseURL: nil)
        } else {
            let url = URL(fileURLWithPath: path)
            self.webView.loadRequest( URLRequest(url: url))
        }
    }
    
    
    func fetchPreviewURL(){        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async{
        
            let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
            if let url = result?.uri {
                DispatchQueue.main.sync{
                    self.fileInfoData = result
                    self.convertURL = url
                    self.progressView.setProgress(0.05, animated: true)
                }
                if !url.isEmpty {
                    self.connectSocketIO()
                }
                
            } else {
                DispatchQueue.main.async{
                    self.showFailedInfo(FailedType.failToConvert)
                }
            }
            
        }
        
    }
    
    func fetchDownloadURL(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async{
            let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
            if let url = result?.uri {
                DispatchQueue.main.async{
                    self.fileInfoData = result
                    self.downloadURL = url
                    if !url.isEmpty{
                        self.webView.isHidden = true
                        self.loadingPad.isHidden = false
                        self.progressView.isHidden = false
                        self.progressView.setProgress(0.2, animated: true)
                        self.nowDownloadType = DOWNLOAD_TYPE.directly_ORIGINAL
                        self.startDownloading()
                    }
                };
            } else {
                DispatchQueue.main.async{
                    self.showFailedInfo(FailedType.noNet)
                }
            }
        }
        
    }
    
    func openActMenu(){
        let newLocalPath = Utils.replaceStrBySearchStr(self.localFilePath!, search: self.localFilePath!.lastPathComponent, replace: self.fileName)
        if FileManager.default.fileExists(atPath: newLocalPath){
            self.docController = UIDocumentInteractionController(url: URL(fileURLWithPath: newLocalPath))
            self.isCopyFile = true
        } else {
            do{
                try FileManager.default.copyItem(atPath: localFilePath!, toPath: newLocalPath)
                self.docController = UIDocumentInteractionController(url: URL(fileURLWithPath: newLocalPath))
                self.isCopyFile = true
                
            }catch _ as NSError{
                self.docController = UIDocumentInteractionController(url: URL(fileURLWithPath: self.localFilePath!))
                self.isCopyFile = false
                
            }
            
            
        }
        
        self.docController?.delegate = self
        self.docController?.uti = Utils.getDocumentUTIType(self.fileName.pathExtension)
        self.docController?.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
        
    }
    
    func connectSocketIO(){
        let arr: [String : String?] = ["url":self.convertURL,"filehash":self.fileHash,"ext":self.fileFullPath.pathExtension]
    
        let sign: String = ""
        
        let socketurl = "doc.gokuai.com:5030"
        
        let param = ["url":self.convertURL!,"filehash":self.fileHash!,"ext":self.fileName.pathExtension,"sign":sign]
        
        if self.socketio == nil {
            self.socketio = SocketIOClient(socketURL: URL(string: socketurl)!, config: [.connectParams(param), .forcePolling(true)])
        }
        
        self.socketio!.on("progress"){[weak self] data, ack in
            var previewErr = false
            if let ret = data[0] as? NSDictionary {
                if let pro = ret.value(forKey: "progress") as? Float {
                    if Thread.isMainThread{
                        self?.progressView.setProgress(0.05+(pro/100.00)*0.15, animated: true)
                    } else {
                        DispatchQueue.main.sync{
                            self?.progressView.setProgress(0.05+(pro/100.00)*0.15, animated: true)
                        }
                    }
                    
                    if pro >= 100.0{
                        if let downloadurl = ret.value(forKey: "url") as? String {
                            self?.socketio?.disconnect()
                            self?.socketio = nil
                            self?.downloadURL = downloadurl
                            self?.nowDownloadType = DOWNLOAD_TYPE.preview_FILE
                            DispatchQueue.main.async{
                                self?.webView.isHidden = true
                                self?.loadingPad.isHidden = false
                                self?.progressView.isHidden = false
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
                self?.socketio?.disconnect()
                self?.socketio = nil
                self?.showFailedInfo(FailedType.failToConvert)
            }
            
        }
        
        self.socketio!.on("err"){[weak self] data, ack in
            var notSupport = false
            if let ret = data[0] as? NSDictionary {
                if let code = ret.value(forKey: "error_code") as? Int {
                    if code == 403{
                        notSupport = true
                    }
                }
            }
            self?.socketio?.disconnect()
            self?.socketio = nil
            self?.showFailedInfo(notSupport ? FailedType.notSupport : FailedType.failToConvert )
        }
        
        
        self.socketio?.connect()
    }
    
    func startDownloading(){
        print("start download the original file")
        
        if let _ = self.downloadURL {
            self.recieveBytes = 0
            self.isLoading = true
            
            if self.session == nil {
                let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "com.fileviewcontrollersession.yunkusdk")
                sessionConfig.isDiscretionary = true
                self.session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
            }
            
            var req = URLRequest(url: URL(string: self.downloadURL!)!)
            req.httpMethod = "GET"
            req.httpShouldHandleCookies = false
            req.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
            req.addValue("client-gokuai", forHTTPHeaderField: "User-Agent")
            
            let downTask = self.session?.downloadTask(with:req)

            downTask?.resume()
        }
    }
    
    func startDownloadingAct(){
        
        self.recieveBytes = 0
        self.nowDownloadType = DOWNLOAD_TYPE.original_AFTER_PREIVEW
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async{
            let result: FileData? = FileDataManager.sharedInstance?.getFileInfoSync(self.fileFullPath)
            if let url = result?.uri {
                DispatchQueue.main.async{
                    self.downloadURL = url
                    if !url.isEmpty{
                        //self.alertViewWithProgressbar = AGAlertViewWithProgressbar(title: nil, message: NSBundle.getLocalStringFromBundle("正在加载...", comment: ""), delegate: self, cancelButtonTitle: NSBundle.getLocalStringFromBundle("取消", comment: ""))
                        
                        self.alertViewWithProgressbar = AGAlertViewWithProgressbar(title: nil, message: Bundle.getLocalStringFromBundle("Loading", comment: ""), andDelegate: self)
                        self.alertViewWithProgressbar?.cancelButtonTitle = Bundle.getLocalStringFromBundle("Cancel", comment: "")
                        
                        self.alertViewWithProgressbar?.show()
                        
                        self.startDownloading()
                    }
                };
            } else {
                DispatchQueue.main.async{
                    self.showFailedInfo(FailedType.noNet)
                }
            }
        }
    }
    
    
    //MARK: movie player
    func playMovieFile(_ movieFileURL: URL){
        self.createAndPlayMovieForURL(movieFileURL, sourceType: MPMovieSourceType.file)
    }
    
    fileprivate func createAndPlayMovieForURL(_ movieURL: URL,sourceType: MPMovieSourceType){
        let player = MPMoviePlayerController(contentURL: movieURL)
        if player != nil{
            self.moviePlayerController = player
            
            self.installMovieNotificationObservers()
            
            player?.contentURL = movieURL
            player?.movieSourceType = sourceType  //在播放前设置source type会使加载过程更快
            
            self.applyUserSettingToMoviePlayer()
            
            let invalidRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height-self.toolBar.frame.height)
            
            player?.view.frame = invalidRect
            
            self.view.addSubview((player?.view)!)
            
            player?.play()
        }
    }
    
    fileprivate func installMovieNotificationObservers(){
        if let player = self.moviePlayerController{
            NotificationCenter.default.addObserver(self, selector: #selector(FileViewController.loadStateDidChange(_:)), name: NSNotification.Name.MPMoviePlayerLoadStateDidChange, object: player)
            NotificationCenter.default.addObserver(self, selector: #selector(FileViewController.moviePlayBackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: player)
            NotificationCenter.default.addObserver(self, selector: #selector(FileViewController.mediaIsPreparedToPlayDidChange(_:)), name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange, object: player)
            NotificationCenter.default.addObserver(self, selector: #selector(FileViewController.moviePlayBackStateDidChange(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: player)
            
        }
    }
    
    fileprivate func uninstallMovieNotificationObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerLoadStateDidChange, object: self.moviePlayerController)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: self.moviePlayerController)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange, object: self.moviePlayerController)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: self.moviePlayerController)
    }
    
    fileprivate func applyUserSettingToMoviePlayer(){
        if let player = self.moviePlayerController{
            player.scalingMode = MPMovieScalingMode.aspectFit
            player.controlStyle = MPMovieControlStyle.embedded
            player.repeatMode = MPMovieRepeatMode.none
            player.backgroundView.backgroundColor = RGBA(30, g: 35, b: 40)
            player.allowsAirPlay = true
        }
    }
    
    fileprivate func removeMoviePlayer(){
        if let player = self.moviePlayerController{
            player.view.removeFromSuperview()
            self.uninstallMovieNotificationObservers()
        }
    }
    
    func showDetailInfo(_ data: FileData){
        self.isDetailShowing = true
        let timeC = "\(Utils.formatFileTime(TimeInterval(data.createTime)))"
        let strCreate = "\(data.createName) 创建于 \(timeC))"
        let timeM =  "\(Utils.formatFileTime(TimeInterval(data.lastDateline)))"
        let strModify = "\(data.lastMemberName) 最后修改于 \(timeM)"
        
        let strSize = "大小: \(data.fileSize!)"
        let strLocation="位置: \(data.fullPath)"
        
        let win = UIApplication.shared.keyWindow
        
        maskV = UIControl(frame: UIScreen.main.bounds)
        maskV.backgroundColor = UIColor.black
        maskV.alpha = 0.3
        maskV.addTarget(self, action: #selector(FileViewController.maskTap), for: UIControlEvents.touchDown)
        
        win?.addSubview(maskV)
        
        let rc = self.view.convert(self.view.bounds, to: win)

        detailPad = UIView(frame: CGRect(x: 0, y: rc.origin.y, width: self.view.frame.width, height: 270))
        //detailPad = UIView(frame: CGRectMake((self.view.frame.size.width-280)/2, 130, 280, 270))
        detailPad!.backgroundColor = UIColor.white
        win?.addSubview(detailPad!)

        let imgvFolderV = UIImageView(frame: CGRect(x: (detailPad!.frame.size.width-88)/2, y: 20, width: 90, height: 90))
        imgvFolderV.image = UIImage.imageNameFromMyBundle(Utils.getImageIcon(data.fileName, dir: data.dir))
        detailPad!.addSubview(imgvFolderV)
        
        let filenamel = UILabel(frame: CGRect(x: 0, y: imgvFolderV.frame.origin.y+imgvFolderV.frame.size.height+15, width: detailPad!.frame.size.width, height: 20))
        filenamel.text = data.fileName
        filenamel.backgroundColor = UIColor.clear
        filenamel.font = UIFont.systemFont(ofSize: 16)
        filenamel.textColor = UIColor.black
        filenamel.textAlignment = NSTextAlignment.center
        detailPad!.addSubview(filenamel)
        
        let timecl = UILabel(frame: CGRect(x: 0, y: filenamel.frame.origin.y+filenamel.frame.size.height+5, width: detailPad!.frame.size.width, height: 20))
        timecl.text = strCreate
        timecl.backgroundColor = UIColor.clear
        timecl.font = UIFont.systemFont(ofSize: 13)
        timecl.textColor = UIColor.gray
        timecl.textAlignment = NSTextAlignment.center
        detailPad!.addSubview(timecl)
        let timeml = UILabel(frame: CGRect(x: 0, y: timecl.frame.origin.y+timecl.frame.size.height+5, width: detailPad!.frame.size.width, height: 20))
        timeml.text = strModify;
        timeml.backgroundColor = UIColor.clear
        timeml.font = UIFont.systemFont(ofSize: 13)
        timeml.textColor = UIColor.gray
        timeml.textAlignment = NSTextAlignment.center
        detailPad!.addSubview(timeml)
        let sizel = UILabel(frame: CGRect(x: 0, y: timeml.frame.origin.y+timeml.frame.size.height+5, width: detailPad!.frame.size.width, height: 20))
        sizel.text = strSize;
        sizel.backgroundColor = UIColor.clear
        sizel.font = UIFont.systemFont(ofSize: 13)
        sizel.textColor = UIColor.gray
        sizel.textAlignment = NSTextAlignment.center
        detailPad!.addSubview(sizel)
        let locl = UILabel(frame: CGRect(x: 0, y: sizel.frame.origin.y+sizel.frame.size.height+5, width: detailPad!.frame.size.width, height: 20))
        locl.text = strLocation
        locl.backgroundColor = UIColor.clear
        locl.font = UIFont.systemFont(ofSize: 13)
        locl.textColor = UIColor.gray
        locl.textAlignment = NSTextAlignment.center
        detailPad!.addSubview(locl)
    }
    
    func maskTap(){
        maskV.removeFromSuperview()
        detailPad!.removeFromSuperview()
        isDetailShowing = false
    }
    
    //MARK: Movie Notification Handlers
    func moviePlayBackDidFinish(_ notification: Notification){
        if let dic = notification.userInfo{
            let reason: NSNumber? = dic[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? NSNumber
            if reason != nil{
                if reason!.intValue == 0 {
                    //MPMovieFinishReason.PlaybackEnded
                    
                } else if reason!.intValue == 1{
                    //MPMovieFinishReason.PlaybackError
                    self.removeMoviePlayer()
                } else if reason!.intValue == 2{
                    //MPMovieFinishReason.UserExited
                    self.removeMoviePlayer()
                }
            }
        }
    }
    
    func loadStateDidChange(_ notification: Notification){
        let player: MPMoviePlayerController? = notification.object as? MPMoviePlayerController
        _ = player?.loadState
    }
    
    func moviePlayBackStateDidChange(_ notification: Notification){
        let player: MPMoviePlayerController? = notification.object as? MPMoviePlayerController
        if player != nil {
            _ = player!.playbackState
        }
        
    }
    
    func mediaIsPreparedToPlayDidChange(_ notification: Notification){
        
    }

    
    //MARK: delegate
    
    //MARK: UIWebView Delegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if self.fileName.pathExtension.lowercased() == "gknote"{
            self.actBtns.append(self.btnEdit)
        }
        
        if Utils.isPrintType(self.fileName){
            self.actBtns.append(self.btnPrint)
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        self.alertViewWithProgressbar?.hide()
        self.alertViewWithProgressbar = nil
        
        self.isLoading = false
        self.downloadURL = nil
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        if self.isCopyFile{
            do{
                try FileManager.default.removeItem(at: controller.url!)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            
        }
    }
    
    //MARK: NSURLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }
    
    //MARK: NSURLSessionTaskDelegate
//    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
//        completionHandler(request)
//    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?)
        -> Void) {
            // your code
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        UIApplication.shared.isIdleTimerDisabled = false
        self.isLoading = false
        self.toolBar.isHidden = false
        
        self.alertViewWithProgressbar?.hide()
        
        if error != nil {
            self.showFailedInfo(FailedType.noNet)
        } else {
            if !FileManager.default.fileExists(atPath: self.localFilePath!){
                self.showFailedInfo(FailedType.noNet)
            } else {
                self.loadingPad.isHidden = true
                
                if !self.needAction{
                    self.openFileWithPath(self.localFilePath!)
                } else {
                    self.openActMenu()
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
    }
    
    //MARK: NSURLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let destPos = URL(fileURLWithPath: self.localFilePath!)
        
        do {

           try FileManager.default.copyItem(at: location, to: destPos)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        self.recieveBytes = totalBytesWritten
        
        if self.nowDownloadType == DOWNLOAD_TYPE.original_AFTER_PREIVEW{
            let p: Float = Float(totalBytesWritten)*1.0/Float(fileSize)*1.0
            self.alertViewWithProgressbar?.progress = UInt(p * 100)
            if (p >= 1.000000) {
                self.alertViewWithProgressbar?.hide()
            }
            
        } else {
            var p: Float = 0
            if self.nowDownloadType == DOWNLOAD_TYPE.preview_FILE{
                self.infoLabel.text = "\(Utils.formatSize(UInt64(recieveBytes))), 共\(Utils.formatSize(UInt64(totalBytesExpectedToWrite)))"
                
                p = 0.2+(Float(totalBytesWritten)*1.0/Float(totalBytesExpectedToWrite)*1.0)*0.8
            } else {
                p = 0.2+(Float(totalBytesWritten)*1.0/Float(fileSize)*1.0)*0.8
            }
            self.progressView.setProgress(p, animated: true)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func onFileDidCreate(_ fileName: String) {
        DialogUtils.showProgresing(self)
        self.uploadDelegate.onFileDidCreate(fileName)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: property
    lazy var webView:UIWebView = {
        let rc = self.view.bounds
       let webv = UIWebView(frame: CGRect(x: 0, y: 0, width: rc.width, height: rc.height))
        webv.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        webv.isHidden = true
        webv.delegate = self
        webv.scalesPageToFit = true
        webv.backgroundColor = UIColor.white
        //let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"gesAction" )
        //singleTap.delegate = self
        //webv.addGestureRecognizer(singleTap)
        return webv
    }()

    
    
    lazy var moreBarBtn:UIBarButtonItem = {
        return UIBarButtonItem(title: Bundle.getLocalStringFromBundle("More", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: "onMore:")
    }()
    
    lazy var toolBar:UIToolbar = {
        let rc = self.view.bounds
       var bar = UIToolbar(frame: CGRect(x: 0, y: rc.height-44.0, width: rc.width, height: 44.0))
        bar.barStyle = UIBarStyle.default
        bar.isTranslucent = false
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let actbtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(FileViewController.onAction))
        bar.items = [space,actbtn,space]
        bar.autoresizingMask = [.flexibleWidth , .flexibleTopMargin];
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
        let v = UIView(frame: CGRect(x: 0, y: (rc.height-150)/2-40, width: rc.width, height: 150))
        v.backgroundColor = UIColor.clear
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let imgv: UIImageView = UIImageView(frame: CGRect(x: (rc.width-kIconWidth)/2, y: 0, width: kIconWidth, height: kIconWidth))
        imgv.image = UIImage.imageNameFromMyBundle(Utils.getImageIcon(self.fileName, dir: self.fileDir))
        self.iconView = imgv
        v.addSubview(imgv)
        
        let infoText: UILabel = UILabel(frame: CGRect(x: 10.0, y: imgv.frame.maxY+6.0, width: rc.size.width-20.0, height: 20.0))
        infoText.font = UIFont.systemFont(ofSize: 12.0)
        infoText.textColor = RGBA(100, g: 100, b: 100)
        infoText.textAlignment = NSTextAlignment.center
        infoText.text = Bundle.getLocalStringFromBundle("Beginning to preview", comment:"")
        self.infoLabel = infoText
        v.addSubview(infoText)
        
        let p: UIProgressView = UIProgressView(frame: CGRect(x: (rc.width-150)/2, y: infoText.frame.maxY+10, width: 150.0, height: 10.0))
        p.progressViewStyle = UIProgressViewStyle.default
        p.progress = 0.0
        self.progressView=p
        v.addSubview(p)
        
        return v
    }()
    
    var iconView: UIImageView!
    var infoLabel: UILabel!
    var progressView: UIProgressView!
    
    lazy var btnDetail: UIButton = {
       let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.setTitle(Bundle.getLocalStringFromBundle("Detail", comment: ""), for: UIControlState())
        btn.addTarget(self, action: #selector(FileViewController.onBtnDetail(_:)), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    lazy var btnPrint: UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.setTitle(Bundle.getLocalStringFromBundle("Print", comment: ""), for: UIControlState())
        btn.addTarget(self, action: #selector(FileViewController.onBtnPrint(_:)), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    lazy var btnEdit: UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.setTitle(Bundle.getLocalStringFromBundle("Edit", comment: ""), for: UIControlState())
        btn.addTarget(self, action: #selector(FileViewController.onBtnEdit(_:)), for: UIControlEvents.touchUpInside)
        return btn
        }()
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    var session: Foundation.URLSession? = nil
    
    var moviePlayerController: MPMoviePlayerController? = nil
    
    
    var gkZipName: String? = nil
    var gknoteContent: String? = nil
    
    var fileInfoData: FileData? = nil
    var isDetailShowing: Bool = false
    
    var detailPad: UIView? = nil
    var maskV: UIControl! = nil
    var uploadDelegate:FileUploadManagerDelegate!
    
}



