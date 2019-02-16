//
//  DownloadModel+CoreDataProperties.swift
//  YDL
//
//  Created by ceonfai on 2019/1/7.
//  Copyright © 2019 Ceonfai. All rights reserved.
//
//

import Foundation
import CoreData


extension DownloadModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadModel> {
        return NSFetchRequest<DownloadModel>(entityName: "DownloadModel")
    }
    @NSManaged public var fileName: String?//文件显示的名称,也是沙盒文件的名称
    @NSManaged public var audioTempName: String?//缓存音频轨时,文件的名称
    @NSManaged public var videoTempName: String?//缓存视频轨时,文件的名称
    @NSManaged public var videoURL: String?//视频轨的下载链接
    @NSManaged public var audioURL: String?//音频轨的下载链接
    @NSManaged public var thmURL: String?//缩略图的下载链接
    @NSManaged public var webURL: String?//从哪个链接解释到的视频
    @NSManaged public var date: String?//文件下载日期
    @NSManaged public var duration: String?//文件时长
    @NSManaged public var size: String?//文件大小
    @NSManaged public var resolution: String?//文件分辨率
    @NSManaged public var extention: String?//文件扩展名
    @NSManaged public var thmData: NSData?//视频缩略图二进制
    @NSManaged public var isSplitter: Bool//是否音视频单独下载并合并
    @NSManaged public var downloadState: Int32//记录文件的下载状态
    @NSManaged public var progress: String?//文件下载进度--/--
    @NSManaged public var progressPercent: Float//文件喜爱杂比例 百分比
    @NSManaged public var isVideoDownloaded: Bool//判断当前视频是否下载完成,是->下载音频,否->下载视频

    func configDownloadModel(menuModel:MenuModel) -> Void {
    
        thmURL   = menuModel.mTHMURL
        fileName = menuModel.mTitle
        videoURL = menuModel.mVURL
        audioURL = menuModel.mAURL
        webURL   = menuModel.mWebURL
        duration = menuModel.mDuration
        size = menuModel.mSize
        resolution = menuModel.mResolution
        extention = menuModel.mExtention
        isSplitter = menuModel.isSpilter
        downloadState = DOWNLOAD_STATE.DOWNLOADING.rawValue
        isVideoDownloaded = false
    }
}
