//
//  Permissions.swift
//
//  Created by zhangzp on 2022/6/1.
//

import Foundation

public class Permissions {
    public static func isNotDetermined(_ type: PermissionsType) async -> Bool {
        return await permission(with: type).isNotDetermined()
    }
    
    public static func isAuthorized(_ type: PermissionsType) async -> Bool {
        return await permission(with: type).isAuthorized()
    }
    
    public static func isDenied(_ type: PermissionsType) async -> Bool {
        return await permission(with: type).isDenied()
    }
    
    public static func isLimited() -> Bool {
        return permission(with: .photoLibrary).isLimited()
    }
    
    public static func requestAccess(_ type: PermissionsType) async -> Bool {
        return await permission(with: type).requestAccess()
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
        }
    }
}
