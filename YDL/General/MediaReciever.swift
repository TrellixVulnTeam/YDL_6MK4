//
//  MediaReciever.swift
//  YDL
//
//  Created by ceonfai on 2019/2/12.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class MediaReciever: NSObject {

    func didReceivedMedia(with url: URL) {
        
        let originPath = url.path
        let pathExtentions = url.pathExtension
        let fileName = url.lastPathComponent
        let toSavePath = MyDocumentsPath + "/" + fileName
        let saveContex = DownloadManager.shared.dlContex
        let mediaTool  = MediaTool()
        try? FileManager.default.removeItem(atPath: toSavePath)
        try? FileManager.default.moveItem(atPath: originPath, toPath: toSavePath)
        
        let mediaInfo:NSDictionary = mediaTool.readVideoInfo(withPath: toSavePath) as NSDictionary
    
        let dlModel = NSEntityDescription.insertNewObject(forEntityName: "DownloadModel", into: saveContex)as! DownloadModel
        dlModel.fileName = fileName
        dlModel.extention = pathExtentions
        dlModel.thmURL = "none"
        
        dlModel.size = (mediaInfo.value(forKey: "size") as! String)
        dlModel.resolution = (mediaInfo.value(forKey: "resolution") as! String)
        dlModel.duration = (mediaInfo.value(forKey: "duration") as! String)
        dlModel.date = dateFormatter.string(from: Date.init())
        dlModel.isVideoDownloaded = true
        dlModel.thmData = (mediaInfo.value(forKey: "thumbnail") as! NSData)
        dlModel.downloadState = DOWNLOAD_STATE.DOWNLOADED.rawValue
        DownloadManager.shared.downloadeds?.insert(dlModel, at: 0)
        //通知界面刷新
        NotificationCenter.default.post(name: NSNotification.Name("refreshQueue"), object: nil, userInfo: nil)
        
         YDLHUD.showSuccess(text: Localized(enKey: "success"), delay: 1.5)
    
           try saveContex.save()
           YDLHUD.showSuccess(text: Localized(enKey: "Success"), delay: 1.5)
           print("Successful")
    }
    


}
