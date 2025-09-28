//
//  Coordinator.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController? { get set }
    func start()
    func navigate(to route: String, with data: Any?)
}
