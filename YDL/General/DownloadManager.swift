//
//  DownloadManager.swift
//  YDL
//
//  Created by ceonfai on 2019/1/21.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit
import CoreData

class DownloadManager: NSObject {

    var downloadings:NSMutableArray?//正在下载队列
    var downloadeds:NSMutableArray?//已下载文件
    var downloadingModel:DownloadModel?
    var mediaTool:MediaTool = {
        return MediaTool.init()
    }()
    lazy var downloadManager = { () -> TRManager in
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.downloadManager
    }()
    lazy var dlContex:NSManagedObjectContext = {
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }()
    
    //单例
    class var shared: DownloadManager {
        struct Static {
            static let instance = DownloadManager()
        }
        return Static.instance
    }
    
    func prepareData() -> Void {
        
        //初始化
        self.downloadings = NSMutableArray()
        self.downloadeds  = NSMutableArray()
        //查找所有记录
        let allCaches = fetchAllData() as NSArray
        allCaches.enumerateObjects({ obj, idx, stop in
            let cache = allCaches[idx] as? DownloadModel
            if cache?.downloadState == DOWNLOAD_STATE.DOWNLOADED.rawValue {
//                let destination = MyDocumentsPath + "/" + (cache?.fileName)!
//                let fileURL = URL.init(fileURLWithPath: destination)
//                let size = calculateSize(sizeOfByte: NSInteger(getSize(url: fileURL)))
//                cache?.size = size
//                cache?.date = dateFormatter.string(from: Date.init())
//                cache?.resolution = "640 x 360"
//                self.saveDataRightNow()
                self.downloadeds!.insert(cache!, at: 0)
            } else {
                self.downloadings?.add(cache!)
            }
        })
    }
    
    func addVideoDL(menuModel:MenuModel) -> Void {
        
        let downloadModel = generateNewRecord(mModel: menuModel)
        //有进行中任务
        if(self.downloadingModel != nil){
            self.downloadings?.add(downloadModel)
            return
        }
        //无进行中任务
        self.downloadings?.add(downloadModel)
        resumeDL()
        
        //通知界面刷新
        NotificationCenter.default.post(name: NSNotification.Name("refreshQueue"), object: nil, userInfo: nil)
    }
    
    func pauseDownload() -> Void {
        TRManager.default.totalSuspend()
        self.downloadingModel = nil
    }
    
    func resumeDL() -> Void {
        
        if(self.downloadManager.tasks.count>0){
            if(self.downloadManager.status == .removed){
                self.downloadManager.totalStart()
            }
            return
        }
        
        if(self.downloadings?.count == 0){
            return
        }
        self.downloadingModel = (self.downloadings![0] as! DownloadModel)
        
        var dlLink:String?//下载链接
        var isAudio:Bool?//当前任务是否音频文件
        
        //dlPath = MyDocumentsPath + "/" + (self.downloadingModel?.fileName)!//文件最终位置
        
        //视频是否下载完成
        if(self.downloadingModel?.isVideoDownloaded == false){
            
            dlLink = self.downloadingModel?.videoURL
            isAudio = false

        }else{
            
            isAudio = true
            dlLink = self.downloadingModel?.audioURL
            //dlPath = MyDocumentsPath + (self.downloadingModel?.audioTempName)!
        }
        
        let task = TRManager.default.download(dlLink!)
        
        if(task!.status == .succeeded){
          self.downloadSuccess(task: task!, isAudio: isAudio!)
          return
        }
        
        if(task?.status == .suspended){
            task?.start()
        }
        
        task?.progress({ (task) in
           NotificationCenter.default.post(name: NSNotification.Name("DL_STATE"), object: task, userInfo: nil)
        }).success({ [weak self] (task) in
            
            self?.downloadSuccess(task: task, isAudio: isAudio!)
            
        }).failure({ (task) in
            print("下载失败")
        })
    }
    
    func downloadSuccess(task:TRTask,isAudio:Bool) -> Void {
        if(isAudio == true){
            self.downloadingModel?.audioTempName = task.fileName
            self.finishOneTask()
        }else{
            
            self.downloadingModel?.videoTempName = task.fileName
            if(self.downloadingModel?.isSplitter == true){
                self.downloadingModel?.isVideoDownloaded = true
                self.saveDataRightNow()
                self.resumeDL()
            }else{
                self.finishOneTask()
            }
        }
    }
    
    func finishOneTask() -> Void {
        
        let destination = MyDocumentsPath + "/" + (self.downloadingModel?.fileName)!
        let vTemp = tiercelPath + (self.downloadingModel?.videoTempName)!
        //如果视频和音频分离就进行合并 否则直接拷贝
        if(self.downloadingModel?.isSplitter == true){
            
            let aTemp = tiercelPath + (self.downloadingModel?.audioTempName)!
            self.mediaTool.mixVideo(vTemp, withAudio: aTemp, toPath: destination) { (isSuccess) in
                if(isSuccess == false){
                    return
                }
                self.updateMediaInfo(path: destination)
        }
            
        }else{
           try?FileManager.default.copyItem(atPath: vTemp, toPath: destination)
           self.updateMediaInfo(path: destination)
        }
        //remove downloaded cache
        downloadManager.cache.clearDiskCache()

    }
    
    func updateMediaInfo(path:String) -> Void {
        let mediaInfo = mediaTool.readVideoInfo(withPath: path) as NSDictionary
        self.downloadingModel?.size = (mediaInfo.value(forKey: "size") as! String)
        self.downloadingModel?.resolution = (mediaInfo.value(forKey: "resolution") as! String)
        self.downloadingModel?.duration = (mediaInfo.value(forKey: "duration") as! String)
        self.downloadingModel?.date = dateFormatter.string(from: Date.init())
        self.downloadingModel?.isVideoDownloaded = true
        self.downloadingModel?.downloadState = DOWNLOAD_STATE.DOWNLOADED.rawValue
        self.downloadingModel?.thmData = (mediaInfo.value(forKey: "thumbnail") as! NSData)
        self.saveDataRightNow()
        self.downloadeds?.insert(self.downloadingModel!, at: 0)
        self.downloadings?.remove(self.downloadingModel!)
        self.downloadingModel = nil;
        self.resumeDL()
        //通知界面刷新
        NotificationCenter.default.post(name: NSNotification.Name("refreshQueue"), object: nil, userInfo: nil)
    }
    
    func generateNewRecord(mModel:MenuModel) -> DownloadModel {
        
        let dlModel = NSEntityDescription.insertNewObject(forEntityName: "DownloadModel", into: self.dlContex)as! DownloadModel
        dlModel.configDownloadModel(menuModel: mModel)
        self.saveDataRightNow()
        return dlModel
    }
    
    func fetchAllData() -> NSArray {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "DownloadModel")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let error: Error? = nil
        let downloadData = try? self.dlContex.fetch(fetchRequest) as NSArray
        if error != nil {
            print(error as Any)
        }
        return downloadData!
    }
    
    func saveDataRightNow() -> Void {
        do {
            try self.dlContex.save()
            print("Successful")
        }catch let error{
            print("context can't save!, Error:\(error)")
        }
    }
}
