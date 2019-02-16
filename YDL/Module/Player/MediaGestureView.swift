//
//  MediaGestureView.swift
//  YDL
//
//  Created by ceonfai on 2019/1/28.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

//视频播放器触摸方向

enum Direction : Int {
    case right = 0
    case left = 1
    case upOrDown = 2
    case none = 3
}

protocol TouchControlViewDelegate: NSObjectProtocol {
    /**
     * 开始触摸
     */
    func touchesBegan(with point: CGPoint)
    /**
     * 结束触摸
     */
    func touchesEnd(with point: CGPoint)
    /**
     * 移动手指
     */
    func touchesMove(with point: CGPoint)
    func didTapControlView()
    func didDoubleTapControlView()
    func touchesCancel()
}

class MediaGestureView: UIView {

    weak var touchDelegate:TouchControlViewDelegate?
    
   override init(frame: CGRect) {
        super.init(frame: frame)

    //Tap Gesture
    //single
    let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapControlView))
    singleTapGestureRecognizer.numberOfTapsRequired = 1
    self.addGestureRecognizer(singleTapGestureRecognizer)
    //double
    let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapControlView))
    doubleTapGestureRecognizer.numberOfTapsRequired = 2
    singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    self.addGestureRecognizer(doubleTapGestureRecognizer)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //获取触摸开始的坐标
        let touch = touches.first
        let currentP: CGPoint? = touch?.location(in: self)
        touchDelegate!.touchesBegan(with: currentP!)
    }
    
     //触摸结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch = touches.first
        let currentP: CGPoint? = touch?.location(in: self)
        touchDelegate!.touchesEnd(with: currentP!)
    }
    
    //移动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let currentP: CGPoint? = touch?.location(in: self)
        touchDelegate!.touchesMove(with: currentP!)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate!.touchesCancel()
    }

    @objc func didTapControlView() {
        
        if (touchDelegate != nil) {
            
            touchDelegate!.didTapControlView()
        }
    }
    
    @objc func didDoubleTapControlView() {
        
        
        if (touchDelegate != nil) {
            
            touchDelegate!.didDoubleTapControlView()
        }
    }
}
