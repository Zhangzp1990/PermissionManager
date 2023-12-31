//
//  PermissionsType.swift
//  PermissionManagerDemo
//
//  Created by zhangzp on 2022/6/1.
//

import Foundation

public enum PermissionsType {
    /// 相机
    case camera
    /// 麦克风
    case microphone
    /// 相册
    case photoLibrary
    /// 通知
    case notification
    /// 通讯录
    case contactStore
    /// 定位
    case location(type: LocationType)
    
    public enum LocationType {
        case always
        case whenInUse
        case background
    }
}
