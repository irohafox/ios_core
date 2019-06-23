//
//  NotificationService.swift
//  ArrvisCore
//
//  Created by Yutaka Izumaru on 2019/06/23.
//  Copyright © 2019 Arrvis Co., Ltd. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift
import SwiftEventBus

/// 通知データ
struct NotificationData {
    let alert: String

    static func fromUserInfo(_ userInfo: [AnyHashable: Any]) -> NotificationData? {
        guard let aps = userInfo["aps"] as? [String: Any] else {
            return nil
        }
        if let available = aps["content-available"] as? Bool, !available {
            return nil
        }
        guard let alert = aps["alert"] as? String else {
            return nil
        }
        return NotificationData(alert: alert)
    }
}

/// 通知関連サービス
public final class NotificationService {

    // MARK: - Variables

    /// DisposeBag
    public static let disposeBag = DisposeBag()

    private static var deviceTokenObserver: AnyObserver<Void>?
    private static var deviceToken: String?
}

// MARK: - Permission
extension NotificationService {

    /// 許可されているか取得
    public static func fetchGranted() -> Observable<(Bool)> {
        return Observable.create({ observer in
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
                NSObject.runOnMainThread {
                    if let error = error {
                        deviceToken = nil
                        observer.onError(error)
                    }
                    if error != nil {
                        observer.onNext(false)
                        observer.onCompleted()
                        return
                    }
                    if !granted {
                        deviceToken = nil
                    }
                    observer.onNext(granted)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
}

// MARK: - Token
extension NotificationService {

    /// デバイストークン取得リクエスト
    public static func requestDeviceToken() -> Observable<Void> {
        return Observable.create { observer in
            if deviceToken != nil {
                observer.onCompleted()
                return Disposables.create()
            }
            deviceTokenObserver = observer

            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
                if let error = error {
                    observer.onError(error)
                    return
                }
                if !granted {
                    observer.onCompleted()
                    return
                }
                NSObject.runOnMainThread {
                    center.delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return Disposables.create()
        }
    }

    /// デバイストークン取得完了
    public static func didReceiveDeviceToken(_ deviceToken: Data) {
        self.deviceToken = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        deviceTokenObserver?.onNext(())
    }

    /// デバイストークン取得エラー
    public static func didErrorReceiveDeviceToken(_ error: Error) {
        deviceTokenObserver?.onError(error)
    }
}

// MARK: - Notification
extension NotificationService {

    /// リモート通知受信
    static func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        guard let data = NotificationData.fromUserInfo(userInfo) else {
            return
        }
        SwiftEventBus.post(SystemBusEvents.didReceiveRemoteNotification, sender: data)
    }
}