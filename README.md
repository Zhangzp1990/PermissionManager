# PermissionManager
**项目中各种权限的访问导致工程代码很凌乱，统一封装的权限管理**

# 使用方法

```
Task {
    /// 获取相机权限
    let camera = await Permissions.requestAccess(.camera)
    /// 相机权限是否授权
    let cameraAuth = await Permissions.isAuthorized(.camera)
    /// 相机权限是否未决定
    let cameraNotDetermined = await Permissions.isNotDetermined(.camera)
    /// 相机权限是否拒绝
    let cameraDenied = await Permissions.isDenied(.camera)
    
    /// 获取通知权限
    let notification = await Permissions.requestAccess(.notification)
    /// 通知权限是否授权
    let notificationAuth = await Permissions.isAuthorized(.notification)
    /// 通知权限是否未决定
    let notifiNotDetermined = await Permissions.isNotDetermined(.notification)
    /// 通知权限是否拒绝
    let notifiDenied = await Permissions.isDenied(.notification)
}
```
