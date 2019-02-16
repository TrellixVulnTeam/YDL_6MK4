//
//  MediaPlayerManager.swift
//  YDL
//
//  Created by ceonfai on 2019/1/28.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit
import AVFoundation

enum MediaPlayerState : Int {
    case unknow // 未初始化的
    case failed // 播放失败（无网络，视频地址错误）
    case readyToPlay // 可以播放了
    case buffering // 缓冲中
    case playing // 播放中
    case pause // 暂停播放
    case stoped // 播放已停止（需要重新初始化）
}

protocol MediaPlayerManagerDelegate: NSObjectProtocol {
    //* 视频状态改变时
    func selectSubtitle(withParam param: [AnyHashable : Any]?) //选择字幕
    func change(_ state: MediaPlayerState) //播放器状态
    func displayMessage(_ message: String?) //一些信息提示需要返回主界面显示
    func mediaInfoChange() //更新播放器界面的信息如时长,标题
    func playViewReload() //更新playerView重新初始化了播放器
    //* 播放进度改变时 @progress:范围：0 ~ 1 @second: 原秒数
    func changePlayProgress(_ progress: Double, second: CGFloat)
    //* 缓冲进度改变时 @progress范围：0 ~ 1 @second: 原秒数
    func changeLoadProgress(_ progress: Double, second: CGFloat)
    //* 当缓冲到可以再次播放时
    func didBuffer(_ playerMgr: MediaPlayerManager?)
    //* 播放器准备开始播放时
    func playerReadyToPlay()
}

class LMPlayerStatusModel: NSObject {
    //* 是否自动播放
    var autoPlay = false
    //* 是否被用户暂停
    var pauseByUser = false
    //* 播放完了
    var playDidEnd = false
    //* 进入后台
    var didEnterBackground = false
    //* 是否正在拖拽进度条
    var dragged = false
    // ------------我是分割线-------------
    
    //* 是否全屏
    var fullScreen = false
    
    // ------------我是分割线-------------
    
    /**
     重置状态模型属性
     */
    func playerResetStatusModel() {
        autoPlay = false
        playDidEnd = false
        dragged = false
        didEnterBackground = false
        pauseByUser = true
        fullScreen = false
    }

}


class MediaPlayerManager: NSObject {

    var initReadyToPlay = false
    var seekTime: Int = 0
    var playState:MediaPlayerState?
    var playingModel:DownloadModel?
    var playingIndex:NSInteger?
    var playQueue:NSArray?
    var player: IJKMediaPlayback?
    var playerStatusModel: LMPlayerStatusModel?
    var delegate:MediaPlayerManagerDelegate?
    var closing:Bool?
    
    weak var mDelegate: MediaPlayerManagerDelegate?
    
    class var shared: MediaPlayerManager {
        struct Static {
            static let instance = MediaPlayerManager()
        }
        return Static.instance
    }
    
    func playMedia(playModel:DownloadModel) -> Void {
        
        if (self.player != nil){
            self.player?.shutdown()
            self.removeNotification()
        }
        #if DEBUG
        IJKFFMoviePlayerController.setLogReport(true)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_DEBUG)
        #else
        IJKFFMoviePlayerController.setLogReport(false)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_INFO)
        #endif
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(true)
        
        self.player?.view.removeFromSuperview()
        self.playingIndex = self.playQueue?.index(of: playModel)
        self.playingModel = playModel;
        
        if((self.mDelegate) != nil){
            self.mDelegate?.mediaInfoChange()
        }
        
        //初始化底层数据读写/设置断点
        let options = IJKFFOptions.byDefault()
        options!.setPlayerOptionIntValue(1, forKey: "subtitle")
        let playPath = MyDocumentsPath + "/" + playModel.fileName!
        self.player = IJKFFMoviePlayerController(contentURL: URL(fileURLWithPath: playPath), with: options)
        self.player!.prepareToPlay()
        
        if((self.mDelegate) != nil){
            self.mDelegate!.playViewReload()
        }
        
        self.player?.setPauseInBackground(false)
        self.registNotification()

    }
    
    func play() -> Void {
        self.player?.play()
    }
    
    func pause() -> Void {
        self.player?.pause()
    }
    
    func next() -> Void {
        
        let currentIndex: Int = self.playingIndex!
        var nextIndex = currentIndex + 1
        if nextIndex > self.playQueue!.count - 1 {
            nextIndex = 0
        }
        let playModel = self.playQueue?.object(at: nextIndex)
        self.playMedia(playModel: playModel as! DownloadModel)
    }
    
    func stop(whenClose finish: @escaping () -> ()) {
        
        self.closing = true
        DispatchQueue.global(qos: .default).async(execute: {
            
            self.player!.shutdown()
            //通知主线程刷新
            DispatchQueue.main.async(execute: {
                self.closing = false
                //if finish
                finish()
                self.removeNotification()
            })
        })
    }

    
    func displayMessage(displayText: String?)->Void {
        
        if((self.mDelegate) != nil){
            self.mDelegate!.displayMessage(displayText)
        }
    }
    
    func setPlayState(state:MediaPlayerState) -> Void {
        self.playState = state
        if(self.mDelegate != nil){
            self.mDelegate?.change(state)
        }
    }
    
    @objc func loadStateDidChange(notify:NSNotification)->Void{
        let loadState = self.player?.loadState
        if (loadState!.rawValue != 0  && Int(IJKMPMovieLoadState.playthroughOK.rawValue) != 0)  {
            // 加载完成，即将播放，停止加载的动画，并将其移除
            print("加载完成, 自动播放了 LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: \(Int(Float(loadState!.rawValue)))\n")
            
            self.setPlayState(state: MediaPlayerState.readyToPlay)
            
            if !self.initReadyToPlay {
                self.initReadyToPlay = true
                if((self.mDelegate) != nil){
                    self.mDelegate!.playerReadyToPlay()
                }
                
                if self.seekTime != 0 {
                    self.player!.currentPlaybackTime = TimeInterval(seekTime)
                    seekTime = 0 // 滞空, 防止下次播放出错
                    self.player!.play()
                }
            }
        }
        else if (loadState!.rawValue != 0 && IJKMPMovieLoadState.stalled.rawValue != 0)  {
            // 可能由于网速不好等因素导致了暂停，重新添加加载的动画
            
            print("自动暂停了，loadStateDidChange: IJKMPMovieLoadStateStalled: \(Int(Float(loadState!.rawValue)))\n")
            self.playState = MediaPlayerState.buffering
            // 当缓冲好的时候可能达到继续播放时
            //[self.mDelegate didBuffer:self];
        } else if (loadState?.rawValue != 0  && IJKMPMovieLoadState.playable.rawValue != 0 ) {
            print("loadStateDidChange: IJKMPMovieLoadStatePlayable: \(Int(Float(loadState!.rawValue)))\n")
        } else {
            print("loadStateDidChange: \(Int(Float(loadState!.rawValue)))\n")
        }


    }
    
    @objc func moviePlayBackFinish(notify:NSNotification)->Void{
         let key = IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey as String
        let reason: Int = (notify.userInfo![key] as? NSNumber)?.intValue ?? 0
        switch reason {
        case Int(Float(IJKMPMovieFinishReason.playbackEnded.rawValue)):
            print("playbackStateDidChange: 播放完毕: \(reason)\n")
            self.setPlayState(state: MediaPlayerState.stoped)
             //self.playerStatusModel!.playDidEnd = true
//            if self.playerStatusModel!.dragged == true {
//                // 如果不是拖拽中，直接结束播放
//                self.playerStatusModel!.playDidEnd = true
//            }
        case Int(Float(IJKMPMovieFinishReason.userExited.rawValue)):
            print("playbackStateDidChange: 用户退出播放: \(reason)\n")
        case Int(Float(IJKMPMovieFinishReason.playbackError.rawValue)):
            print("playbackStateDidChange: 播放出现错误: \(reason)\n")
            self.setPlayState(state: MediaPlayerState.failed)
        default:
            print("playbackPlayBackDidFinish: ???: \(reason)\n")
        }
    }
    
    @objc func mediaIsPrepared(notify:NSNotification)->Void{
        print("mediaIsPrepareToPlayDidChange\n")
    }
    
    @objc func moviePlayBackStateDidChange(notify:NSNotification)->Void{
        switch self.player?.playbackState.rawValue {
        case IJKMPMoviePlaybackState.stopped.rawValue:
            print("IJKMPMoviePlayBackStateDidChange \(player!.playbackState.rawValue): stoped")
            // 这里的回调也会来多次(一次播放完成, 会回调三次), 所以, 这里不设置
        //self.playState = IJKPlayerStateStoped;
        case IJKMPMoviePlaybackState.playing.rawValue:
            print("IJKMPMoviePlayBackStateDidChange \(player!.playbackState.rawValue): playing")
            playState = MediaPlayerState.playing
        case IJKMPMoviePlaybackState.paused.rawValue:
            print("IJKMPMoviePlayBackStateDidChange \(player!.playbackState.rawValue): paused")
            playState = MediaPlayerState.pause
        case IJKMPMoviePlaybackState.interrupted.rawValue:
            print("IJKMPMoviePlayBackStateDidChange \(player!.playbackState.rawValue): interrupted")
        case IJKMPMoviePlaybackState.seekingForward.rawValue, IJKMPMoviePlaybackState.seekingBackward.rawValue:
            print("IJKMPMoviePlayBackStateDidChange \(player!.playbackState.rawValue): seeking")
        case IJKMPMoviePlaybackState.seekingBackward.rawValue:
            print("IJKMPMoviePlayBackStateDidChange \(player!.playbackState.rawValue): seeking")
        default:
            print("IJKMPMoviePlayBackStateDidChange \(player!.playbackState.rawValue): unknown")
        }
    }

    @objc func handleInterruption(notify:NSNotification)->Void{
        
        print("中断/恢复通知")
    }

    
    func registNotification()->Void{
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackFinish), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPrepared), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
        //播放打断
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }
    
    func removeNotification()->Void{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
    }
}

