//
//  LanguageReader.swift
//  YDL
//
//  Created by ceonfai on 2018/12/23.
//  Copyright © 2018 Ceonfai. All rights reserved.
//

import Foundation
import UIKit

var AppUsingLanguage:String?
var languageBundle:Bundle = {
    return Bundle.init(path: Bundle.main.path(forResource: "Language", ofType: "bundle")!)!
}()

func Localized(enKey:String)->String{
    var lproj:String?
    lproj = languageBundle.path(forResource: AppUsingLanguage, ofType: "lproj")
    let localizedKey = Bundle.init(path: lproj!)!.localizedString(forKey: enKey, value: "", table: "")
    return localizedKey
}

class LanguageReader: NSObject {
    
    //单例
    class var sharedInstance: LanguageReader {
        struct Static {
            static let instance = LanguageReader()
        }
        return Static.instance
    }
    
    func initLanguage() -> Void {
        
        let usingLanguage = self.usingLanguage()
        let ChineseKey: String = "zh-Hans"
        let englishKey:String = "en"
        let isChinese:Bool? = usingLanguage.contains(ChineseKey)
        var toUseKey:String?
        if isChinese! {
            toUseKey = ChineseKey
        }else{
            
            toUseKey = englishKey
        }
        
        self.toUseLanguage(languageKey: toUseKey!)
        
    }
    
    func usingLanguage() -> String {
        let sysLanguage = (NSLocale.preferredLanguages.first?.contains("zh-Hans"))! ? "zh-Hans":"en"
        AppUsingLanguage = UserDefaults.standard.string(forKey: "LanguageKey") ?? sysLanguage
        return AppUsingLanguage!

    }
    
    func toUseLanguage(languageKey:String) -> Void {
        AppUsingLanguage = languageKey
        UserDefaults.standard.set(languageKey, forKey: "LanguageKey")
    }
}
