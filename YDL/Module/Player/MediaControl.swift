//
//  MediaControl.swift
//  YDL
//
//  Created by ceonfai on 2019/1/28.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class MediaControl: UIView {

     var player: IJKMediaPlayback?
     var scrollTitle:EFAutoScrollLabel?
     var nextButton: UIButton?
     var playButton:UIButton?
     var listButton:UIButton?
     var lockButton:UIButton?
     var airButton:AirplayView?
     var screenBtn:UIButton?
     var doneBtn:UIButton?
     var totalDurationLabel: UILabel?
     var seekSlider: UISlider?
    
     var overlayPanel:UIView?
     var topPanel:UIView?
     var btmPanel:UIView?
     var touchView:MediaGestureView?
     var volumeSlider:UISlider?
     var volumeView = MPVolumeView()
     var seekView:MediaSeekView?
    
    var isMediaSliderBeingDragged = false
    var isGradientInit = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createVew()
    }
    
    @objc func refreshMediaControl() -> Void {

        let duration: TimeInterval = (self.player?.duration)!
        let intDuration = Int(duration)
        if intDuration > 0 {
            seekSlider!.maximumValue = Float(Int(duration))
            //totalDurationLabel!.text = formatTimeInterval(seconds: intDuration)
        } else {
            totalDurationLabel!.text = "--:--"
            seekSlider!.maximumValue = 1.0
        }
        
        
        // position
        var position: TimeInterval = 0.0
        if isMediaSliderBeingDragged {
            position = TimeInterval(seekSlider!.value)
        } else {
            position = self.player!.currentPlaybackTime
        }
        let intPosition = Int(position + 0.5)
        if intDuration > 0 {
            seekSlider!.value = Float(position)
        } else {
            seekSlider!.value = 0.0
        }
        totalDurationLabel!.text = formatTimeInterval(seconds: intPosition) + "/" + formatTimeInterval(seconds: intDuration)

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshMediaControl), object: nil)
        if !overlayPanel!.isHidden {
            perform(#selector(self.refreshMediaControl), with: nil, afterDelay: 0.5)
        }
    }
    
    func showNoFade() {
        
        if(self.topPanel?.isHidden == false){
            cancelDelayedHide()
            return
        }
        
        let duration = 0.5
        self.topPanel?.isHidden = false
        self.btmPanel?.isHidden = false
        UIView.animate(withDuration:duration, animations: {
            
            
            let topBaseHeight = 44
            let btmBaseHeight = 60
            let topLayoutForX = isBangDevice ?(topBaseHeight+20):topBaseHeight
            let btmLayoutForX = isBangDevice ?(btmBaseHeight+30):btmBaseHeight+20
            
            self.topPanel?.snp.remakeConstraints({ (make) in
                make.left.top.width.equalTo(self)
                make.height.equalTo(topLayoutForX);
            })
            
            self.btmPanel?.snp.remakeConstraints({ (make) in
                make.left.bottom.width.equalTo(self)
                make.height.equalTo(btmLayoutForX);
            })
            
            self.layoutIfNeeded()
            
        }) { (Bool) in
            
        }
        
        cancelDelayedHide()
        refreshMediaControl()
    }
    
    func showAndFade() {
        showNoFade()
        perform(#selector(self.hidePanel), with: nil, afterDelay: 7)
    }
    
    @objc func hidePanel() {
        
        UIView.animate(withDuration: 0.5, animations: {
            let topBaseHeight = 44
            let btmBaseHeight = 60
            let topLayoutForX = isBangDevice ?(topBaseHeight+20):topBaseHeight
            let btmLayoutForX = isBangDevice ?(btmBaseHeight+30):btmBaseHeight+20
            
            self.topPanel?.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(self.snp.top)
                make.left.width.equalTo(self)
                make.height.equalTo(topLayoutForX);
            })
            
            self.btmPanel?.snp.remakeConstraints({ (make) in
                make.top.equalTo(self.snp.bottom)
                make.left.width.equalTo(self)
                make.height.equalTo(btmLayoutForX);
            })
            self.layoutIfNeeded()
            
            
        }) { (Bool) in
            self.topPanel?.isHidden = true
            self.btmPanel?.isHidden = true
        }
        
        
        cancelDelayedHide()
    }

    func cancelDelayedHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hidePanel), object: nil)
    }

    
    func ViewWillAppear() -> Void {
        scrollTitle?.layoutIfNeeded()
    }
    
    func createVew() -> Void {
        
        overlayPanel = UIView()
        self.addSubview(overlayPanel!)
        
        touchView = MediaGestureView()
        self.overlayPanel?.addSubview(touchView!)
        
        
        topPanel = UIView()
        self.addSubview(topPanel!)
        
        btmPanel = UIView()
        self.addSubview(btmPanel!)
        
        //touchView
        touchView = MediaGestureView.init(frame: self.bounds)
        touchView?.autoresizingMask = UIView.AutoresizingMask(rawValue: AutoresizingMask.flexibleWidth.rawValue|AutoresizingMask.flexibleHeight.rawValue)
        touchView?.isUserInteractionEnabled = true
        self.overlayPanel?.addSubview(touchView!)
        
        
        playButton = UIButton()
        
        let playImage = FontIcon(withIcon: "\u{e65f}", size: 60, color: .white)
        let pauseImage = FontIcon(withIcon: "\u{e6a9}", size: 60, color: .white)
        playButton!.setImage(playImage, for: .normal)
        playButton!.setImage(pauseImage, for: .selected)
        self.btmPanel?.addSubview(playButton!)
        
        nextButton = UIButton()
        let nextImage = FontIcon(withIcon: "\u{e69d}", size: 60, color: .white)
        nextButton!.setImage(nextImage, for: .normal)
        nextButton?.isUserInteractionEnabled = true
        self.btmPanel?.addSubview(nextButton!)

        
        screenBtn = UIButton()
        self.topPanel?.addSubview(screenBtn!)
        
        airButton = AirplayView.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        self.btmPanel?.addSubview(airButton!)
        
        totalDurationLabel = UILabel()
        totalDurationLabel?.text = "--:--"
        totalDurationLabel?.font = UIFont.systemFont(ofSize: 13.0)
        totalDurationLabel?.textColor = .white
        totalDurationLabel?.textAlignment = NSTextAlignment.right
        self.btmPanel?.addSubview(totalDurationLabel!)
        
        seekSlider = UISlider()
        let sliderImage = FontIcon(withIcon: "\u{e65d}", size: 40, color: .white)
        seekSlider?.tintColor = RGBA(R: 10, G: 181, B: 198, A: 1.0)
        seekSlider?.setThumbImage(sliderImage, for: .normal)
        seekSlider?.maximumValue = 1
        self.btmPanel?.addSubview(seekSlider!)
        
        scrollTitle = EFAutoScrollLabel()
        scrollTitle?.text = "..."
        scrollTitle?.textColor = .white
        scrollTitle?.font = UIFont.systemFont(ofSize: 15)
        self.topPanel?.addSubview(scrollTitle!)
        
        listButton = UIButton()
        let listImage = FontIcon(withIcon: "\u{e6a1}", size: 40, color: .white)
        listButton?.setImage(listImage, for: .normal)
        self.topPanel?.addSubview(listButton!)
        
        doneBtn = UIButton()
        let doneImage = FontIcon(withIcon: "\u{e6ec}", size: 40, color: .white)
        doneBtn?.setImage(doneImage, for: .normal)
        doneBtn?.isUserInteractionEnabled = true
        self.topPanel?.addSubview(doneBtn!)
    
        volumeSlider = self.getSystemVolumSlider()
        
        self.seekView = MediaSeekView.init(frame: CGRect.init(x: 0, y: 0, width: 250, height: 150))
        seekView?.isHidden = true
        self.addSubview(seekView!)

        
        let margin = self.marginForLeftOrRight()
        
        overlayPanel?.snp.makeConstraints({ (make) in
           make.left.top.width.height.equalTo(self);
            
        })
        
        touchView?.snp.makeConstraints({ (make) in
            make.top.equalTo((topPanel?.snp.bottom)!)
            make.bottom.equalTo((btmPanel?.snp.top)!)
            make.left.right.equalTo(overlayPanel!)
        })
        
        let topBaseHeight = 44
        let btmBaseHeight = 60
        
        let topLayoutForX = isBangDevice ?(topBaseHeight+20):topBaseHeight
        let btmLayoutForX = isBangDevice ?(btmBaseHeight+30):btmBaseHeight+20
        
        
        topPanel?.snp.makeConstraints({ (make) in
            make.left.top.width.equalTo(self)
            make.height.equalTo(topLayoutForX);
        })
        
        btmPanel?.snp.makeConstraints({ (make) in
            make.left.bottom.width.equalTo(self)
            make.height.equalTo(btmLayoutForX);
        })
        
        doneBtn?.snp.makeConstraints({ (make) in
            make.bottom.equalTo((topPanel?.snp.bottom)!).offset(-8)
            make.left.equalTo((topPanel?.snp.left)!).offset(margin)
            make.width.height.equalTo(40)
        })
        
        listButton?.snp.makeConstraints({ (make) in
            make.bottom.equalTo((topPanel?.snp.bottom)!).offset(-8)
            make.right.equalTo((topPanel?.snp.right)!).offset(-(margin))
            make.width.height.equalTo(40)
        })
        
        scrollTitle?.snp.makeConstraints({ (make) in
            make.left.equalTo(doneBtn!.snp.right).offset(10);
            make.right.equalTo(listButton!.snp.left).offset(-10)
            make.top.equalTo((doneBtn?.snp.top)!).offset(5)
            make.height.equalTo(30)
        })
        
        airButton?.snp.makeConstraints({ (make) in
            make.top.equalTo((playButton?.snp.top)!)
            make.right.equalTo((btmPanel?.snp.right)!).offset(-(margin-10))
            make.width.height.equalTo(40)
        })
        
        seekSlider?.snp.makeConstraints({ (make) in
            make.left.equalTo(nextButton!.snp.right).offset(5);
            make.right.equalTo(airButton!.snp.left).offset(-5)
            make.top.equalTo(self.btmPanel!.snp.top).offset(8)
            make.height.equalTo(30)
        })
        
        totalDurationLabel?.snp.makeConstraints({ (make) in
            make.top.equalTo((seekSlider?.snp.bottom)!)
            make.right.equalTo((seekSlider?.snp.right)!)
            make.width.equalTo(110)
            make.height.equalTo(18)
        })
        
        playButton?.snp.makeConstraints({ (make) in
            make.left.equalTo((btmPanel?.snp.left)!).offset(self.marginForLeftOrRight())
            make.top.equalTo((btmPanel?.snp.top)!).offset(8)
            make.width.height.equalTo(40)
        })
        
        nextButton?.snp.makeConstraints({ (make) in
            make.left.equalTo(playButton!.snp.right).offset(8)
           make.top.equalTo((btmPanel?.snp.top)!).offset(8)
            make.width.height.equalTo(40)
        })
        
        seekView?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.width.height.equalTo(150)
        })
        
        self.layoutIfNeeded()
       
    }
    
    func marginForLeftOrRight() -> Int {
        let isPortraint = self.isPortraintApp()
        let margin = isBangDevice ? (isPortraint ? 20:45 ):10
        return margin
    }
    
    override func layoutSubviews() {
        let topBaseHeight = 44
        let btmBaseHeight = 60
        
        let topLayoutForX = isBangDevice ?(topBaseHeight+20):topBaseHeight+10
        let btmLayoutForX = isBangDevice ?(btmBaseHeight+10):btmBaseHeight
        
        topPanel?.snp.updateConstraints({ (make) in
            make.height.equalTo(topLayoutForX);
        })
        
        btmPanel?.snp.updateConstraints({ (make) in
          
            make.height.equalTo(btmLayoutForX);
        })

        playButton?.snp.updateConstraints({ (make) in
            
           make.left.equalTo(self.marginForLeftOrRight());
        })
        
        doneBtn?.snp.updateConstraints({ (make) in
            
            make.left.equalTo(self.marginForLeftOrRight());
        })
        
        listButton?.snp.updateConstraints({ (make) in
            make.right.equalTo(-(self.marginForLeftOrRight()));
        })
        
        airButton?.snp.updateConstraints({ (make) in
            make.right.equalTo(-(self.marginForLeftOrRight()));
        })
        
        seekView?.snp.updateConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        })
        
//        totalDurationLabel?.snp.updateConstraints({ (make) in
//            make.right.equalTo(-(self.marginForLeftOrRight()));
//        })
        
        if(self.isPortraintApp() == false && self.isGradientInit == false){
//            topPanel.colors = [UIColor.black, UIColor.clear]
//            topPanel.startPoint = CGPoint(x: 1, y: 0)
//            topPanel.endPoint = CGPoint(x: 1, y: 1)
//
//            btmPanel.colors = [UIColor.clear, UIColor.black]
//            btmPanel.startPoint = CGPoint(x: 1, y: 0)
//            btmPanel.endPoint = CGPoint(x: 1, y: 1)

            topPanel?.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.3)
            btmPanel?.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.3)
            
            self.isGradientInit = true
        }
    }
    
    func isPortraintApp() -> Bool {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let isPortraint = width < height ? true:false
        return isPortraint
    }
    
    func beginDragMediaSlider() {
        isMediaSliderBeingDragged = true
        showNoFade() //防止拖动过程中消失
    }

    func endDragMediaSlider() {
        isMediaSliderBeingDragged = false
        showAndFade() //拖动结束后自动消失
    }
    
    func continueDragMediaSlider() {
        refreshMediaControl()
        
    }

    //获取系统音量滑块
    
    private func getSystemVolumSlider() -> UISlider {
        
        volumeView = MPVolumeView()
        var volumViewSlider = UISlider()
        
        for subView in volumeView.subviews {
            //方法1
            if type(of: subView).description() == "MPVolumeSlider" {
                volumViewSlider = subView as! UISlider
                return volumViewSlider
                
            }
            /*方法2
             
             if subView.isKind(of: UISlider.self) {
             
             print("---\(object_getClassName(subView))---")//0x0000000196cb9a68
             
             print("---\(NSStringFromClass(type(of: subView)))---")//MPVolumeSlider
             
             volumViewSlider = subView as! UISlider
             
             return volumViewSlider
             
             }*/
        }
        return volumViewSlider
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
