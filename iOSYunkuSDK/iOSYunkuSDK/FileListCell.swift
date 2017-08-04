//
//  FileListCell.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/29.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit

open class FileListCell : UITableViewCell {
  
    var fileNameLabel:UILabel!
    var fileImgView:UIImageView!
    var infoLabel:UILabel!
    var imageBtn:UIButton!
    var delegate:FileItemOperateDelegate!
    var data:FileData!
    var moreLabel:UILabel!
    
    init(){
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: FileListCell.description())
       
        fileImgView = UIImageView(frame: CGRect(x: 20,  y: 10, width: 34, height: 34))
        
        fileNameLabel = UILabel(frame: CGRect(x: 62, y: 4, width: 210, height: 24))
        fileNameLabel.numberOfLines = 1
        fileNameLabel.font = UIFont.systemFont(ofSize: 14)
        
        infoLabel = UILabel(frame: CGRect(x: 62, y: 28, width: 210, height: 24))
        infoLabel.numberOfLines = 1
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        infoLabel.textColor = UIColor.gray
        
        imageBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54, y: 0, width: 54, height: 54))
        imageBtn.setImage(UIImage.imageNameFromMyBundle("ic_dropdown_flag_down_normal"), for: UIControlState())
        imageBtn.setImage(UIImage.imageNameFromMyBundle("ic_dropdown_flag_down_pressed"), for: UIControlState.highlighted)
        imageBtn.imageEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        imageBtn.contentMode = UIViewContentMode.scaleAspectFit
        imageBtn.addTarget(self, action: #selector(FileListCell.onItemOperate(_:)), for: UIControlEvents.touchUpInside)
        
        moreLabel = UILabel(frame: CGRect( x: (self.frame.width - 210)/2 , y: 15, width: 210, height: 24))
        moreLabel.numberOfLines = 1
        moreLabel.font = UIFont.systemFont(ofSize: 14)
        moreLabel.text = Bundle.getLocalStringFromBundle("Load More", comment: "")
        moreLabel.textAlignment = NSTextAlignment.center
       
        self.addSubview(self.fileNameLabel)
        self.addSubview(self.fileImgView)
        self.addSubview(self.infoLabel)
        self.addSubview(self.imageBtn)
        self.addSubview(self.moreLabel)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
       
    }
    
    //MARK:绑定FileData数据
    func bindView(_ data:FileData,delegate:FileItemOperateDelegate,option:Option?){
        self.data = data
        self.delegate = delegate
        
        self.fileImgView.isHidden = data.isFoot
        
        self.infoLabel.isHidden = data.isFoot
        self.imageBtn.isHidden = data.isFoot
        self.fileNameLabel.isHidden = data.isFoot
        self.moreLabel.isHidden = !data.isFoot
        
        if data.isFoot{
            return
        }

        
        fileImgView.image = UIImage.imageNameFromMyBundle(data.icons)
        fileNameLabel.text = data.fileName
        
        let timeStr = Utils.formatFileTime(Double(data.lastDateline))
        if data.dir == FileData.dirs {
            infoLabel.text = timeStr
        }else{
            let fileSizeStr = Utils.formatSize(data.fileSize)
            infoLabel.text = "\(fileSizeStr),\(timeStr)"
            
            if Utils.isImageType(data.fileName){
                let url = URL(string: data.thumbNail)
                
                self.fileImgView.hnk_setImageFromURL(url!)

            }
        }
        
        if option == nil || (!option!.canRename && !option!.canDel){
            self.imageBtn.isHidden = true
        }
    }
    
    func onItemOperate(_ sender:AnyObject){
        delegate.onItemOperte(self.tag)
    }
    
}

protocol FileItemOperateDelegate {
    func onItemOperte(_ index:Int)
}

