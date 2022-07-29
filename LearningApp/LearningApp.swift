//
//  LearningApp.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-03-22.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct LearningApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LauchView()
                .environmentObject(ContentView())
        }
    }
}
