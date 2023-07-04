//
//  ViewController.swift
//  PermissionManagerDemo
//
//  Created by zhangzp on 2023/7/1.
//

import UIKit
import Photos
import UserNotifications
import EventKit
import Contacts

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /// 相册权限
        let isAuthorized = Permissions.isAuthorized(.photoLibrary)
        let isNotDetermined = Permissions.isNotDetermined(.photoLibrary)
        Permissions.requestAccess(.photoLibrary) { status in
            print("photoLibrary status = \(status)")
        }

        /// 通知权限
        if #available(iOS 13.0, *) {
            Task {
                let notification = await Permissions.requestAccess(.notification)
                print("notification status = \(notification)")
            }
        } else {
            // Fallback on earlier versions
        }
        
        /// 定位权限
        Permissions.requestAccess(.location(type: .whenInUse)) { result in
            print("location status = \(result)")
            guard result else { return }
            
            Permissions.getLocations { location in
                guard let location = location else { return }
                print("longitude = \(location.coordinate.longitude) latitude = \(location.coordinate.latitude)")
            }
            
            Permissions.getGeoLocations { placemark in
                guard let placemark = placemark else { return }
                print("placemark = \(placemark)")
            }
        }
        
        /// 权限批量请求，顺序弹窗
        Permissions.syncRequestAccess(types: [.camera, .microphone, .contactStore]) { type, status in
            print("type = \(type) status = \(status)")
        }
    }
}

