//
//  SystemScreenProtocols.swift
//  ArrvisCore
//
//  Created by Yutaka Izumaru on 2019/10/21.
//  Copyright © 2019 Arrvis Co., Ltd. All rights reserved.
//

/// SystemScreen表示可能
public protocol SystemScreenShowable: AlertShowable, ActionSheetShowable, ActivityShowable, ImagePickerShowable {}

/// Alert情報
public struct AlertInfo {

    /// タイトル
    public let title: String?

    /// メッセージ
    public let message: String?

    /// カスタムView
    public let customView: UIView?

    /// アクション
    public let actions: [String: (UIAlertAction.Style, () -> Void)]

    /// キャンセルタイトル
    public let cancel: String?

    /// キャンセルハンドラー
    public let onCancel: (() -> Void)?

    /// UIAlertController生成
    ///
    /// - Parameter preferredStyle: preferredStyle
    /// - Returns: UIAlertController
    public func createAlertController(_ preferredStyle: UIAlertController.Style) -> UIAlertController {
        let vc =  UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)
        vc.title = title
        vc.message = message
        if let customView = customView {
            vc.view.addSubview(customView)
            customView.edgesToSuperview()
        }
        var actions = self.actions.map { pair -> UIAlertAction in
            return UIAlertAction(title: pair.key, style: pair.value.0, handler: { _ in
                pair.value.1()
            })
        }
        if let cancel = cancel {
            let cancelAction = UIAlertAction(title: cancel, style: .destructive, handler: { _ in
                self.onCancel?()
            })
            if vc.preferredStyle == .alert {
                actions.insert(cancelAction, at: 0)
            } else {
                actions.append(cancelAction)
            }
        }
        vc.popoverPresentationController?.sourceView = vc.view
        vc.popoverPresentationController?.sourceRect = CGRect(
            x: vc.view.frame.midX,
            y: vc.view.frame.midY,
            width: 0,
            height: 0
        )
        vc.popoverPresentationController?.permittedArrowDirections = []
        actions.forEach { vc.addAction($0) }
        return vc
    }
}

public protocol AlertShowable {
    func showAlert(_ alertInfo: AlertInfo)
}

extension AlertShowable {

    public func showOkAlert(
        _ title: String? = nil,
        _ message: String? = nil,
        _ ok: String,
        _ onOk: (() -> Void)? = nil) {
        let alertInfo = AlertInfo(
            title: title,
            message: message,
            customView: nil,
            actions: [ ok: (.default, { onOk?() }) ],
            cancel: nil,
            onCancel: nil
        )
        showAlert(alertInfo)
    }

    public func showConfirmAlert(
        _ title: String? = nil,
        _ message: String? = nil,
        _ ok: String,
        _ onOk: @escaping () -> Void,
        _ cancel: String,
        _ onCancel: (() -> Void)? = nil) {
        let alertInfo = AlertInfo(
            title: title,
            message: message,
            customView: nil,
            actions: [ ok: (.default, { onOk() }) ],
            cancel: cancel,
            onCancel: onCancel
        )
        showAlert(alertInfo)
    }
}

public protocol ActionSheetShowable {
    func showActionSheet(_ alertInfo: AlertInfo)
}

extension ActionSheetShowable {

    public func showActionSheet(
        _ title: String? = nil,
        _ message: String? = nil,
        _ actions: [String: (UIAlertAction.Style, () -> Void)],
        _ cancel: String,
        _ onCancel: (() -> Void)? = nil) {
        let alertInfo = AlertInfo(
            title: title,
            message: message,
            customView: nil,
            actions: actions,
            cancel: cancel,
            onCancel: onCancel
        )
        showActionSheet(alertInfo)
    }
}

/// Activity情報
public struct ActivityInfo {

    /// activityItems
    public let activityItems: [Any]

    /// applicationActivities
    public let applicationActivities: [UIActivity]?

    /// excludedActivityTypes
    public let excludedActivityTypes: [UIActivity.ActivityType]?

    /// UIActivityViewController生成
    ///
    /// - Returns: UIActivityViewController
    public func createActivityViewController() -> UIActivityViewController {
        let vc = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = vc.view
        vc.popoverPresentationController?.sourceRect = CGRect(
            x: vc.view.frame.midX,
            y: vc.view.frame.midY,
            width: 0,
            height: 0
        )
        vc.popoverPresentationController?.permittedArrowDirections = []
        return vc
    }
}

public protocol ActivityShowable {
    func showActivityScreen(_ activityInfo: ActivityInfo)
}

extension ActivityShowable {

    public func showActivityScreen(
        _ activityItems: [Any] = [],
        _ applicationActivities: [UIActivity]? = nil,
        _ excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        let activityInfo = ActivityInfo(
            activityItems: activityItems,
            applicationActivities: applicationActivities,
            excludedActivityTypes: excludedActivityTypes
        )
        showActivityScreen(activityInfo)
    }
}

/// ImagePicker情報
public struct ImagePickerInfo {

    /// delegate
    public weak var delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?

    /// sourceType
    public let sourceType: UIImagePickerController.SourceType

    /// mediaTypes
    public let mediaTypes: [CFString]

    /// UIImagePickerController生成
    ///
    /// - Returns: UIImagePickerController
    public func createImagePickerController() -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.delegate = delegate
        vc.sourceType = sourceType
        vc.mediaTypes = mediaTypes as [String]
        return vc
    }
}

public protocol ImagePickerShowable {
    func showLibraryScreen(_ handler: CameraRollEventHandler, _ mediaTypes: [CFString])
    func showCameraScreen(_ handler: CameraRollEventHandler, _ mediaTypes: [CFString])
}
