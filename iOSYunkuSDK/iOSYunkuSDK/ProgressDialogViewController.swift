//
//  DialogViewController.swift
//  iOSYunkuSDK
//
//  Created by Brandon on 15/7/6.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

import UIKit

class  ProgressDialogViewController :UIViewController {
    
    var popUpView:UIView!
    var fileImg:UIImageView!
    var fileNameLabel:UILabel!
    var progressBar:UIProgressView!
    var percentLabel:UILabel!
    var messageLabel:UILabel!
    var cancelBtn:UIButton!
    var delegate :ProgressDialogDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView = UIView(frame: CGRectMake(20, (self.clientRect().height - 150) / 2, self.clientRect().width - 40, 150))
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.popUpView.backgroundColor = UIColor.whiteColor()
        
        self.fileNameLabel = UILabel(frame: CGRectMake(8, 12, self.clientRect().width - 48, 20))
        self.fileNameLabel.font = UIFont.systemFontOfSize(16)
        self.fileNameLabel.textAlignment = NSTextAlignment.Center
        self.fileNameLabel.numberOfLines = 1
        
        self.fileImg = UIImageView(frame: CGRectMake(10, 68 , 34, 34))
        
        self.progressBar = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
        self.progressBar.frame = CGRectMake(54, 84 , self.clientRect().width - 144, 15)
        self.progressBar.trackTintColor = UIColor(red: 201 / 255, green: 201 / 255, blue: 201 / 255, alpha: 1)
        
        self.percentLabel = UILabel(frame: CGRectMake( self.clientRect().width - 102 , 68, 52, 32))
        self.percentLabel.font = UIFont.systemFontOfSize(12)
        self.percentLabel.textAlignment = NSTextAlignment.Right
        
        self.messageLabel = UILabel(frame: CGRectMake(0, 40, self.clientRect().width - 40 , 21))
        self.messageLabel.numberOfLines = 1
        
        self.messageLabel.textColor = UIColor.grayColor()
        self.messageLabel.textAlignment = NSTextAlignment.Center
        self.messageLabel.font = UIFont.systemFontOfSize(14)
        
        self.cancelBtn = UIButton(frame: CGRectMake( (self.clientRect().width - 92) / 2 , 110, 52, 32))
        self.cancelBtn.setTitle(NSBundle.getLocalStringFromBundle("Cancel", comment: ""), forState: UIControlState.Normal)
        self.cancelBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.cancelBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        self.cancelBtn.addTarget(self, action: "onCancelClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelBtn.setTitleColor(UIColor(red: 5 / 255 , green: 122 / 255, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.cancelBtn.setTitleColor(UIColor(red: 5 / 255 , green: 122 / 255, blue: 1, alpha: 0.5), forState: UIControlState.Highlighted)

        
        self.popUpView.addSubview(self.fileNameLabel)
        self.popUpView.addSubview(self.fileImg)
        self.popUpView.addSubview(self.progressBar)
        self.popUpView.addSubview(self.percentLabel)
        self.popUpView.addSubview(self.messageLabel)
        self.popUpView.addSubview(self.cancelBtn)
        
        self.view.addSubview(self.popUpView)
    }
    
    func onCancelClick(sender:AnyObject){
        if delegate != nil{
            delegate.onDialogCacnel()
        }
        
    }
    
    func showInView(aView: UIView!, fileName: String, message:String,animated: Bool){
        aView.window?.addSubview(self.view)
        
        self.fileImg.image = UIImage.imageNameFromMyBundle(Utils.getImageIcon(fileName, dir: 0))
        self.messageLabel.text = message
        self.fileNameLabel.text = fileName
        self.setProgress(0)
        
        if animated{
            self.showAnimate()
        }
    }
    
    func setProgress(percent:Float){
        self.progressBar.setProgress(percent, animated: true)
        self.percentLabel.text = "\(Int(percent * 100))%"
    }
    
    func setMessage(message:String){
        self.messageLabel.text = message
    }
    
    func showAnimate(){
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate(){
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.popUpView = nil
        self.fileImg = nil
        self.fileNameLabel = nil
        self.progressBar = nil
        self.messageLabel = nil
        self.percentLabel = nil
        self.cancelBtn = nil
    }

}

protocol ProgressDialogDelegate{
    
    func onDialogCacnel()
}
