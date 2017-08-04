//
//  YKMainViewControl.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/25.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit
import YunkuSwiftSDK
import AssetsLibrary

open class YKMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,FileListDataDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,RenameDelegate,NewFolderDelegate,FileItemOperateDelegate,RequestDelegate,UIAlertViewDelegate,FileUploadManagerDelegate{
    
    //=================view=================
    var tableView:UITableView!
    var refreshControl:UIRefreshControl!
    var emptyLabel:UILabel!
 
    //======================================
    
    
    //================ data =================
    var fullPath = SDKConfig.orgRootPath
    var fileList:Array<FileData>!
    var photoArray:Array<ImageData>!
    
    var isAnimating = false
    var dropDownViewIsDisplayed = false
    
    var hightLightFileName = ""
    
    var isLoading = false
    
    open var option:Option!
    
    open var delegate:HookDelegate!

    //======================================
  
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        if self == self.navigationController?.viewControllers[0] {//is root
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Bundle.getLocalStringFromBundle("Close", comment: ""),
                style: UIBarButtonItemStyle.plain, target: self, action:"onClose:")
        }
        
        //设置返回按钮的文字
        let backButton = UIBarButtonItem(title: Bundle.getLocalStringFromBundle("Back", comment: ""),
                        style: UIBarButtonItemStyle.plain, target: self, action:"onBack:")
        
        self.navigationItem.backBarButtonItem = backButton
        
        
        if !(option == nil || !option.canUpload){
            //设置添加按钮
            let addButton = UIBarButtonItem(title: Bundle.getLocalStringFromBundle("Add", comment: ""),
                style: UIBarButtonItemStyle.plain, target: self, action:"onAdd:")
            self.navigationItem.rightBarButtonItem = addButton
        }
        
        //设置标题
        self.navigationItem.title = FileDataManager.sharedInstance!.isRootPath(self.fullPath) ? SDKConfig.orgRootTitle : self.fullPath.lastPathComponent
        
        self.tableView = UITableView(frame: self.clientRect(), style: UITableViewStyle.plain)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        
        //添加下拉刷新的控件
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(YKMainViewController.onRefresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
      
        //设置emptyView
        self.emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 300))
        self.emptyLabel.text = Bundle.getLocalStringFromBundle("Empty Folder", comment: "")
        self.emptyLabel.textAlignment = NSTextAlignment.center
        self.emptyLabel.textColor = UIColor.gray
        self.emptyLabel.font = UIFont.systemFont(ofSize: 14)
        self.emptyLabel.isHidden = false
        
        self.tableView.addSubview(self.emptyLabel)
        
        self.initData()
        
        FileDataManager.sharedInstance?.registerHook(self.delegate)
        
    }
    
    //MARK:文件列表返回和文件
    func onBack(_ sender:AnyObject?){
        if FileDataManager.sharedInstance!.isRootPath(self.fullPath) {
            self.dismiss(animated: true, completion: nil)
            
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    
    }
    
    //MARK:列表刷新
    func onRefresh(_ sender:AnyObject?){
        self.initData()
    }
    
    //MARK:文件添加
    func onAdd(_ sender:AnyObject?){
        
        let sheet = UIActionSheet(title: Bundle.getLocalStringFromBundle("Add files to ...", comment: ""), delegate: self, cancelButtonTitle: Bundle.getLocalStringFromBundle("Cancel", comment: ""),
            destructiveButtonTitle: nil, otherButtonTitles:  Bundle.getLocalStringFromBundle("New Folder", comment: ""),
            Bundle.getLocalStringFromBundle("Gallery", comment: ""), Bundle.getLocalStringFromBundle("Take Photo", comment: ""),
            Bundle.getLocalStringFromBundle("Gknote", comment: ""))
        sheet.tag = actionSheetTagAddFile
        sheet.show(in: self.view)
        
       
    }
    
    
    //MARK:初始化列表数据
    func initData(){
        self.emptyLabel.text = Bundle.getLocalStringFromBundle("Loading", comment: "")
        
        FileDataManager.sharedInstance?.getFileList(0, fullPath: fullPath, delegate: self)
    }
    
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.fileList == nil || self.fileList.count == 0 {
            self.emptyLabel.isHidden = false
            return 0
        }
        self.emptyLabel.isHidden = true
        return self.fileList.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  FileListCell()
        cell.tag = indexPath.row
        cell.bindView( fileList[indexPath.row], delegate:self, option: self.option)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        let data = fileList[indexPath.row]
        
        //文件夹
        if data.dir == FileData.dirs {
            
            let control = YKMainViewController()
            control.fullPath = data.fullPath
            control.delegate = self.delegate
            control.option = self.option
            self.navigationController?.pushViewController(control, animated: true)
        
        }else if data.isFoot{
            if !self.isLoading{
                let cell: FileListCell = tableView.cellForRow(at: indexPath) as! FileListCell
                cell.moreLabel.text = Bundle.getLocalStringFromBundle("Loading", comment: "")
                self.isLoading = true
                FileDataManager.sharedInstance?.getMoreList(self)
            }
           
        }else {
            //打开文件
            if Utils.isImageType(data.fileName){
                let photoControl =  FGalleryViewController(nibName: self.debugDescription, bundle: nil)
                var imageList = Array<ImageData>()
                var index = 0
                var startIndex = 0 //当前文件在图库中的位置
                for fileData in self.fileList{
                    if Utils.isImageType(fileData.fileName){
                        imageList.append(ImageData(data:fileData))
                        //当前列表
                        if data.fullPath == fileData.fullPath{
                            startIndex = index
                        }
                        
                        index += 1
                    }
                }
                
                self.photoArray = imageList
                photoControl.startingIndex = startIndex
                photoControl.photoArray = NSMutableArray(array: self.photoArray)
                self.present(UINavigationController(rootViewController: photoControl), animated: true, completion: nil)

            } else {
                
                let fileViewer = FileViewController(fullpath: data.fullPath, filename: data.fileName, dir: data.dir, filehash: data.fileHash, localpath: "", filesize: data.fileSize)
                fileViewer.uploadDelegate = self
                self.navigationController?.pushViewController(fileViewer, animated: true)
            }
            
        }
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

        self.tableView = nil
        self.refreshControl = nil
        self.emptyLabel = nil
    }
    
    
    //MARK:接收到文件请求数据
    func onHttpRequest(_ start: Int, fullPath: String, list: Array<FileData>) {
        self.refreshControl.endRefreshing()
        
        self.isLoading = false
        
        self.emptyLabel.text = Bundle.getLocalStringFromBundle("Empty Folder", comment: "")
        
        //防止多次点击，返回错位的列表
        if self.fullPath == fullPath{
            
            if start == 0{
                self.fileList = list
            }else{
                //=====如果最后一个是 加载更多一项，要移除=====
                let footer = self.fileList.last!
                if footer.isFoot{
                    self.fileList.removeLast()
                }
                //===================================
            
                self.fileList.append(contentsOf: list)
            }
            
            if list.count >= FileDataManager.pageSize {//大于是防止服务端错误
                //还有更多数据添加更多一项
                let footer = self.fileList.last!
                if !footer.isFoot {
                    self.fileList.append(FileData.createFooter())
                }
                
            }

            self.tableView.reloadData()
        }
        
        if !self.hightLightFileName.isEmpty{
            DialogUtils.hideProgresing(self)
            self.hightLightName(self.hightLightFileName)
        
        }
  
    }
    
    func onHttpRequest(_ action: Action) {
        
        switch action {
        case Action.delete:
            DialogUtils.hideProgresing(self)
            
            self.fileList.remove(at: self.operatingIndex)
            self.tableView.reloadData()
            
        default:
            ()
        }

    }
    
    //MARK:返回请求错误信息
    func onError(_ errorMsg:String){
        self.isLoading = false
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        self.view.makeToast(message: errorMsg)
        self.emptyLabel.text = errorMsg
        
    }
    
    //MARK:返回Hook错误
    func onHookError(_ type:HookType){
        self.isLoading = false
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        DialogUtils.hideProgresing(self)
        
    }
    
    //MARK:没有网络
    func onNetUnable(){
        self.isLoading = false
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        let message = NSLocalizedString("Network not available", tableName: nil, bundle: Bundle.myResourceBundleInstance!, value: "", comment: "")
        self.view.makeToast(message: message)
        self.emptyLabel.text = message
        DialogUtils.hideProgresing(self)
        
    }
    
    let actionSheetTagAddFile = 1
    let actionSheetTagFileOpration = 2
    
    open func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {

        if actionSheet.tag == actionSheetTagAddFile {
            switch buttonIndex {
            case 1://Folder
                let newFolderC = NewFolderController()
                newFolderC.list = fileList
                newFolderC.upFullPath = self.fullPath
                newFolderC.delegate = self
                let navC = UINavigationController(rootViewController: newFolderC)
                self.present(navC, animated: true, completion: nil)
                
            case 2://Gallery
                
                if(!Utils.canAccessPhotos()){
                    let message = Bundle.getLocalStringFromBundle("Need the prermission of Photos , please access the Setting -> Private -> Photos", comment: "")
                    let alert = UIAlertView(title: nil, message: message, delegate: self, cancelButtonTitle: Bundle.getLocalStringFromBundle("I Know", comment: ""))
                    alert.show()
                    return
                    
                }
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                    
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.present(picker, animated: true, completion: nil)
                    
                }
                
            case 3://Photos
                if(!Utils.canAcessCamera()){
                    let message = Bundle.getLocalStringFromBundle("Need the prermission of Photos , please access the Setting -> Private -> Camera", comment: "")
                    let alert = UIAlertView(title: nil, message: message, delegate: self, cancelButtonTitle: Bundle.getLocalStringFromBundle("I Know", comment: ""))
                    alert.show()
                    return
                    
                }
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(picker, animated: true, completion: nil)
                }
                
            case 4://gknote
                
                let control = GKnoteViewController()
                control.fileList = self.fileList
                control.requestPath = self.fullPath
                control.delegate = self
                let navC = UINavigationController(rootViewController: control)
                
                self.present(navC, animated: true, completion: nil)
                
            default:
                ()
                
            }
            
        }else if actionSheet.tag == actionSheetTagFileOpration {
            
            let reNameIndex = option.canRename ? 1 : -1
            
            let deleteIndex = option.canRename ? 2 : 1
            
            switch buttonIndex {
                
            case reNameIndex:
                
                let renameC = RenameController()
                renameC.list = fileList
                renameC.delegate = self
                renameC.fileIndex = self.operatingIndex
                let navC = UINavigationController(rootViewController: renameC)
                self.present(navC, animated: true, completion: nil)
                
            case deleteIndex:
                
                let message = Bundle.getLocalStringFromBundle("Are you sure to delete this file?", comment: "")
                DialogUtils.showTipDialog(message, okBtnString: Bundle.getLocalStringFromBundle("Delete", comment: ""), delegate: self, tag: alertTagDelete)
                
            default:
                ()
                
            }
            
        }

    }
    
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        var filename:String?
        var image: UIImage?
        
        if picker.sourceType == UIImagePickerControllerSourceType.camera{
            image = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage
            
            //根据当前时间生成照片的名字
            filename =  Utils.formatImageNameFromAssetLibrary(Date().timeIntervalSince1970)
            
            self.uploadImage(filename!, image: image!, picker: picker)
            
        }else if picker.sourceType == UIImagePickerControllerSourceType.photoLibrary{
            //获取照片在asset library的url
            let localUrl = editingInfo![UIImagePickerControllerReferenceURL] as? URL
            var loadError: NSError?
            
            let assetsLibrary = ALAssetsLibrary()
            assetsLibrary.asset(for: localUrl, resultBlock: { (asset) -> Void in
                
                let imageRep:ALAssetRepresentation = asset!.defaultRepresentation() as ALAssetRepresentation
                
                //获取照片的时间
                let date:Date = (asset?.value(forProperty: ALAssetPropertyDate) as! Date?)!
                
                //设置照片的名字
                filename =  Utils.formatImageNameFromAssetLibrary(date.timeIntervalSince1970)
                
                //获取照片的数据
                let iref: Unmanaged<CGImage> = imageRep.fullResolutionImage()
                image = UIImage( cgImage: iref.takeRetainedValue())
                
                self.uploadImage(filename!, image: image!, picker: picker)
                iref.retain()//避免被释放
                
                }, failureBlock: { (error) -> Void in
                    loadError = error;
            } as! ALAssetsLibraryAccessFailureBlock)
            
            
            if (loadError != nil) {
                LogPrint.error("image upload err:\(loadError)")
                
            }
            
        }
    }

   
    //MARK:上传图片
    func uploadImage(_ filename:String,image:UIImage,picker:UIImagePickerController){
        
        var localPath:String?
        let upFullPath = self.fullPath
        
        //保存至本地缓存
        localPath = Utils.saveImageToCache(image,fileName:filename)
        //设置上传路径
        let appendingString = upFullPath.isEmpty ? "": "/"
        let fullPath = String(format: "%@%@%@", upFullPath,appendingString,filename)
        
        LogPrint.info("fileName:\(filename)")
        LogPrint.info("localPath:\(localPath)")
        
        picker.dismiss(animated: true, completion: {()-> Void in
            
            FileUploadManager.sharedInstance?.upload(fullPath, data: LocalFileData(fileName: filename, localPath: localPath!),view:self.view)
            FileUploadManager.sharedInstance?.delegate = self
            
        })
        
    }
  
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:接受需要高亮显示的文件名
    func hightLightName(_ hightLightName: String) {
        
        for (index,data) in self.fileList.enumerated() {
            if data.fileName == hightLightName{
                self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
                
                self.hightLightFileName = ""
            }
        }

    }
    
    //MARK:重命名操作完成
    func didRenamed(_ newName: String, index: Int) {
        let data = self.fileList[index]
        data.fileName = newName
        let parentPath = data.fullPath.stringByDeletingLastPathComponent
        let appendingString = parentPath.isEmpty ? "":"/"
        let newPath = "\(parentPath)\(appendingString)\(newName)"
        data.fullPath = newPath
        self.tableView.reloadData()
        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
    }
    
    //MARK:文件夹创建完成
    func didCreateFolder(_ fileName: String) {
        let data  = FileData()
        let appendingString = self.fullPath.isEmpty ? "":"/"
        data.fullPath = "\(self.fullPath)\(appendingString)\(fileName)"
        data.fileName = fileName
        data.dir = FileData.dirs
        data.lastDateline = Int(Date().timeIntervalSince1970)
        self.fileList.insert(data, at: 0)
        self.tableView.reloadData()
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
    }
    
    func onFileDidCreate(_ fileName: String) {
        self.hightLightFileName = fileName
        self.onRefresh(nil)
        DialogUtils.showProgresing(self)
    }
    
    //MARK:正在操作的一列index
    var operatingIndex:Int!
    
    //MARK:cell 单项操作
    func onItemOperte(_ index: Int) {
        
        self.operatingIndex = index
        
        let isSepecial = option != nil && ((option.canRename && !option.canDel) || (!option.canRename && option.canDel))
        
        let butonName =  isSepecial && option.canRename ? Bundle.getLocalStringFromBundle("Rename", comment: "") : Bundle.getLocalStringFromBundle("Delete", comment: "")
        
        let sheet = !isSepecial ? UIActionSheet(title: Bundle.getLocalStringFromBundle("File Oprations...", comment: ""), delegate: self, cancelButtonTitle: Bundle.getLocalStringFromBundle("Cancel", comment: ""),
            destructiveButtonTitle: nil, otherButtonTitles:  Bundle.getLocalStringFromBundle("Rename", comment: ""),
            Bundle.getLocalStringFromBundle("Delete", comment: ""))
            : UIActionSheet(title: Bundle.getLocalStringFromBundle("File Oprations...", comment: ""), delegate: self, cancelButtonTitle: Bundle.getLocalStringFromBundle("Cancel", comment: ""),
                destructiveButtonTitle: nil, otherButtonTitles: butonName)

        sheet.delegate = self
        sheet.tag = actionSheetTagFileOpration
        sheet.show(in: self.view)

    }
    
    //MARK:删除tag
    let alertTagDelete = 0
    
    open func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        if alertView.tag == alertTagDelete {
            if buttonIndex == 1 {
                
                let data = self.fileList[operatingIndex]
                self.view.makeToastActivity()
                
                FileDataManager.sharedInstance?.del(data.fullPath, delegate: self)
            }
        }
   
    }
    

    //MARK:兼容iPad bug
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            OperationQueue.main.addOperation{
                super.present(viewControllerToPresent, animated: flag, completion: completion)
            }
        
        }else{
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        
        }
    }
    
    func onClose(_ sender:AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
}

