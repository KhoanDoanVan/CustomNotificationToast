//
//  InAppNotification+Extension.swift
//  CustomNotificationToast
//
//  Created by Đoàn Văn Khoan on 25/12/24.
//

import SwiftUI

extension UIApplication {
    func inAppNotification<Content: View>(
        adaptForDynamicIsland: Bool = false,
        timeout: CGFloat = 5.0,
        swipeToClose: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        /// Fetching active window via WindowScene
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: {
            $0.tag == 41232
        }) {
            /// Frame and Safearea Values
            let frame = activeWindow.frame
            let safeArea = activeWindow.safeAreaInsets
            
            /// Tag
            var tag: Int = 10123
            /// Because the approximate of the top area to dynamic island was around 11 pixels
            let checkForDynamicIsland = adaptForDynamicIsland && safeArea.top >= 51
            
            if let previousTag = UserDefaults.standard.value(forKey: "in_app_notification_tag") as? Int {
                tag = previousTag + 1
            }
            
            UserDefaults.standard.set(tag, forKey: "in_app_notification_tag")
            
            /// Changing Status bar into black to blend with Dynamic Island
            if checkForDynamicIsland {
                if let controller = activeWindow.rootViewController as? StatusBarBasedController {
                    controller.statusBarStyle = .darkContent
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
            
            /// Creating UIView from SwiftUIView using UIHosting Configuration
            let config = UIHostingConfiguration {
                AnimatedNotificationView(
                    content: content(),
                    safeArea: safeArea,
                    tag: tag,
                    adaptForDynamicIsland: checkForDynamicIsland,
                    timeout: timeout,
                    swipeToClose: swipeToClose
                )
                .frame(width: frame.width - (checkForDynamicIsland ? 20 : 30), height: 120, alignment: .top)
                .contentShape(.rect)
            }
            
            /// Creating UIView
            let view = config.makeContentView()
            view.tag = tag
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            /// Adding view to WindowView (can't run on simulator)
            if let rootView = activeWindow.rootViewController?.view {
                rootView.addSubview(view)
                
                /// Layout Constraints
                view.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
                view.centerYAnchor.constraint(equalTo: rootView.centerYAnchor, constant: -((frame.height - safeArea.top) / 2) + (checkForDynamicIsland ? 11 : safeArea.top)).isActive = true
            }
        }
    }
}


fileprivate struct AnimatedNotificationView<Content: View>: View {
    
    var content: Content
    var safeArea: UIEdgeInsets
    var tag: Int
    var adaptForDynamicIsland: Bool
    var timeout: CGFloat
    var swipeToClose: Bool
    
    /// View Properties
    @State private var animationNotification: Bool = false
    
    var body: some View {
        content
            .blur(radius: animationNotification ? 0 : 10)
            .disabled(!animationNotification)
            .mask {
                if adaptForDynamicIsland {
                    /// Size based capsule
                    GeometryReader { geometry in
                        let size = geometry.size
                        let radius = size.height / 2
                        
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                    }
                } else {
                    Rectangle()
                }
            }
            /// Offset only for nonDynamic Island Notification
            .offset(y: offsetY)
            /// Scaling Animation Only for Dynamic Island Notification
            .scaleEffect(adaptForDynamicIsland ? (animationNotification ? 1 : 0.01) : 1, anchor: .init(x: 0.5, y: 0.01))
            /// Gesture
            .gesture(
                DragGesture()
                    .onEnded({ value in
                        if -value.translation.height > 50 && swipeToClose {
                            withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                                animationNotification = false
                            } completion: {
                                removeNotificationViewFromWindow()
                            }
                        }
                    })
            )
            .onAppear {
                Task {
                    guard !animationNotification else { return }
                    
                    withAnimation(.smooth) {
                        animationNotification = true
                    }
                    
                    /// Timeout For Notification
                    try await Task.sleep(for: .seconds(timeout < 1 ? 1 : timeout))
                    
                    guard animationNotification else { return }
                    
                    withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                        animationNotification = false
                    } completion: {
                        removeNotificationViewFromWindow()
                    }
                }
            }
    }
    
    var offsetY: CGFloat {
        if adaptForDynamicIsland {
            return 0
        }
        
        return animationNotification ? 10 : -(safeArea.top + 130)
    }
    
    func removeNotificationViewFromWindow() {
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 41232 })
        {
            if let view = activeWindow.viewWithTag(tag) {
                
                /// Remove view with tag
                print("remove tag: \(tag)")
                view.removeFromSuperview()
                
                /// Resetting Once all notification was removed
                if let controller = activeWindow.rootViewController as? StatusBarBasedController,
                   controller.view.subviews.isEmpty
                {
                    controller.statusBarStyle = .default
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
