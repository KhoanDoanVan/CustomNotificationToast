//
//  ContentView.swift
//  CustomNotificationToast
//
//  Created by Đoàn Văn Khoan on 25/12/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isShowSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Show Notifications") {
                    UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout:  5, swipeToClose: false) {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(.black)
                    }
                }
                
                NavigationLink {
                    Text("Next View")
                } label: {
                    Text("Next view")
                        .foregroundStyle(Color.yellow)
                }
                
                /// If the sheet showed after the notification had showed, the notification will display below the sheet view
                Button {
                    isShowSheet.toggle()
                } label: {
                    Text("Show Sheet")
                        .foregroundStyle(Color.red)
                }
                
            }
            .sheet(isPresented: $isShowSheet, content: {
                Text("Sheet View")
            })
            .navigationTitle("In App Notification")
        }
    }
}

#Preview {
    ContentView()
}
