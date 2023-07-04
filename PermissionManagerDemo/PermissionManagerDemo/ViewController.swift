//
//  ViewController.swift
//  PermissionManagerDemo
//
//  Created by zhangzp on 2023/7/3.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {
            let camera = await Permissions.requestAccess(.camera)
            let cameraAuth = await Permissions.isAuthorized(.camera)
            print("camera status = \(camera) isAuthorized = \(cameraAuth)")
            
            let photoLibrary = await Permissions.requestAccess(.photoLibrary)
            let photoAuth = await Permissions.isAuthorized(.photoLibrary)
            print("photoLibrary status = \(photoLibrary) isAuthorized = \(photoAuth)")
            
            let microphone = await Permissions.requestAccess(.microphone)
            let microphoneAuth = await Permissions.isAuthorized(.microphone)
            print("microphone status = \(microphone) isAuthorized = \(microphoneAuth)")
            
            let contactStore = await Permissions.requestAccess(.contactStore)
            let contactAuth = await Permissions.isAuthorized(.contactStore)
            print("contactStore status = \(contactStore) isAuthorized = \(contactAuth)")
            
            let notification = await Permissions.requestAccess(.notification)
            let notificationAuth = await Permissions.isAuthorized(.notification)
            print("notification status = \(notification) isAuthorized = \(notificationAuth)")
        }
    }
}

