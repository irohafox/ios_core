//
//  Navigatable.swift
//  ArrvisCore
//
//  Created by Yutaka Izumaru on 2019/10/21.
//  Copyright © 2019 Arrvis Co., Ltd. All rights reserved.
//

/// Navigate可能
public protocol Navigatable {

    /// スキーム
    var scheme: String { get }

    /// ルート一覧
    var routes: [String] { get }

    /// スクリーン取得
    ///
    /// - Parameter path: パス
    /// - Returns: スクリーン
    func getScreen(path: String) -> Screen
}

extension Navigatable {

    public var scheme: String {
        fatalError("Not implemented")
    }

    public var routes: [String] {
        fatalError("Not implemented")
    }

    public func getScreen(path: String) -> Screen {
        if let screen = SystemScreens(rawValue: path) {
            return screen
        }
        fatalError("Not implemented")
    }
}
