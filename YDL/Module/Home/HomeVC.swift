//
//  ZHomeVC.swift
//  YDL
//
//  Created by ceonfai on 2018/12/26.
//  Copyright © 2018 Ceonfai. All rights reserved.
//

import UIKit
import Photos

class HomeVC: UIViewController,BrowserVCDelegate,PopMenuViewControllerDelegate {

    var homeView:HomeView?
    var navLabel:UILabel?
    var leftItem:UIBarButtonItem?
    var rightItem:UIBarButtonItem?
    var optionIndices:NSMutableIndexSet?
    var popMenu:PopMenuViewController?
    var actionModel:DownloadModel?
    var docShare:UIDocumentInteractionController?
    
    //导航栏图片
    let sideBarIcon  = FontIcon(withIcon: "\u{e64c}", size: 50, color: .white)//菜单
    let settingIcon  = FontIcon(withIcon: "\u{eb69}", size: 40, color: .white)//设置
    let selectIcon   = FontIcon(withIcon: "\u{e631}", size: 40, color: .white)//选中
    let unselectIcon = FontIcon(withIcon: "\u{eb2a}", size: 40, color: .white)//未选中
    let cancelIcon   = FontIcon(withIcon: "\u{e627}", size: 40, color: .white)//未选中
    
    //侧边菜单图片
    let youtubeIcon      = FontIcon(withIcon: "\u{e613}", size: 100, color: .white)//菜单
    let viemoIcon        = FontIcon(withIcon: "\u{e64b}", size: 100, color: .white)//菜单
    let dailyMotionIcon  = FontIcon(withIcon: "\u{e687}", size: 100, color: .white)//菜单
    let customIcon       = FontIcon(withIcon: "\u{e609}", size: 100, color: .white)//菜单
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.homeView?.refreshTransmissHeaderState()
        self.homeView?.homeTable?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createHomeView()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshQueue), name: NSNotification.Name(rawValue:"refreshQueue"), object: nil)
        
        prepareEnv()
    }
    
    func prepareEnv() -> Void {
        showHUD(type: DGActivityIndicatorAnimationType.ballBeat)
        DispatchQueue.global(qos: .default).async {
           
            if(!PythonManager.shared().isInit){
                PythonManager.shared().configPythonEnv()
                PythonManager.shared().loadPythonModule()
            }
            DispatchQueue.main.async {
                endHUD()
            }
        }
    }
    
    func createHomeView() -> Void {
        //导航栏
        self.title = Localized(enKey: "Downloaded")
        leftItem = UIBarButtonItem.init(image: sideBarIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(onClickLeftItem))
        rightItem = UIBarButtonItem.init(image: settingIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(onClickRightItem))
        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = rightItem
        //文件列表
        homeView = HomeView.init(frame: self.view.frame)
        self.view.addSubview(homeView!)
        
        homeView?.fileClickCallBack = ({ [weak self] (index: Int) -> Void in
        
            let mediaVC = MediaPlayerVC()
            mediaVC.setupPlayer(playQueue: DownloadManager.shared.downloadeds!, playIndex: index)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.allowRotation = true
            mediaVC.beginSupportLanscape()
            self!.present(mediaVC, animated:true, completion: nil)
        })
        
        homeView?.fileDeleteCallBack = ({ [weak self] (index: Int) -> Void in
            
          let deleteModel = DownloadManager.shared.downloadeds![index] as! DownloadModel
          //cache
          let realFilePath = MyDocumentsPath + "/" + (deleteModel.fileName)!
          try?FileManager.default.removeItem(atPath: realFilePath)
          //coredata remove
          DownloadManager.shared.downloadeds?.remove(deleteModel)
          DownloadManager.shared.dlContex.delete(deleteModel)
          DownloadManager.shared.saveDataRightNow()
          //updateUI
          let indexPath = IndexPath.init(item: index, section: 0)
          self?.homeView?.homeTable?.deleteRows(at: [indexPath], with: .bottom)
          playDeleteSound()
          DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute:
          {
            self?.homeView?.homeTable?.reloadData()
          })
        })
        
        homeView?.fileTransmissionCallBack = ({ [weak self] (index: Int) -> Void in
            let downloadVc = DownloadVC()
            self?.navigationController?.pushViewController(downloadVc, animated: true)
        })
        
        homeView?.fileMoreActionCallBack = ({ [weak self] (index: Int) -> Void in
            self!.actionModel = (DownloadManager.shared.downloadeds![index] as! DownloadModel)
            let actions = [
                PopMenuDefaultAction(title: Localized(enKey: "Save to Album")),
                PopMenuDefaultAction(title: Localized(enKey: "Share Video")),
                PopMenuDefaultAction(title: Localized(enKey: "Share Audio"))
            ]
            self!.popMenu = PopMenuViewController(actions: actions)
            self!.popMenu?.delegate = self
            self!.present(self!.popMenu!, animated: true, completion: nil)
        })

    }
    
    func editAction() -> Void {
        
    }
    
    func noEditAction() -> Void {
        
    }
    
    @objc func onClickLeftItem() -> Void {
        if (self.homeView?.isInEdit == true) {
            
        }
        else{
            OpenBrowser()
        }
    }
    
     @objc func onClickRightItem() -> Void {
        if (self.homeView?.isInEdit == true) {
            self.homeView?.isInEdit = false
            refreshNavigationBar()
        }
        else{
            let settingVc = SettingVC.init()
            settingVc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingVc, animated: true)
        }
    }
    
    @objc func refreshNavigationBar() -> Void {
        if(homeView?.isInEdit == true){

            let selectedCount = self.homeView?.editData?.count.description
            let allCount = DownloadManager.shared.downloadeds?.count.description
            let isAll    = (selectedCount == allCount)

            //self.baseView.toolbar.deleteBtn.enabled = self.baseView.editData.count>0?YES:NO;
             self.title = Localized(enKey: "Downloaded")
            //导航栏左侧
            leftItem?.image = isAll ?self.selectIcon:self.unselectIcon
            rightItem?.image = self.cancelIcon

        }else{

            self.title = Localized(enKey: "Downloaded")

            leftItem?.image = self.sideBarIcon
            rightItem?.image = self.settingIcon
        }
    }
    
    func OpenBrowser() -> Void {
        let webVC = BrowserVC()
        webVC.loadURLWithString(SUPORTURL.Youtube.rawValue)
        webVC.toolbar.toolbarTintColor = UIColor.darkGray
        webVC.toolbar.toolbarBackgroundColor = UIColor.white
        webVC.toolbar.toolbarTranslucent = false
        webVC.allowsBackForwardNavigationGestures = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            webVC.showToolbar(true, animated: true)
        })
        webVC.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.pushViewController(webVC, animated: true)

    }
    
    @objc func refreshQueue() -> Void {
        self.homeView?.refreshTransmissHeaderState()
        self.homeView?.homeTable?.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    public func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        
        switch index {
        case 0:
          self.permissions()
            break
        case 1:
          self.sharVideo()
            break
        case 2:
            self.shareAudio()
            break
            
        default:
           break
        }

    }
    
    func sharVideo()->Void{
        
        let destination = MyDocumentsPath + "/" + (actionModel!.fileName)!
        let videoPath = URL(fileURLWithPath: destination)
        docShare = UIDocumentInteractionController(url: videoPath)
        docShare!.presentOpenInMenu(from: CGRect.zero, in: view, animated: true)

    }

    func shareAudio()->Void{
        
        //only supports mp4/3gp
        if(actionModel?.extention?.caseInsensitiveCompare("mp4").rawValue != 0 && actionModel?.extention?.caseInsensitiveCompare("3gp").rawValue != 0){
            YDLHUD.showError(text: Localized(enKey: "only support MP4/3GP"), delay: 1.5)
            return
        }
        
        let destination = MyDocumentsPath + "/" + (actionModel!.fileName)!
        let videoPath = URL(fileURLWithPath: destination)
        
        let finalName = videoPath.deletingPathExtension().lastPathComponent + ".aac"
        let exportFolder = MyTempPath + ("ShareAudio/")
        let exportPath = exportFolder + (finalName)
        
        //检查输出目录
        let manager = FileManager.default
        if !manager.fileExists(atPath: exportFolder) {
            try? manager.createDirectory(atPath: exportFolder, withIntermediateDirectories: false, attributes: nil)
        }
        
        let mediaTool = MediaTool()
        showHUD(type: .ballSpinFadeLoader)
        mediaTool.separateAudio(fromVideo: destination, toPath: exportPath) { (isSuccess) in
            endHUD()
            if(isSuccess == true){
                DispatchQueue.main.async {
                    self.docShare = UIDocumentInteractionController(url:URL.init(fileURLWithPath: exportPath))
                    self.docShare!.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                }
            }
            else{
                YDLHUD.showError(text: Localized(enKey: "Uncaught Errors"), delay: 1.5)
            }
        }

    }
    
    func saveVideoToCameraRoll()->Void{
        //only supports mp4/3gp
        if(actionModel?.extention?.caseInsensitiveCompare("mp4").rawValue != 0 && actionModel?.extention?.caseInsensitiveCompare("3gp").rawValue != 0){
            YDLHUD.showError(text: Localized(enKey: "only support MP4/3GP"), delay: 1.5)
            return
        }
        let destination = MyDocumentsPath + "/" + (actionModel!.fileName)!
        let url = URL.init(fileURLWithPath: destination)
       
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (boo, error) in
           
            DispatchQueue.main.async {
                if((error) != nil){
                    YDLHUD.showError(text:Localized(enKey:  "Fail"), delay: 1.5)
                }else{
                    YDLHUD.showSuccess(text: Localized(enKey: "Success"), delay: 1.5)
                }
            }
    }

        
    }
    
    ///有没有pn写入s权限判断
    private func permissions(_ int:Int = 0){
        
        if PHPhotoLibrary.authorizationStatus().rawValue == PHAuthorizationStatus.notDetermined.rawValue {
            ///用户还没做选择
            PHPhotoLibrary.requestAuthorization({ (status) in
                
                if status.rawValue == PHAuthorizationStatus.authorized.rawValue {
                    //print("点同意")
                    self.saveVideoToCameraRoll()
                } else if status == PHAuthorizationStatus.denied ||  status == PHAuthorizationStatus.restricted {
                    //print("点拒绝")
                    self.jumpSet(str: "相册")
                }
                
            })
        } else if(PHPhotoLibrary.authorizationStatus().rawValue == PHAuthorizationStatus.authorized.rawValue ) {
            //用户同意写入权限
            print(PHPhotoLibrary.authorizationStatus().rawValue)
            self.saveVideoToCameraRoll()
        }else{
            self.jumpSet(str: "相册")
        }
    }
    
    ///跳转到设置中开启权限
    private func jumpSet(str:String){
       
        let settingUrl = URL(string: UIApplication.openSettingsURLString)!
        //print(UIApplication.shared.canOpenURL(settingUrl))
        if UIApplication.shared.canOpenURL(settingUrl)
        {
             UIApplication.shared.openURL(settingUrl)
        }
        
    }

}
