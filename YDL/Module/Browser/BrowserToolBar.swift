//
//  BrowserToolBar.swift
//  YDL
//
//  Created by ceonfai on 2019/1/8.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

#if swift(>=4.2)
fileprivate let barButtonItemStyle = UIBarButtonItem.Style.self
fileprivate let barButtonSystemItem = UIBarButtonItem.SystemItem.self
#else
fileprivate let barButtonItemStyle = UIBarButtonItemStyle.self
fileprivate let barButtonSystemItem = UIBarButtonSystemItem.self
#endif

@objc protocol BrowserNavigationToolbarDelegate {
    func webViewNavigationToolbarGoBack(_ toolbar: BrowserNavigationToolbar)
    func webViewNavigationToolbarGoForward(_ toolbar: BrowserNavigationToolbar)
    func webViewNavigationToolbarRefresh(_ toolbar: BrowserNavigationToolbar)
    func webViewNavigationToolbarStop(_ toolbar: BrowserNavigationToolbar)
}

class BrowserNavigationToolbar: UIView {
    
    // MARK: Public Properties
    
    var toolbar: UIToolbar! {
        get {
            return _toolbar
        }
    }
    weak var delegate: BrowserNavigationToolbarDelegate?
    var backButtonItem: UIBarButtonItem? {
        get {
            return _backButtonItem
        }
    }
    var forwardButtonItem: UIBarButtonItem? {
        get {
            return _forwardButtonItem
        }
    }
    var refreshButtonItem: UIBarButtonItem? {
        get {
            return _refreshButtonItem
        }
    }
    
    /** The tint color to apply to the toolbar button items.*/
    var toolbarTintColor: UIColor? {
        get {
            return _toolbarTintColor
        }
        
        set(value) {
            _toolbarTintColor = value
            if let toolbar = self.toolbar {
                toolbar.tintColor = _toolbarTintColor
            }
        }
    }
    
    /** The toolbar's background color.*/
    var toolbarBackgroundColor: UIColor? {
        get {
            return _toolbarBackgroundColor
        }
        
        set(value) {
            _toolbarBackgroundColor = value
            if let toolbar = self.toolbar {
                toolbar.barTintColor = _toolbarBackgroundColor
            }
        }
    }
    
    /** A Boolean value that indicates whether the toolbar is translucent (true) or not (false).*/
    var toolbarTranslucent: Bool {
        get {
            return _toolbarTranslucent
        }
        
        set(value) {
            _toolbarTranslucent = value
            if let toolbar = self.toolbar {
                toolbar.isTranslucent = _toolbarTranslucent
            }
        }
    }
    
    var showsStopRefreshControl: Bool {
        get {
            return _showsStopRefreshControl
        }
        
        set(value) {
            if _toolbar != nil {
                if value && !_showsStopRefreshControl {
                    _toolbar.setItems([_backButtonItem, _forwardButtonItem, _flexibleSpace, _refreshButtonItem], animated: false)
                } else if !value && _showsStopRefreshControl {
                    _toolbar.setItems([_backButtonItem, _forwardButtonItem], animated: false)
                }
            }
            
            _showsStopRefreshControl = value
        }
    }
    
    // MARK: Private Properties
    
    fileprivate var _toolbar: UIToolbar!
    fileprivate lazy var _backButtonItem: UIBarButtonItem = {
        let backButtonItem = UIBarButtonItem(title: "\u{25C0}\u{FE0E}", style: barButtonItemStyle.plain, target: self, action: #selector(BrowserNavigationToolbar.goBack))
        backButtonItem.isEnabled = false
        return backButtonItem
    }()
    fileprivate lazy var _forwardButtonItem: UIBarButtonItem = {
        let forwardButtonItem = UIBarButtonItem(title: "\u{25B6}\u{FE0E}", style: barButtonItemStyle.plain, target: self, action: #selector(BrowserNavigationToolbar.goForward))
        forwardButtonItem.isEnabled = false
        return forwardButtonItem
    }()
    fileprivate lazy var _refreshButtonItem: UIBarButtonItem = {UIBarButtonItem(barButtonSystemItem: barButtonSystemItem.refresh, target: self, action: #selector(BrowserNavigationToolbar.refresh))}()
    fileprivate lazy var _stopButtonItem: UIBarButtonItem = {UIBarButtonItem(barButtonSystemItem: barButtonSystemItem.stop, target: self, action: #selector(BrowserNavigationToolbar.stop))}()
    fileprivate lazy var _flexibleSpace: UIBarButtonItem = {UIBarButtonItem(barButtonSystemItem: barButtonSystemItem.flexibleSpace, target: nil, action: nil)}()
    fileprivate var _toolbarTintColor: UIColor?
    fileprivate var _toolbarBackgroundColor: UIColor?
    fileprivate var _toolbarTranslucent = true
    fileprivate var _showsStopRefreshControl = true
    
    // MARK: Public Methods
    
    func loadDidStart() {
        if !_showsStopRefreshControl {
            return
        }
        
        let items = [_backButtonItem, _forwardButtonItem, _flexibleSpace, _stopButtonItem]
        _toolbar.setItems(items, animated: true)
    }
    
    func loadDidFinish() {
        if !_showsStopRefreshControl {
            return
        }
        
        let items = [_backButtonItem, _forwardButtonItem, _flexibleSpace, _refreshButtonItem]
        _toolbar.setItems(items, animated: true)
    }
    
    // MARK: Navigation Methods
    @objc func goBack() {
        delegate?.webViewNavigationToolbarGoBack(self)
    }
    
    @objc func goForward() {
        delegate?.webViewNavigationToolbarGoForward(self)
    }
    
    @objc func refresh() {
        delegate?.webViewNavigationToolbarRefresh(self)
    }
    
    @objc func stop() {
        delegate?.webViewNavigationToolbarStop(self)
    }
    
    // MARK: Life Cycle
    
    init(delegate: BrowserNavigationToolbarDelegate) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (_toolbar == nil) {
            _toolbar = UIToolbar()
            _toolbar.tintColor = _toolbarTintColor
            _toolbar.barTintColor = _toolbarBackgroundColor
            _toolbar.isTranslucent = _toolbarTranslucent
            _toolbar.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(_toolbar)
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[toolbar]-0-|", options: [], metrics: nil, views: ["toolbar": _toolbar]))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[toolbar]-0-|", options: [], metrics: nil, views: ["toolbar": _toolbar]))
            
            // Set up _toolbar
            let items = _showsStopRefreshControl ? [_backButtonItem, _forwardButtonItem, _flexibleSpace, _refreshButtonItem] : [_backButtonItem, _forwardButtonItem]
            _toolbar.setItems(items, animated: false)
        }
    }
    
}
