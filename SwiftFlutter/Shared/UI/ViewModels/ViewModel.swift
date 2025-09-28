//
//  ViewModel.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation

protocol ViewModel: ObservableObject {
    associatedtype Route
    func navigate(to route: Route)
}
