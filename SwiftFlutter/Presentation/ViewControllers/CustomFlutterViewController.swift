//
//  CustomFlutterViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import UIKit

class CustomFlutterViewController: FlutterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 隐藏导航栏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保导航栏保持隐藏状态
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 再次确保导航栏保持隐藏状态
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}