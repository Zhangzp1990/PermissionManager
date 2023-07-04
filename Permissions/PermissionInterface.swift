//
//  PermissionInterface.swift
//
//  Created by zhangzp on 2022/6/1.
//

import Foundation
import Photos
import UserNotifications
import EventKit
import Contacts

public protocol PermissionInterface {
    /// 用户还未决定
    func isNotDetermined() async -> Bool
    /// 用户授权
    func isAuthorized() async -> Bool
    /// 用户拒绝
    func isDenied() async -> Bool
    /// 有限的权限（特殊：仅相册使用）
    func isLimited() -> Bool
    /// 请求权限
    func requestAccess() async -> Bool
}

extension PermissionInterface {
    /// 默认实现
    public func isLimited() -> Bool {
        return false
    }
}

/// 相机权限
public final class CameraPermission: PermissionInterface {
    public func isNotDetermined() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }
    
    public func isAuthorized() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public func isRestrict() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .restricted
    }
    
    public func isDenied() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .denied || status == .restricted
    }
    
    public func requestAccess() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
}

/// 麦克风权限
public final class MicrophonePermission: PermissionInterface {
    public func isNotDetermined() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .undetermined
    }
    
    public func isAuthorized() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    public func isDenied() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .denied
    }
    
    public func requestAccess() async -> Bool {
        return await withCheckedContinuation({ continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        })
    }
}

/// 相册权限
public final class PhotoLibraryPermission: PermissionInterface {
    public func isNotDetermined() -> Bool {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined
        } else {
            return PHPhotoLibrary.authorizationStatus() == .notDetermined
        }
    }
    
    public func isAuthorized() -> Bool {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return status == .authorized
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            return status == .authorized
        }
    }
    
    public func isDenied() -> Bool {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return status == .denied || status == .restricted
        } else {
            return PHPhotoLibrary.authorizationStatus() == .denied
        }
    }
    
    public func isLimited() -> Bool {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
        } else {
            return false
        }
    }
    
    public func requestAccess() async -> Bool {
        if #available(iOS 14, *) {
            let result = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return result == .authorized || result == .limited
        } else {
            return await withCheckedContinuation({ continuation in
                PHPhotoLibrary.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized || status == .limited)
                }
            })
        }
    }
}

/// 通讯录权限
public final class ContactStorePermission: PermissionInterface {
    public func isNotDetermined() -> Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .notDetermined
    }
    
    public func isAuthorized() -> Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    public func isDenied() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status == .denied || status == .restricted
    }
    
    public func requestAccess() async -> Bool {
        do {
            return try await CNContactStore().requestAccess(for: .contacts)
        } catch {
            print("CNContactStore request failed with error: \(error)")
        }
        return false
    }
}

/// 通知权限
public final class NotificationPermission: PermissionInterface {
    public func isNotDetermined() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .notDetermined
    }
    
    public func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    public func isDenied() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .denied
    }
    
    public func requestAccess() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound])
        } catch {
            print("CNContactStore request failed with error: \(error)")
        }
        return false
    }
}
