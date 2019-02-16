//
//  ZBrowserVC.swift
//  YDL
//
//  Created by ceonfai on 2018/12/26.
//  Copyright © 2018 Ceonfai. All rights reserved.
//

import UIKit
import WebKit

public enum BrowserVCProgressIndicatorStyle {
    case activityIndicator
    case progressView
    case both
    case none
}

@objc public protocol BrowserVCDelegate {
    @objc optional func webViewController(_ webViewController: BrowserVC, didChangeURL newURL: URL?)
    @objc optional func webViewController(_ webViewController: BrowserVC, didChangeTitle newTitle: NSString?)
    @objc optional func webViewController(_ webViewController: BrowserVC, didFinishLoading loadedURL: URL?)
    @objc optional func webViewController(_ webViewController: BrowserVC, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void)
    @objc optional func webViewController(_ webViewController: BrowserVC, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void)
    @objc optional func webViewController(_ webViewController: BrowserVC, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

open class BrowserVC: UIViewController, WKNavigationDelegate, WKUIDelegate, BrowserNavigationToolbarDelegate,PopMenuViewControllerDelegate {
    
    // MARK: Public Properties
    
    var popMenu:PopMenuViewController?
    var catchBtton:UIButton?
    var parseResult:NSDictionary?
    
    /** An object to serve as a delegate which conforms to BrowserNavigationToolbarDelegate protocol. */
    open weak var delegate: BrowserVCDelegate?
    
    /** The style of progress indication visualization. Can be one of four values: .ActivityIndicator, .ProgressView, .Both, .None*/
    open var progressIndicatorStyle: BrowserVCProgressIndicatorStyle = .both
    
    /** A Boolean value indicating whether horizontal swipe gestures will trigger back-forward list navigations. The default value is false. */
    open var allowsBackForwardNavigationGestures: Bool {
        get {
            return webView.allowsBackForwardNavigationGestures
        }
        set(value) {
            webView.allowsBackForwardNavigationGestures = value
        }
    }
    /** A boolean value if set to true shows the toolbar; otherwise, hides it. */
    open var showsToolbar: Bool {
        set(value) {
            self.toolbarHeight = value ? 44 : 0
        }
        
        get {
            return self.toolbarHeight == 44
        }
    }
    
    /** A boolean value if set to true shows the refresh control (or stop control while loading) on the toolbar; otherwise, hides it. */
    open var showsStopRefreshControl: Bool {
        get {
            return toolbarContainer.showsStopRefreshControl
        }
        
        set(value) {
            toolbarContainer.showsStopRefreshControl = value
        }
    }
    
    /** The navigation toolbar object (read-only). */
    var toolbar: BrowserNavigationToolbar {
        get {
            return toolbarContainer
        }
    }
    
    /** Boolean flag which indicates whether JavaScript alerts are allowed. Default is `true`. */
    open var allowJavaScriptAlerts = true
    
    public var webView: WKWebView!
    
    // MARK: Private Properties
    fileprivate var progressView: UIProgressView!
    fileprivate var toolbarContainer: BrowserNavigationToolbar!
    fileprivate var toolbarHeightConstraint: NSLayoutConstraint!
    fileprivate var toolbarHeight: CGFloat = 0
    fileprivate var navControllerUsesBackSwipe: Bool = false
    lazy fileprivate var activityIndicator: UIActivityIndicatorView! = {
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.2)
        #if swift(>=4.2)
        activityIndicator.style = .whiteLarge
        #else
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        #endif
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[activityIndicator]-0-|", options: [], metrics: nil, views: ["activityIndicator": activityIndicator]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[activityIndicator]-0-[toolbarContainer]|", options: [], metrics: nil, views: ["activityIndicator": activityIndicator, "toolbarContainer": self.toolbarContainer, "topGuide": self.topLayoutGuide]))
        return activityIndicator
    }()
    
    // MARK: Public Methods
    
    /**
     Navigates to an URL created from provided string.
     
     - parameter URLString: The string that represents an URL.
     */
    
    // TODO: Earlier `scheme` property was optional. Now it isn't true. Need to check that scheme is always
    
    open func loadURLWithString(_ URLString: String) {
        if let URL = URL(string: URLString) {
            if (URL.scheme != "") && (URL.host != nil) {
                loadURL(URL)
            } else {
                loadURLWithString("http://\(URLString)")
            }
        }
    }
    
    /**
     Navigates to the URL.
     
     - parameter URL: The URL for a request.
     - parameter cachePolicy: The cache policy for a request. Optional. Default value is .UseProtocolCachePolicy.
     - parameter timeoutInterval: The timeout interval for a request, in seconds. Optional. Default value is 0.
     */
    open func loadURL(_ URL: Foundation.URL, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 0) {
        webView.load(URLRequest(url: URL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval))
    }
    
    /**
     Evaluates the given JavaScript string.
     - parameter javaScriptString: The JavaScript string to evaluate.
     - parameter completionHandler: A block to invoke when script evaluation completes or fails.
     
     The completionHandler is passed the result of the script evaluation or an error.
     */
    open func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((AnyObject?, NSError?) -> Void)?) {
        webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler as! ((Any?, Error?) -> Void)?)
    }
    
    /**
     Shows or hides toolbar.
     
     - parameter show: A Boolean value if set to true shows the toolbar; otherwise, hides it.
     - parameter animated: A Boolean value if set to true animates the transition; otherwise, does not.
     */
    open func showToolbar(_ show: Bool, animated: Bool) {
        self.showsToolbar = show
        
        if toolbarHeightConstraint != nil {
            toolbarHeightConstraint.constant = self.toolbarHeight
            if animated {
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            } else {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc open func goBack(){
        webView.goBack()
    }
    
    @objc open func goForward(){
        webView.goForward()
    }
    
    @objc open func stopLoading(){
        webView.stopLoading()
    }
    
    @objc open func reload(){
        webView.reload()
    }
    
    // MARK: BrowserNavigationToolbarDelegate Methods
    
    func webViewNavigationToolbarGoBack(_ toolbar: BrowserNavigationToolbar) {
        webView.goBack()
    }
    
    func webViewNavigationToolbarGoForward(_ toolbar: BrowserNavigationToolbar) {
        webView.goForward()
    }
    
    func webViewNavigationToolbarRefresh(_ toolbar: BrowserNavigationToolbar) {
        webView.reload()
    }
    
    func webViewNavigationToolbarStop(_ toolbar: BrowserNavigationToolbar) {
        webView.stopLoading()
    }
    
    // MARK: WKNavigationDelegate Methods
    
    open func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }
        
        showError(error.localizedDescription)
    }
    
    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }
        showError(error.localizedDescription)
    }
    
    open func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard ((delegate?.webViewController?(self, didReceiveAuthenticationChallenge: challenge, completionHandler: { (disposition, credential) -> Void in
            completionHandler(disposition, credential)
        })) != nil)
            else {
                completionHandler(.performDefaultHandling, nil)
                return
        }
    }
    
    open func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }
    
    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoading(true)
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard ((delegate?.webViewController?(self, decidePolicyForNavigationAction: navigationAction, decisionHandler: { (policy) -> Void in
            decisionHandler(policy)
            if policy == .cancel {
                self.showError("This navigation is prohibited.")
            }
        })) != nil)
            else {
                decisionHandler(.allow);
                return
        }
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard ((delegate?.webViewController?(self, decidePolicyForNavigationResponse: navigationResponse, decisionHandler: { (policy) -> Void in
            decisionHandler(policy)
            if policy == .cancel {
                self.showError("This navigation response is prohibited.")
            }
        })) != nil)
            else {
                decisionHandler(.allow)
                return
        }
    }
    
    
    open func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url{
            if url.description.lowercased().range(of: "http://") != nil || url.description.lowercased().range(of: "https://") != nil  {
                webView.load(navigationAction.request)
            }
        }
        return nil
    }
    
    // MARK: WKUIDelegate Methods
    
    open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if !allowJavaScriptAlerts {
            return
        }
        
        let alertController: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(action: UIAlertAction) -> Void in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Some Private Methods
    
    fileprivate func showError(_ errorString: String?) {
        let alertView = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    fileprivate func showLoading(_ animate: Bool) {
        if animate {
            if (progressIndicatorStyle == .activityIndicator) || (progressIndicatorStyle == .both) {
                activityIndicator.startAnimating()
            }
            
            toolbar.loadDidStart()
        } else if activityIndicator != nil {
            if (progressIndicatorStyle == .activityIndicator) || (progressIndicatorStyle == .both) {
                activityIndicator.stopAnimating()
            }
            
            toolbar.loadDidFinish()
        }
    }
    
    fileprivate func progressChanged(_ newValue: NSNumber) {
        if progressView == nil {
            progressView = UIProgressView()
            progressView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(progressView)
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[progressView]-0-|", options: [], metrics: nil, views: ["progressView": progressView]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[progressView(2)]", options: [], metrics: nil, views: ["progressView": progressView, "topGuide": self.topLayoutGuide]))
        }
        
        progressView.progress = newValue.floatValue
        if progressView.progress == 1 {
            progressView.progress = 0
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.progressView.alpha = 0
            })
        } else if progressView.alpha == 0 {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.progressView.alpha = 1
            })
        }
    }
    
    fileprivate func backForwardListChanged() {
        if self.navControllerUsesBackSwipe && self.allowsBackForwardNavigationGestures {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !webView.canGoBack
        }
        
        toolbarContainer.backButtonItem?.isEnabled = webView.canGoBack
        toolbarContainer.forwardButtonItem?.isEnabled = webView.canGoForward
    }
    
    // MARK: KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        switch keyPath {
        case "estimatedProgress":
            if (progressIndicatorStyle == .progressView) || (progressIndicatorStyle == .both) {
                if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    progressChanged(newValue)
                }
            }
        case "URL":
            delegate?.webViewController?(self, didChangeURL: webView.url)
        case "title":
            delegate?.webViewController?(self, didChangeTitle: webView.title as NSString?)
        case "loading":
            if let val = change?[NSKeyValueChangeKey.newKey] as? Bool {
                if !val {
                    showLoading(false)
                    backForwardListChanged()
                    delegate?.webViewController?(self, didFinishLoading: webView.url)
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: Overrides
    
    // Override this property getter to show bottom toolbar above other toolbars
    override open var edgesForExtendedLayout: UIRectEdge {
        get {
            return UIRectEdge(rawValue: super.edgesForExtendedLayout.rawValue ^ UIRectEdge.bottom.rawValue)
        }
        set {
            super.edgesForExtendedLayout = newValue
        }
    }
    
    // MARK: Life Cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up toolbarContainer
        self.view.addSubview(toolbarContainer)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[toolbarContainer]-0-|", options: [], metrics: nil, views: ["toolbarContainer": toolbarContainer]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[toolbarContainer]-0-|", options: [], metrics: nil, views: ["toolbarContainer": toolbarContainer]))
        toolbarHeightConstraint = NSLayoutConstraint(item: toolbarContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: toolbarHeight)
        toolbarContainer.addConstraint(toolbarHeightConstraint)
        
        // Set up webView
        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[webView]-0-|", options: [], metrics: nil, views: ["webView": webView as WKWebView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[webView]-0-[toolbarContainer]|", options: [], metrics: nil, views: ["webView": webView as WKWebView, "toolbarContainer": toolbarContainer, "topGuide": self.topLayoutGuide]))
        
        self.title = Localized(enKey: "Browser")
        let popIcon  = FontIcon(withIcon: "\u{e6ec}", size: 40, color: .white)//返回按钮
        let moreIcon = FontIcon(withIcon: "\u{e688}", size: 40, color: .white)//三点菜单
        let leftItem = UIBarButtonItem.init(image: popIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(popAction))
        let rightItem = UIBarButtonItem.init(image: moreIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(popMenuTextOnly))
        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = rightItem
        
        //抓取视频的按钮
        let catchFrame = CGRect.init(x: SCREEN_WIDTH-60, y: SCREEN_HEIGHT-109, width: 50, height: 50)
        catchBtton = UIButton.init(frame: catchFrame)
        self.view.addSubview(catchBtton!)

        let iconColor = RGBA(R: 0, G: 0, B: 0, A: 0.7)
        catchBtton?.setImage(FontIcon(withIcon: "\u{e79a}", size: 100, color: iconColor)!, for: .normal)
        catchBtton!.addTarget(self, action: #selector(blurButtonPressed(_:)), for: .touchUpInside)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    @objc func blurButtonPressed(_ sender: UIButton) {
        print("Light blur button pressed.")
        showHUD(type: .ballSpinFadeLoader)
        let webURL = self.webView.url?.absoluteString
        //异步获取数据
        DispatchQueue.global(qos: .default).async {
            self.parseResult = PythonManager.shared().parseVideos(webURL!) as NSDictionary
            print(self.parseResult as Any)
            DispatchQueue.main.async {
                endHUD()
                if(self.parseResult?.count == 0){
                    YDLHUD.showText(text: "没有发现视频", delay: 1.5)
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let menuView:MenuLinkView = MenuLinkView.init()
                    menuView.showMenu(menuData: self.parseResult!)
                    menuView.topView?.configWithOriginData(parseResult: self.parseResult!)
                    menuView.mCallback = ({[weak self] in
                        let dlVc = DownloadVC()
                        self?.navigationController?.pushViewController(dlVc, animated: true)
                    })
                }
            }
         }
        
    }
    
    @objc func popAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func popMenuTextOnly() -> Void {
        let actions = [
            PopMenuDefaultAction(title: "Youtube"),
            PopMenuDefaultAction(title: "Vimeo"),
            PopMenuDefaultAction(title: "Daily Motion")
        ]
        self.popMenu = PopMenuViewController(actions: actions)
        popMenu?.delegate = self
        present(self.popMenu!, animated: true, completion: nil)

    }
    
    func readValue(key:String,param:NSDictionary) -> String {
        if(param[key] is NSNull){
            return ""
        }
        let obj = param[key] is NSNumber
        return String()
    }
    
    public func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        
        var visitURL:String?
        
        switch index {
        case 0:
            visitURL = SUPORTURL.Youtube.rawValue
        case 1:
            visitURL = SUPORTURL.Vimeo.rawValue
        case 2:
            visitURL = SUPORTURL.dailyMotion.rawValue
        default:
            visitURL = SUPORTURL.Youtube.rawValue
        }
        //loadURL(URL.init(string: visitURL!)!)
        self.webView.load(URLRequest.init(url: URL.init(string: visitURL!)!))
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "URL")
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navVC = self.navigationController {
            if let gestureRecognizer = navVC.interactivePopGestureRecognizer {
                navControllerUsesBackSwipe = gestureRecognizer.isEnabled
            } else {
                navControllerUsesBackSwipe = false
            }
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navControllerUsesBackSwipe {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        webView.stopLoading()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        let webConfiguration = WKWebViewConfiguration.init()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsAirPlayForMediaPlayback = false
        webConfiguration.requiresUserActionForMediaPlayback = false
        webView = WKWebView.init(frame: CGRect.init(), configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        toolbarContainer = BrowserNavigationToolbar(delegate: self)
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
    }
}
