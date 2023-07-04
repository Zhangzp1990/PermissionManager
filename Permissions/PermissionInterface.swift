//
//  PermissionInterface.swift
//  PermissionManagerDemo
//
//  Created by zhangzp on 2022/6/1.
//

import Foundation
import Photos
import UserNotifications
import EventKit
import Contacts
import MapKit

public protocol PermissionInterface {
    /// 用户还未决定
    func isNotDetermined() -> Bool
    /// 用户授权
    func isAuthorized() -> Bool
    /// 用户拒绝
    func isDenied() -> Bool
    /// 有限的权限（特殊：仅相册使用）
    func isLimited() -> Bool
    /// 请求权限
    func requestAccess(completion: @escaping (Bool) -> Void)
    /// 请求权限
    @available(iOS 13.0.0, *)
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
    
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { finished in
            completion(finished)
        }
    }
    
    @available(iOS 13.0.0, *)
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
    
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
    
    @available(iOS 13.0.0, *)
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
            return status == .authorized || status == .limited
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
    
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                completion(status == .authorized)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                completion(status == .authorized)
            }
        }
    }
    
    @available(iOS 13.0.0, *)
    public func requestAccess() async -> Bool {
        if #available(iOS 14, *) {
            let result = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return result == .authorized || result == .limited
        } else {
            return await withCheckedContinuation({ continuation in
                PHPhotoLibrary.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
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
    
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            completion(granted)
            print("CNContactStore request failed with error: \(String(describing: error))")
        }
    }
    
    @available(iOS 13.0.0, *)
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
    /// 阻塞线程，需要异步获取
    public func isNotDetermined() -> Bool {
        var status: UNAuthorizationStatus = .notDetermined
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            status = setting.authorizationStatus
            semaphore.signal()
        }
        return status == .notDetermined
    }
    
    /// 阻塞线程，需要异步获取
    public func isAuthorized() -> Bool {
        var status: UNAuthorizationStatus = .notDetermined
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            status = setting.authorizationStatus
            semaphore.signal()
        }
        return status == .authorized
    }
    
    /// 阻塞线程，需要异步获取
    public func isDenied() -> Bool {
        var status: UNAuthorizationStatus = .notDetermined
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            status = setting.authorizationStatus
            semaphore.signal()
        }
        return status == .denied
    }
    
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (result, _) in
            completion(result)
        }
    }
    
    @available(iOS 13.0.0, *)
    public func requestAccess() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound])
        } catch {
            print("CNContactStore request failed with error: \(error)")
        }
        return false
    }
}

public typealias LocationPermissionClosure = (Bool) ->Void
public typealias LocationResultClosure = (CLLocation?) -> Void
public typealias GeoLocationResultClosure = (CLPlacemark?) -> Void

/// 定位权限
public class LocationPermission: NSObject, CLLocationManagerDelegate {
    private var requestType: PermissionsType.LocationType = .always
    private var permissionClosure: LocationPermissionClosure?
    private var locationsClosure: LocationResultClosure?
    private var geoLocationClosure: GeoLocationResultClosure?
     
    public static var shared: LocationPermission?
    
    public var locations: CLLocation? {
        return self.locationManager.location
    }
    
    private lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        /// 为降低功耗, 使用 1英里 范围即可满足需求
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        return manager
    }()
    
    private override init() {
        super.init()
    }
    
    convenience init(type: PermissionsType.LocationType) {
        self.init()
        self.requestType = type
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }
        if let permissionClosure = permissionClosure {
            permissionClosure(isAuthorized())
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        
        guard let location = locations.last else {
            if let locationsClosure = self.locationsClosure {
                locationsClosure(nil)
                self.locationsClosure = nil
            }
            
            if let geoLocationClosure = geoLocationClosure {
                geoLocationClosure(nil)
                self.geoLocationClosure = nil
            }
            return
        }
        
        if let locationsClosure = self.locationsClosure {
            locationsClosure(location)
            self.locationsClosure = nil
        }
        
        if let geoLocationClosure = geoLocationClosure {
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                guard error == nil, let placeMark = placemarks?.first else {
                    geoLocationClosure(nil)
                    return
                }
                geoLocationClosure(placeMark)
                self.geoLocationClosure = nil
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError error: \(error)")
        if let locationsClosure = self.locationsClosure {
            locationsClosure(nil)
            self.locationsClosure = nil
        }
    }
    
    public func getLocations(with completion: @escaping LocationResultClosure) {
        self.locationsClosure = completion
        self.locationManager.startUpdatingLocation()
    }
    
    public func getGeoLocation(with completion: @escaping GeoLocationResultClosure) {
        self.geoLocationClosure = completion
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationPermission: PermissionInterface {
    public func isNotDetermined() -> Bool {
        if #available(iOS 14.0, *) {
            return self.locationManager.authorizationStatus == .notDetermined
        } else {
            return CLLocationManager.authorizationStatus() == .notDetermined
        }
    }
    
    public func isAuthorized() -> Bool {
        if #available(iOS 14.0, *) {
            switch requestType {
            case .always:
                return self.locationManager.authorizationStatus == .authorizedAlways
            case .whenInUse:
                return self.locationManager.authorizationStatus == .authorizedWhenInUse
            case .background:
                return self.locationManager.authorizationStatus == .authorizedAlways
            }
        } else {
            switch requestType {
            case .always:
                return CLLocationManager.authorizationStatus() == .authorizedAlways
            case .whenInUse:
                return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
            case .background:
                return CLLocationManager.authorizationStatus() == .authorizedAlways
            }
        }
    }
    
    public func isDenied() -> Bool {
        if #available(iOS 14.0, *) {
            return self.locationManager.authorizationStatus == .denied
        } else {
            return CLLocationManager.authorizationStatus() == .denied
        }
    }
    
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        self.permissionClosure = completion
        
        guard CLLocationManager.locationServicesEnabled() else {
            completion(false)
            return
        }
        
        switch requestType {
        case .always:
            self.locationManager.requestAlwaysAuthorization()
        case .whenInUse:
            self.locationManager.requestWhenInUseAuthorization()
        case .background:
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    @available(iOS 13.0.0, *)
    public func requestAccess() async -> Bool {
        fatalError("method not support")
    }
}
