//
//  CustomNotificationToastApp.swift
//  CustomNotificationToast
//
//  Created by Đoàn Văn Khoan on 25/12/24.
//

import SwiftUI

@main
struct CustomNotificationToastApp: App {
    
    @State private var overlayWindow: PassThroughWindow?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if overlayWindow == nil {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            let overlayWindow = PassThroughWindow(windowScene: windowScene)
                            overlayWindow.backgroundColor = .clear
                            overlayWindow.tag = 41232
                            let controller = StatusBarBasedController()
                            controller.view.backgroundColor = .clear
                            overlayWindow.rootViewController = controller
                            overlayWindow.isHidden = false
                            overlayWindow.isUserInteractionEnabled = true
                            self.overlayWindow = overlayWindow
                        }
                    }
                }
        }
    }
}


/// Status Bar of the device
class StatusBarBasedController: UIViewController {
    
    var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
}


/// Passthrough Window to The overlay window can pass the interact with the view below it
fileprivate class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}
