//
//  HybridBridge.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import Foundation
import WebKit

/// 混合开发Bridge实现
class HybridBridge: NSObject {
    // MARK: - Properties
    
    private var webView: WKWebView?
    private var isInitialized = false
    private var eventHandlers: [String: (Any?) -> Void] = [:]
    private var pendingCallbacks: [String: (Result<Any?, Error>) -> Void] = [:]
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupBridge()
    }
    
    // MARK: - Setup
    
    private func setupBridge() {
        // 创建WebView配置
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 注册JavaScript消息处理器
        userContentController.add(self, name: "nativeBridge")
        configuration.userContentController = userContentController
        
        // 创建WebView
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.navigationDelegate = self
        
        isInitialized = true
        print("Hybrid Bridge initialized")
    }
    
    // MARK: - Method Calls
    
    /// 调用混合开发方法
    func callMethod(_ method: String, arguments: [String: Any]? = nil, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard isInitialized else {
            completion(.failure(BridgeError.bridgeNotAvailable("Hybrid")))
            return
        }
        
        switch method {
        case "loadMallPage":
            handleLoadMallPage(arguments: arguments, completion: completion)
            
        case "processPayment":
            handleProcessPayment(arguments: arguments, completion: completion)
            
        case "getProductList":
            handleGetProductList(arguments: arguments, completion: completion)
            
        case "receiveSharedData":
            handleReceiveSharedData(arguments: arguments, completion: completion)
            
        case "callWebMethod":
            handleCallWebMethod(arguments: arguments, completion: completion)
            
        default:
            completion(.failure(BridgeError.methodCallFailed("Unknown method: \(method)")))
        }
    }
    
    // MARK: - Method Handlers
    
    private func handleLoadMallPage(arguments: [String: Any]?, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let args = arguments,
              let pageType = args["pageType"] as? String else {
            completion(.failure(BridgeError.invalidArguments))
            return
        }
        
        // 模拟加载商城页面
        let pageInfo = [
            "pageType": pageType,
            "url": "https://mall.example.com/\(pageType)",
            "title": getPageTitle(for: pageType),
            "loaded": true
        ] as [String : Any]
        
        completion(.success(pageInfo))
    }
    
    private func handleProcessPayment(arguments: [String: Any]?, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let args = arguments,
              let amount = args["amount"] as? Double,
              let orderId = args["orderId"] as? String else {
            completion(.failure(BridgeError.invalidArguments))
            return
        }
        
        // 模拟支付处理
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let paymentResult = [
                "orderId": orderId,
                "amount": amount,
                "status": "success",
                "transactionId": "txn_\(UUID().uuidString.prefix(8))",
                "timestamp": Date().timeIntervalSince1970
            ] as [String : Any]
            
            completion(.success(paymentResult))
        }
    }
    
    private func handleGetProductList(arguments: [String: Any]?, completion: @escaping (Result<Any?, Error>) -> Void) {
        let category = arguments?["category"] as? String ?? "all"
        
        // 模拟获取商品列表
        let products = [
            [
                "id": "prod_001",
                "name": "智能手机",
                "price": 2999.00,
                "category": "electronics",
                "image": "https://example.com/phone.jpg",
                "rating": 4.5
            ],
            [
                "id": "prod_002",
                "name": "无线耳机",
                "price": 299.00,
                "category": "electronics",
                "image": "https://example.com/earphones.jpg",
                "rating": 4.2
            ],
            [
                "id": "prod_003",
                "name": "智能手表",
                "price": 1299.00,
                "category": "wearables",
                "image": "https://example.com/watch.jpg",
                "rating": 4.7
            ]
        ]
        
        let filteredProducts = category == "all" ? products : products.filter { product in
            (product["category"] as? String) == category
        }
        
        completion(.success(["products": filteredProducts, "category": category]))
    }
    
    private func handleReceiveSharedData(arguments: [String: Any]?, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let args = arguments,
              let data = args["data"] as? [String: Any],
              let source = args["source"] as? String else {
            completion(.failure(BridgeError.invalidArguments))
            return
        }
        
        // 处理接收到的共享数据
        print("Hybrid received data from \(source): \(data)")
        
        // 如果有WebView，将数据传递给Web端
        if let webView = webView {
            let jsCode = "window.receiveNativeData && window.receiveNativeData(\(jsonString(from: data)), '\(source)');"
            webView.evaluateJavaScript(jsCode) { _, error in
                if let error = error {
                    print("Error sending data to web: \(error)")
                }
            }
        }
        
        // 触发事件通知
        if let handler = eventHandlers["dataReceived"] {
            handler(["data": data, "source": source])
        }
        
        completion(.success(["received": true]))
    }
    
    private func handleCallWebMethod(arguments: [String: Any]?, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let args = arguments,
              let method = args["method"] as? String,
              let webView = webView else {
            completion(.failure(BridgeError.invalidArguments))
            return
        }
        
        let callbackId = UUID().uuidString
        pendingCallbacks[callbackId] = completion
        
        let params = args["params"] as? [String: Any] ?? [:]
        let jsCode = "window.\(method) && window.\(method)(\(jsonString(from: params)), '\(callbackId)');"
        
        webView.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                self.pendingCallbacks.removeValue(forKey: callbackId)
                completion(.failure(BridgeError.methodCallFailed("JavaScript error: \(error.localizedDescription)")))
            }
            // 结果将通过JavaScript回调返回
        }
    }
    
    // MARK: - Event Handling
    
    /// 监听混合开发事件
    func listenToEvents(eventName: String, handler: @escaping (Any?) -> Void) {
        eventHandlers[eventName] = handler
        print("Hybrid listening to event: \(eventName)")
    }
    
    /// 发送事件到Web端
    func sendEventToWeb(eventName: String, data: Any?) {
        guard let webView = webView else { return }
        
        let jsCode = "window.receiveNativeEvent && window.receiveNativeEvent('\(eventName)', \(jsonString(from: data)));"
        webView.evaluateJavaScript(jsCode) { _, error in
            if let error = error {
                print("Error sending event to web: \(error)")
            }
        }
    }
    
    // MARK: - WebView Management
    
    /// 获取WebView实例
    func getWebView() -> WKWebView? {
        return webView
    }
    
    /// 加载URL
    func loadURL(_ urlString: String) {
        guard let webView = webView,
              let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    /// 加载HTML内容
    func loadHTML(_ htmlString: String, baseURL: URL? = nil) {
        webView?.loadHTMLString(htmlString, baseURL: baseURL)
    }
    
    // MARK: - Utility Methods
    
    private func getPageTitle(for pageType: String) -> String {
        switch pageType {
        case "home":
            return "商城首页"
        case "category":
            return "商品分类"
        case "cart":
            return "购物车"
        case "profile":
            return "个人中心"
        case "order":
            return "订单管理"
        default:
            return "商城页面"
        }
    }
    
    private func jsonString(from object: Any?) -> String {
        guard let object = object,
              let data = try? JSONSerialization.data(withJSONObject: object),
              let string = String(data: data, encoding: .utf8) else {
            return "null"
        }
        return string
    }
    
    /// 检查Hybrid Bridge是否可用
    func isAvailable() -> Bool {
        return isInitialized && webView != nil
    }
    
    /// 获取Bridge状态
    func getStatus() -> [String: Any] {
        return [
            "initialized": isInitialized,
            "webViewReady": webView != nil,
            "activeEventHandlers": eventHandlers.keys.count,
            "pendingCallbacks": pendingCallbacks.keys.count,
            "lastUpdate": Date().timeIntervalSince1970
        ]
    }
}

// MARK: - WKScriptMessageHandler

extension HybridBridge: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "nativeBridge",
              let messageBody = message.body as? [String: Any] else {
            return
        }
        
        handleWebMessage(messageBody)
    }
    
    private func handleWebMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }
        
        switch type {
        case "methodCallback":
            handleMethodCallback(message)
        case "event":
            handleWebEvent(message)
        case "log":
            handleWebLog(message)
        default:
            print("Unknown web message type: \(type)")
        }
    }
    
    private func handleMethodCallback(_ message: [String: Any]) {
        guard let callbackId = message["callbackId"] as? String,
              let callback = pendingCallbacks.removeValue(forKey: callbackId) else {
            return
        }
        
        if let error = message["error"] as? String {
            callback(.failure(BridgeError.methodCallFailed(error)))
        } else {
            callback(.success(message["result"]))
        }
    }
    
    private func handleWebEvent(_ message: [String: Any]) {
        guard let eventName = message["eventName"] as? String else { return }
        
        if let handler = eventHandlers[eventName] {
            handler(message["data"])
        }
    }
    
    private func handleWebLog(_ message: [String: Any]) {
        let level = message["level"] as? String ?? "info"
        let content = message["message"] as? String ?? "Unknown log"
        print("[Web \(level.uppercased())]: \(content)")
    }
}

// MARK: - WKNavigationDelegate

extension HybridBridge: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Hybrid WebView finished loading")
        
        // 注入Bridge JavaScript代码
        let bridgeJS = """
        window.nativeBridge = {
            call: function(method, params, callback) {
                const callbackId = 'cb_' + Date.now() + '_' + Math.random();
                window.webkit.messageHandlers.nativeBridge.postMessage({
                    type: 'methodCall',
                    method: method,
                    params: params,
                    callbackId: callbackId
                });
            },
            sendEvent: function(eventName, data) {
                window.webkit.messageHandlers.nativeBridge.postMessage({
                    type: 'event',
                    eventName: eventName,
                    data: data
                });
            },
            log: function(level, message) {
                window.webkit.messageHandlers.nativeBridge.postMessage({
                    type: 'log',
                    level: level,
                    message: message
                });
            }
        };
        """
        
        webView.evaluateJavaScript(bridgeJS) { _, error in
            if let error = error {
                print("Error injecting bridge JS: \(error)")
            } else {
                print("Bridge JavaScript injected successfully")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Hybrid WebView failed to load: \(error.localizedDescription)")
    }
}
