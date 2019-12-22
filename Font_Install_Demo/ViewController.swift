//
//  ViewController.swift
//  Font_Install_Demo
//
//  Created by 鶴田 啓 on 2019/12/23.
//  Copyright © 2019 鶴田 啓. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Protperties
    
    private var resourceRequest: NSBundleResourceRequest?
    
    // MARK: IBActions

    @IBAction private func install(_ sender: UIButton) {
        let fontList = ["NotoSans-Black"] as CFArray
        let assetList: Set<String> = ["Font"]
        requestFont(tags: assetList, fonts: fontList)
    }
    
    @IBAction private func uninstall(_ sender: Any) {
        let fontList = ["NotoSans-Black"]
        let fontDescriptors = fontList.compactMap { $0.fontDescriptor }
        unInstall(fontDescriptors: fontDescriptors)
    }
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Methods
    
    func requestFont(tags: Set<String>, fonts: CFArray) {
        resourceRequest = NSBundleResourceRequest(tags: tags)
        resourceRequest?.conditionallyBeginAccessingResources { [weak self] isAvailable in
            if isAvailable {
                debugPrint("is available")
                self?.installFont(fonts: fonts)
            } else {
                debugPrint("is not available")
                self?.accessFont(fonts: fonts)
            }
        }
    }
    
    func accessFont(fonts: CFArray) {
        resourceRequest?.beginAccessingResources { [weak self] error in
            if error == nil {
                self?.installFont(fonts: fonts)
            } else {
                print("error", error?.localizedDescription ?? "")
            }
            self?.resourceRequest?.endAccessingResources()
        }
    }
    
    func installFont(fonts: CFArray) {
        CTFontManagerRegisterFontsWithAssetNames(fonts, CFBundleGetMainBundle(), .persistent, true) { errors, _ -> Bool in
            if 1 <= CFArrayGetCount(errors) {
                debugPrint("font install failure: \(unsafeBitCast(CFArrayGetValueAtIndex(errors, 0), to: CFError.self).localizedDescription)")
                return false
            } else {
                debugPrint("font install success")
                return true
            }
        }
    }

    func unInstall(fontDescriptors: [CTFontDescriptor]) {
        CTFontManagerUnregisterFontDescriptors(fontDescriptors as CFArray, .persistent) { errors, _ -> Bool in
            if 1 <= CFArrayGetCount(errors) {
                debugPrint("font uninstall failure: \(unsafeBitCast(CFArrayGetValueAtIndex(errors, 0), to: CFError.self).localizedDescription)")
                return false
            } else {
                debugPrint("font uninstall success")
                return true
            }
        }
    }
}

extension String {
    
    var fontDescriptor: CTFontDescriptor? {
        return (CTFontManagerCopyRegisteredFontDescriptors(.persistent, true) as? [CTFontDescriptor])?.first {
            CTFontDescriptorCopyAttribute($0, kCTFontNameAttribute) as? String == self
        }
    }
}
