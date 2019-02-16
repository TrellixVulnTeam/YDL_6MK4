//
//  MediaPlayerVC.swift
//  YDL
//
//  Created by ceonfai on 2019/1/28.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class MediaPlayerVC: UIViewController,MediaPlayerManagerDelegate,TouchControlViewDelegate {

    var mediaControl:MediaControl?
    var playerManager:MediaPlayerManager?
    var mediaSelector:MediaSelector?
    
    //gesture
    var startPoint:CGPoint?
    var endPoint:CGPoint?
    var startVB:CGFloat?//起始的音量或亮度
    var direction:Direction?
    var currentRate:NSInteger = 0
    var vStartSeekTime:NSInteger?
    var vSeekTime:NSInteger?
    var vDuration:NSInteger?
    var maxRewin:NSInteger?
    var maxFast:NSInteger?

    override func viewDidLoad() {
        super.viewDidLoad()
        mediaControl = MediaControl.init(frame: self.view.frame)
        self.view.addSubview(mediaControl!)
        setupControlEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.beginSupportLanscape()
    }
    
    func setupPlayer(playQueue:NSArray,playIndex:Int) -> Void {
        
        playerManager = MediaPlayerManager.shared
        playerManager?.mDelegate = self
        playerManager?.playQueue = playQueue
        playerManager?.playingIndex = playIndex
        playerManager?.playMedia(playModel: playQueue.object(at: playIndex) as! DownloadModel)
        mediaControl?.showAndFade()
    }
    
    func setupControlEvents() -> Void {
        
        
        self.mediaControl?.doneBtn?.addTarget(self, action: #selector(onClickDone), for: UIControl.Event.touchUpInside)
        self.mediaControl?.playButton?.addTarget(self, action: #selector(onClickPlay), for: UIControl.Event.touchUpInside)
        self.mediaControl?.nextButton?.addTarget(self, action: #selector(onClickNext), for: UIControl.Event.touchUpInside)
        self.mediaControl?.listButton?.addTarget(self, action: #selector(onClickList), for: UIControl.Event.touchUpInside)
        
        self.mediaControl?.seekSlider?.addTarget(self, action: #selector(didSliderValueChanged), for: .valueChanged)
        self.mediaControl?.seekSlider?.addTarget(self, action: #selector(didSliderTouchDown), for: .touchDown)
        self.mediaControl?.seekSlider?.addTarget(self, action: #selector(didSliderTouchCancel), for: .touchCancel)
        self.mediaControl?.seekSlider?.addTarget(self, action: #selector(didSliderTouchUpInside), for: .touchUpInside)
        self.mediaControl?.seekSlider?.addTarget(self, action: #selector(didSliderTouchUpOutside), for: .touchUpOutside)
        
        //touch Action
        self.mediaControl?.touchView?.touchDelegate = self
        
        //sysVolume Change
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged), name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)

    }
    
    @objc func volumeChanged(_ notification: Notification?) {
        
        let volume: Float = (notification?.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? NSNumber)?.floatValue ?? 0.0
         self.mediaControl?.volumeSlider?.value = volume
        print("FlyElephant-系统音量:\(volume)")
        
    }
    
   
    //mark -envents
    @objc func onClickDone()->Void{
        showHUD(type: DGActivityIndicatorAnimationType.ballBeat)
        self.playerManager?.stop(whenClose: {
           
            DispatchQueue.main.async {
                 endHUD()
                 self.endSupportLanscape()
                 self.dismiss(animated: true, completion: nil)
                
            }
        })
    }
    
    @objc func didSliderTouchDown()->Void{
        
        self.mediaControl?.beginDragMediaSlider()
    }
    
    @objc func didSliderTouchCancel()->Void{
        
        self.mediaControl?.endDragMediaSlider()
    }
    
    @objc func didSliderValueChanged()->Void{
        
        self.mediaControl?.continueDragMediaSlider()
    }
   
    @objc func didSliderTouchUpInside()->Void{
        
        self.playerManager?.player!.currentPlaybackTime = Double((mediaControl!.seekSlider?.value)!)
        mediaControl!.endDragMediaSlider()
    }
  
    @objc func didSliderTouchUpOutside()->Void{
        
        self.mediaControl?.endDragMediaSlider()
    }
    
    @objc func onClickPlay(sender:UIButton) -> Void {
        if(self.mediaControl?.playButton?.isSelected == true){
            self.playerManager?.pause()
        }else{
            self.playerManager?.play()
        }
        self.mediaControl?.playButton?.isSelected = !(self.mediaControl?.playButton?.isSelected)!
        
    }
    
    @objc func onClickNext(sender:UIButton) -> Void {
        self.playerManager?.next()
    }
    
    @objc func onClickList(sender:UIButton) -> Void {
        
        self.mediaControl?.hidePanel()
        mediaSelector = MediaSelector.init(frame: self.view.bounds)
        mediaSelector?.showSelector()
        mediaSelector?.selectorBlock = ({ [weak self] (index: Int) -> Void in
            
            let playModel = DownloadManager.shared.downloadeds?[index] as! DownloadModel
            if(playModel != self?.playerManager?.playingModel){
                self?.mediaSelector?.hideSelector()
                self?.playerManager?.playMedia(playModel: playModel )
            }
        })
        
    }
    
    func touchesBegan(with point: CGPoint) {
        self.startPoint = point
        //Direction
        if((self.startPoint?.x)! <= (self.mediaControl?.touchView?.bounds.size.width)!/2){
            self.startVB = CGFloat(UIScreen.main.brightness)
        }else{
            self.startVB = CGFloat(AVAudioSession.sharedInstance().outputVolume)
        }
        //默认无方向
        self.direction = Direction.none
        self.currentRate = 0
        self.vStartSeekTime = Int(self.playerManager!.player!.currentPlaybackTime)
        self.vDuration = Int(self.playerManager!.player!.duration)
        
        //最大快退偏移
        self.maxRewin = self.vStartSeekTime;
        
        //最大快进偏移
        self.maxFast = -(Int(self.vDuration!) - Int(self.maxRewin!))
        
        print("touch Began")
    }
    

    func touchesCancel(){
        self.mediaControl?.seekView?.isHidden = true
        print("touch Cancel")
    }
    
    func touchesEnd(with point: CGPoint) {
        
        if self.direction == Direction.left || self.direction == Direction.right {
            
            if (self.playerManager!.player!.isPlaying() == true) {
                self.playerManager!.player!.currentPlaybackTime = TimeInterval(self.vSeekTime!)
                self.mediaControl?.seekView?.isHidden = true
            }
        }
        //mediaControl.seekView.hidden = true
        self.endPoint = CGPoint.zero
        
         print("touch End")
    }
    
    func touchesMove(with point: CGPoint) {
        let panPoint = CGPoint.init(x: point.x - self.startPoint!.x, y: point.y - self.startPoint!.y)
        if self.direction == Direction.none {
            
            if panPoint.x >= 30 {
                //进度
                direction = Direction.right
            } else if panPoint.x <= -30 {
                direction = Direction.left
            } else if panPoint.y >= 30 || panPoint.y <= -30 {
                //音量和亮度
                direction = Direction.upOrDown
            }
        }
        
        if self.direction == Direction.right || self.direction == Direction.left {
            
            if self.endPoint!.x > panPoint.x {
                direction = Direction.left
            } else {
                direction = Direction.right
            }
        }
        self.endPoint = panPoint
        
        if (self.direction == Direction.none) {
            return
        }
        else if (self.direction == Direction.upOrDown) {
            
            if self.startPoint!.x <= (self.mediaControl?.touchView?.frame.size.width ?? 0.0) / 2.0 {
                //调节亮度
                if panPoint.y < 0 {
                    //增加亮度
                    UIScreen.main.brightness = self.startVB! + (-panPoint.y / 30.0 / 10)
                } else {
                    //减少亮度
                    UIScreen.main.brightness = startVB! - (panPoint.y / 30.0 / 10)
                }
               
            }else{
                //音量
                if panPoint.y < 0 {
                    //增大音量
                    let volumValue: Float = Float(self.startVB! + (-panPoint.y / 30.0 / 10))
                    if(volumValue > Float(0.1)){
                        self.mediaControl?.volumeSlider?.setValue(volumValue, animated: true)
                        self.mediaControl?.volumeSlider!.setValue(Float(startVB! + (-panPoint.y / 30.0 / 10)), animated: true)
                    }
                   
                } else {
                    //减少音量
                    self.mediaControl?.volumeSlider?.setValue(Float(startVB! - (panPoint.y / 30.0 / 10)), animated: true)
                }
    
            }
            
        }
        else if self.direction == Direction.left || self.direction == Direction.right {
            
            let rate: NSInteger = (direction == Direction.left) ? -3 : 3
            
            self.vSeekTime = self.vStartSeekTime! + self.currentRate
            
            let startSeek:NSInteger = self.vStartSeekTime!
            let videoDuration:NSInteger = self.vDuration!
            let seek:NSInteger = self.vSeekTime!
            
            if (self.direction == Direction.right) {
                self.currentRate = startSeek > videoDuration ?self.currentRate:self.currentRate + rate
            } else {
                self.currentRate = startSeek - (self.currentRate) <= 0 ? self.currentRate:(self.currentRate + rate)
            }
            
            //var jumpOffset = formatTimeInterval(seconds: currentRate)
            
            //大于起始时间
//            if (startSeek < seek) {
//                
//                mediaControl.seekView.offsetLabel.textColor = UIColor.green
//                mediaControl.seekView.offsetLabel.text = "+\(jumpOffset)"
//            } else {
//                
////                mediaControl.seekView.offsetLabel.textColor = UIColor.red
////                mediaControl.seekView.offsetLabel.text = "-\(jumpOffset)"
//            }
            self.mediaControl?.seekView?.isHidden = false
            let jumpTime = formatTimeInterval(seconds: (seek > videoDuration ?self.vDuration:seek)!)
            let duration = formatTimeInterval(seconds: videoDuration)
            let seekText = jumpTime + "/" + duration
            let isRewin  = startSeek > seek ?true:false
            
            self.mediaControl?.seekView?.updateSeekInfo(text: seekText, isRewin: isRewin)
    
        }

        print("touch Move")
    }
    
    func didTapControlView() {
        if(mediaControl?.topPanel?.isHidden == true){
            mediaControl?.showAndFade()
        }
        else{
            mediaControl?.hidePanel()
        }
    }
    
    func didDoubleTapControlView() {
        if(self.playerManager?.player?.view.contentMode == .scaleAspectFill){
            self.playerManager?.player?.view.contentMode = .scaleAspectFit
            return
        }
        self.playerManager?.player?.view.contentMode = .scaleAspectFill
        
        UIView.animate(withDuration: 0.3) {
             self.view.layoutIfNeeded()
        }
    }
    
    
    func beginSupportLanscape() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.allowRotation = true
        
        let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.landscapeRight.rawValue)
        UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
        
        let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.landscapeRight.rawValue)
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
    }
    
    
    // MARK: - 恢复仅支持单向竖屏 并强制pop/dismiss后竖屏出现
    func endSupportLanscape() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.allowRotation = false
        let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue)
        UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
        
        let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue)
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
        
    }
    
    

    func selectSubtitle(withParam param: [AnyHashable : Any]?) {
        
    }
    
    func change(_ state: MediaPlayerState) {
     
        switch state.rawValue {
        case MediaPlayerState.stoped.rawValue:
            self.playerManager?.next()
            break
        case MediaPlayerState.failed.rawValue:
            break
            
        default:
            break
        }
        
    }
    func displayMessage(_ message: String?) {
        
    }
    
    func mediaInfoChange() {
        DispatchQueue.main.async {
            self.mediaControl?.scrollTitle?.text = self.playerManager?.playingModel?.fileName
            self.mediaControl?.playButton?.isSelected = true
            if(self.mediaSelector != nil){
                self.mediaSelector?.refreshSelector()
            }
        }
    }
    
    func playViewReload() {
        playerManager!.player!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerManager!.player!.scalingMode = IJKMPMovieScalingMode.aspectFit
        playerManager!.player!.shouldAutoplay = true
        view.autoresizesSubviews = true
        playerManager!.player!.view.contentMode = .scaleAspectFit
        playerManager!.player!.view.frame = self.view.frame
        self.view.addSubview(playerManager!.player!.view)
        self.view.addSubview(mediaControl!)
        mediaControl?.player = playerManager!.player
        mediaControl?.refreshMediaControl()
       
    }
    
    func changePlayProgress(_ progress: Double, second: CGFloat) {
        
    }
    
    func changeLoadProgress(_ progress: Double, second: CGFloat) {
        
    }
    
    func didBuffer(_ playerMgr: MediaPlayerManager?) {
        
    }
    
    func playerReadyToPlay() {
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mediaControl?.frame = self.view.frame
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge{
        return .all
    }
}
