//
//  FileListCell.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/6/29.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit

public class FileListCell : UITableViewCell {
  
    var fileNameLabel:UILabel!
    var fileImgView:UIImageView!
    var infoLabel:UILabel!
    var imageBtn:UIButton!
    var delegate:FileItemOperateDelegate!
    var data:FileData!
    var moreLabel:UILabel!
    
    init(){
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: FileListCell.description())
       
        fileImgView = UIImageView(frame: CGRectMake(20,  10, 34, 34))
        
        fileNameLabel = UILabel(frame: CGRectMake(62, 4, 210, 24))
        fileNameLabel.numberOfLines = 1
        fileNameLabel.font = UIFont.systemFontOfSize(14)
        
        infoLabel = UILabel(frame: CGRectMake(62, 28, 210, 24))
        infoLabel.numberOfLines = 1
        infoLabel.font = UIFont.systemFontOfSize(12)
        infoLabel.textColor = UIColor.grayColor()
        
        imageBtn = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 54, 0, 54, 54))
        imageBtn.setImage(UIImage.imageNameFromMyBundle("ic_dropdown_flag_down_normal"), forState: UIControlState.Normal)
        imageBtn.setImage(UIImage.imageNameFromMyBundle("ic_dropdown_flag_down_pressed"), forState: UIControlState.Highlighted)
        imageBtn.imageEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        imageBtn.contentMode = UIViewContentMode.ScaleAspectFit
        imageBtn.addTarget(self, action: "onItemOperate:", forControlEvents: UIControlEvents.TouchUpInside)
        
        moreLabel = UILabel(frame: CGRectMake( (self.frame.width - 210)/2 , 15, 210, 24))
        moreLabel.numberOfLines = 1
        moreLabel.font = UIFont.systemFontOfSize(14)
        moreLabel.text = NSBundle.getLocalStringFromBundle("Load More", comment: "")
        moreLabel.textAlignment = NSTextAlignment.Center
       
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
    func bindView(data:FileData,delegate:FileItemOperateDelegate,option:Option?){
        self.data = data
        self.delegate = delegate
        
        self.fileImgView.hidden = data.isFoot
        
        self.infoLabel.hidden = data.isFoot
        self.imageBtn.hidden = data.isFoot
        self.fileNameLabel.hidden = data.isFoot
        self.moreLabel.hidden = !data.isFoot
        
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
                let url = NSURL(string: data.thumbNail)
                
                self.fileImgView.hnk_setImageFromURL(url!)

            }
        }
        
        if option == nil || (!option!.canRename && !option!.canDel){
            self.imageBtn.hidden = true
        }
    }
    
    func onItemOperate(sender:AnyObject){
        delegate.onItemOperte(self.tag)
    }
    
}

protocol FileItemOperateDelegate {
    func onItemOperte(index:Int)
}

