//
//  iOSCameraApp.swift
//  iOSCamera
//
//  Created by Jiwon_Hae on 2022/01/04.
//

import SwiftUI

@main
struct iOSCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ContentViewModel())
        }
    }
}
