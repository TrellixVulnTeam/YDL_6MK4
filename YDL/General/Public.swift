//
//  Public.swift
//  YDL
//
//  Created by ceonfai on 2019/1/7.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import Foundation
import UIKit

//用于下载的枚举
enum DOWNLOAD_STATE: Int32 {
    case DOWNLOADING = 0
    case DOWNLOADED  = 1
}
enum SUPORTURL: String {
    case Youtube = "https://m.youtube.com"
    case Vimeo   = "https://vimeo.com/"
    case dailyMotion  = "https://www.dailymotion.com/hk"
}

//时间格式
var dateFormatter = { () -> DateFormatter in 
    let df = DateFormatter() as DateFormatter
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
   return df
}()

//沙盒路径
let MyDocumentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
let MyCachesPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
let MyTempPath = NSTemporaryDirectory()

let tiercelPath = MyCachesPath + "/com.Daniels.Tiercel.Cache.default/Downloads/File/"

//屏幕
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

//设备
let IsIPad = (UIDevice.current.userInterfaceIdiom == .pad) ?true:false

/************************  屏幕尺寸  ***************************/
// 屏幕宽度
let WindowWidth = UIScreen.main.bounds.size.width
// 屏幕高度
let WindowHeight = UIScreen.main.bounds.size.height
// iPhone4
let isIphone4 = WindowHeight  < 568 ? true : false
// iPhone 5
let isIphone5 = WindowHeight  == 568 ? true : false
// iPhone 6
let isIphone6 = WindowHeight  == 667 ? true : false
// iphone 6P
let isIphone6P = WindowHeight == 736 ? true : false
// iphone X/s
let isIphoneXS = WindowHeight == 812 ? true : false
// iphone XR
let isIphoneXR = WindowHeight == 414 ? true : false
// iphone XSM
let isIphoneXSM = WindowHeight == 896 ? true : false
//是否刘海屏
let isBangDevice = (isIphoneXS||isIphoneXR||isIphoneXSM) ?true:false
// navigationBarHeight
let navigationBarHeight : CGFloat = isIphoneXS ? 88 : 64




//定义一些颜色
let BGColorForList = UIColor.init(displayP3Red: 245, green: 243, blue: 244, alpha: 1.0)

func RGBA(R:CGFloat,G:CGFloat,B:CGFloat,A:CGFloat) -> UIColor {
    return UIColor.init(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: A)
}

//媒体文件时长计算
func formatTimeInterval(seconds:NSInteger)->String{
    
    if(seconds<0){
        return "--:--"
    }
    var s = seconds
    var m = s/60
    let h = m/60
    
    s = s % 60
    m = m % 60
    
    var timeString = String()
    
    if(h>0){
        timeString.append(String(format:"%ld:%0.2ld", h, m))
        timeString.append(String(format:":%0.2ld",s))
    }else{
        
        timeString.append(String(format:"%0.2ld", m))
        timeString.append(String(format:":%0.2ld",s))
    }
    return timeString
}

//沙盒文件大小
func getSize(url: URL)->UInt64
{
    var fileSize : UInt64 = 0
    do {
        let attr = try FileManager.default.attributesOfItem(atPath: url.path)
        fileSize = attr[FileAttributeKey.size] as! UInt64
        let dict = attr as NSDictionary
        fileSize = dict.fileSize()
    } catch {
        print("Error: \(error)")
    }
    return fileSize
}

//计算文件大小
func calculateSize(sizeOfByte:NSInteger)->String{
    
    if(sizeOfByte<=0){
        return "0B"
    }
    return ByteCountFormatter.string(fromByteCount:Int64(sizeOfByte), countStyle: ByteCountFormatter.CountStyle.binary)
}

//自定义HUD
func showHUD(type:DGActivityIndicatorAnimationType) {
    let window: UIWindow? = UIApplication.shared.keyWindow
    let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    backgroundView.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.8)
//    let blur = UIBlurEffect(style: .light)
//    let effe = UIVisualEffectView(effect: blur)
//    effe.frame = backgroundView.bounds
//    backgroundView.addSubview(effe)
    let activityIndicatorView = DGActivityIndicatorView(type: type, tintColor: RGBA(R: 0, G: 0, B: 0, A: 0.9))
    let width: CGFloat = backgroundView.bounds.size.width / 5.0
    let height: CGFloat = backgroundView.bounds.size.height / 7.0
    activityIndicatorView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
    activityIndicatorView?.tintColor = .white
    activityIndicatorView!.center = backgroundView.center
    backgroundView.addSubview(activityIndicatorView!)
    activityIndicatorView!.startAnimating()
    window?.addSubview(backgroundView)
    //添加标记 方便移除
    backgroundView.tag = 12345
    activityIndicatorView!.tag = 123456
}

func endHUD() {
    let window: UIWindow? = UIApplication.shared.keyWindow
    let backgroundView: UIView? = window?.viewWithTag(12345)
    let activityIndicatorView = window?.viewWithTag(123456) as? DGActivityIndicatorView
    activityIndicatorView?.stopAnimating()
    backgroundView?.removeFromSuperview()
}

func playDeleteSound(){
    
    var filePath = Bundle.main.path(forResource: "delete", ofType: "wav")
    var fileUrl = URL(string: filePath ?? "")
    var soundID = SystemSoundID(0)
    AudioServicesCreateSystemSoundID(fileUrl as! CFURL, &soundID)
    AudioServicesPlaySystemSound(soundID)

}
