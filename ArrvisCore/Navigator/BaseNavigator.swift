//
//  BaseNavigator.swift
//  ArrvisCore
//
//  Created by Yutaka Izumaru on 2018/09/14.
//  Copyright © 2018年 Arrvis Co., Ltd. All rights reserved.
//

import UIKit
import RxSwift
import Compass

protocol Navigatable {
    var scheme: String {get}
    var routes: [String] {get}

    func getScreen(path: String) -> Screen
}

/// Navigator基底クラス
open class BaseNavigator: Navigatable {

    // MARK: - Variables

    let replace = PublishSubject<UIViewController>()
    let push = PublishSubject<(vc: UIViewController, fromRoot: Bool, animate: Bool)>()
    let pop = PublishSubject<(Any?, Bool)>()
    let present = PublishSubject<(vc: UIViewController, animate: Bool)>()
    let dismiss = PublishSubject<(Any?, Bool)>()

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    public init() {
        Navigator.scheme = scheme
        Navigator.routes = routes
        Navigator.handle = { [unowned self] location in
            let animate = location.arguments.keys.contains("Animate")
            let fromRoot = location.arguments.keys.contains("FromRoot")
            var args = location.arguments
            args.removeValue(forKey: "Animate")
            args.removeValue(forKey: "FromRoot")
            let payload: Any?
            if location.payload == nil && !args.isEmpty {
                payload = args
            } else {
                payload = location.payload
            }
            let screen = self.getScreen(path: location.path)
            let vc = screen.createViewController(payload)
            switch screen.transition {
            case .replace:
                self.replace.onNext(vc)
            case .push:
                self.push.onNext((vc: vc, fromRoot: fromRoot, animate: animate))
            case .present:
                self.present.onNext((vc: vc, animate: animate))
            }
        }
    }

    // MARK: - Navigatable

    /// Scheme
    open var scheme: String {
        fatalError("Not implemented")
    }

    /// ルート一覧
    open var routes: [String] {
        fatalError("Not implemented")
    }

    /// スクリーン取得
    open func getScreen(path: String) -> Screen {
        if let screen = SystemScreens(rawValue: path) {
            return screen
        }
        fatalError("Not implemented")
    }
}

// MARK: - Navigate
extension BaseNavigator {

    /// 遷移
    ///
    /// - Parameters:
    ///   - screen: スクリーン
    ///   - payload: ペイロード
    ///   - fromRoot: true:RootのNavigationControllerから遷移 false:カレントのNavigationControllerから遷移
    ///   - animate: アニメーションするかどうか
    public func navigate<T: Screen>(screen: T, payload: Any? = nil, fromRoot: Bool = false, animate: Bool = true) {
        do {
            var arg = [String: String]()
            if fromRoot {
                arg["FromRoot"] = "true"
            }
            if animate {
                arg["Animate"] = "true"
            }
            try Navigator.navigate(location: Location(path: screen.path, arguments: arg, payload: payload))
        } catch {
            fatalError("error")
        }
    }

    /// 遷移
    ///
    /// - Parameter url: URL
    public func navigate(url: URL) {
        do {
            try Navigator.navigate(url: url)
        } catch {
            fatalError("error")
        }
    }

    /// 戻る
    public func popScreen(result: Any? = nil, animate: Bool = true) {
        pop.onNext((result, animate))
    }

    /// スクリーンを非表示
    public func dismissScreen(result: Any? = nil, animate: Bool = true) {
        dismiss.onNext((result, animate))
    }
}
