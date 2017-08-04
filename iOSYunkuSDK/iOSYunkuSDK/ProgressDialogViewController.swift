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
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popUpView = UIView(frame: CGRect(x: 20, y: (self.clientRect().height - 150) / 2, width: self.clientRect().width - 40, height: 150))
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.popUpView.backgroundColor = UIColor.white
        
        self.fileNameLabel = UILabel(frame: CGRect(x: 8, y: 12, width: self.clientRect().width - 48, height: 20))
        self.fileNameLabel.font = UIFont.systemFont(ofSize: 16)
        self.fileNameLabel.textAlignment = NSTextAlignment.center
        self.fileNameLabel.numberOfLines = 1
        
        self.fileImg = UIImageView(frame: CGRect(x: 10, y: 68 , width: 34, height: 34))
        
        self.progressBar = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
        self.progressBar.frame = CGRect(x: 54, y: 84 , width: self.clientRect().width - 144, height: 15)
        self.progressBar.trackTintColor = UIColor(red: 201 / 255, green: 201 / 255, blue: 201 / 255, alpha: 1)
        
        self.percentLabel = UILabel(frame: CGRect( x: self.clientRect().width - 102 , y: 68, width: 52, height: 32))
        self.percentLabel.font = UIFont.systemFont(ofSize: 12)
        self.percentLabel.textAlignment = NSTextAlignment.right
        
        self.messageLabel = UILabel(frame: CGRect(x: 0, y: 40, width: self.clientRect().width - 40 , height: 21))
        self.messageLabel.numberOfLines = 1
        
        self.messageLabel.textColor = UIColor.gray
        self.messageLabel.textAlignment = NSTextAlignment.center
        self.messageLabel.font = UIFont.systemFont(ofSize: 14)
        
        self.cancelBtn = UIButton(frame: CGRect( x: (self.clientRect().width - 92) / 2 , y: 110, width: 52, height: 32))
        self.cancelBtn.setTitle(Bundle.getLocalStringFromBundle("Cancel", comment: ""), for: UIControlState())
        self.cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.cancelBtn.titleLabel?.textAlignment = NSTextAlignment.center
        self.cancelBtn.addTarget(self, action: #selector(ProgressDialogViewController.onCancelClick(_:)), for: UIControlEvents.touchUpInside)
        self.cancelBtn.setTitleColor(UIColor(red: 5 / 255 , green: 122 / 255, blue: 1, alpha: 1), for: UIControlState())
        self.cancelBtn.setTitleColor(UIColor(red: 5 / 255 , green: 122 / 255, blue: 1, alpha: 0.5), for: UIControlState.highlighted)

        
        self.popUpView.addSubview(self.fileNameLabel)
        self.popUpView.addSubview(self.fileImg)
        self.popUpView.addSubview(self.progressBar)
        self.popUpView.addSubview(self.percentLabel)
        self.popUpView.addSubview(self.messageLabel)
        self.popUpView.addSubview(self.cancelBtn)
        
        self.view.addSubview(self.popUpView)
    }
    
    func onCancelClick(_ sender:AnyObject){
        if delegate != nil{
            delegate.onDialogCacnel()
        }
        
    }
    
    func showInView(_ aView: UIView!, fileName: String, message:String,animated: Bool){
        aView.window?.addSubview(self.view)
        
        self.fileImg.image = UIImage.imageNameFromMyBundle(Utils.getImageIcon(fileName, dir: 0))
        self.messageLabel.text = message
        self.fileNameLabel.text = fileName
        self.setProgress(0,animated:false)
        
        if animated{
            self.showAnimate()
        }
    }
    
    func setProgress(_ percent:Float, animated:Bool){
        self.progressBar.setProgress(percent, animated: animated)
        self.percentLabel.text = "\(Int(percent * 100))%"
    }
    
    func setMessage(_ message:String){
        self.messageLabel.text = message
    }
    
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
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
