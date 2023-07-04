//
//  Permissions.swift
//  PermissionManagerDemo
//
//  Created by zhangzp on 2022/6/1.
//

import Foundation
import CoreLocation

public class Permissions {
    public static func isNotDetermined(_ type: PermissionsType) -> Bool {
        return permission(with: type).isNotDetermined()
    }
    
    public static func isAuthorized(_ type: PermissionsType) -> Bool {
        return permission(with: type).isAuthorized()
    }
    
    public static func isDenied(_ type: PermissionsType) -> Bool {
        return permission(with: type).isDenied()
    }
    
    public static func isLimited() -> Bool {
        return permission(with: .photoLibrary).isLimited()
    }
    
    public static func requestAccess(_ type: PermissionsType, completion: @escaping (Bool) -> Void) {
        permission(with: type).requestAccess { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    @available(iOS 13.0.0, *)
    public static func requestAccess(_ type: PermissionsType) async -> Bool {
        return await permission(with: type).requestAccess()
    }
    
    /// 支持多个权限顺序弹窗
    public static func syncRequestAccess(types: [PermissionsType], permission: @escaping (PermissionsType, Bool) -> Void) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        for type in types {
            queue.addOperation {
                queue.isSuspended = true
                requestAccess(type) { result in
                    permission(type, result)
                    queue.isSuspended = false
                }
            }
        }
    }
}

extension Permissions {
    public static func getLocations(completion: @escaping LocationResultClosure) {
        guard LocationPermission.shared != nil else {
            completion(nil)
            return
        }
        LocationPermission.shared?.getLocations(with: completion)
    }
    
    public static func getGeoLocations(completion: @escaping GeoLocationResultClosure) {
        guard LocationPermission.shared != nil else {
            completion(nil)
            return
        }
        LocationPermission.shared?.getGeoLocation(with: completion)
    }
}

extension Permissions {
    private static func permission(with type: PermissionsType) -> PermissionInterface {
        switch type {
        case .camera:
            return CameraPermission()
        case .photoLibrary:
            return PhotoLibraryPermission()
        case .microphone:
            return MicrophonePermission()
        case .contactStore:
            return ContactStorePermission()
        case .notification:
            return NotificationPermission()
        case .location(let type):
            if LocationPermission.shared == nil {
                LocationPermission.shared = LocationPermission(type: type)
            }
            return LocationPermission.shared!
        }
    }
}
