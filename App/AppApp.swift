//
//  AppApp.swift
//  App
//
//  Created by ‌ ‌Haidari on 2025-04-09.
//

import SwiftUI
import UserNotifications

@main
struct AppApp: App {
    @StateObject private var dataStore = MockDataStore()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(dataStore)
                .onAppear {
                    registerForPushNotifications()
                }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(MockDataStore())
}
