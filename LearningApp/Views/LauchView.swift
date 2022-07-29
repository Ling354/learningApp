//
//  LauchView.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-06-13.
//

import SwiftUI

struct LauchView: View {
    
    @EnvironmentObject var model: ContentView
    
    var body: some View {
        
        if model.loggedIn == false {
            // Show log in view
            LoginView()
                .onAppear {
                    // Check if the user is logged in or out
                    model.checkLogin()
                }
        }
        else {
            // Show the logged in view
            TabView {
                HomeView()
                    .tabItem {
                        VStack {
                            Image(systemName: "book")
                            Text("Learn")
                        }
                    }
                ProfileView()
                    .tabItem {
                        Label ("Person", systemImage: "person")
                    }
            }
            .onAppear {
                model.getDatabaseModules()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                
                // Save progress to the database when the app is moving from active to background
                model.saveData(writeToDatabase: true)
            }
        }
        
    }
}

struct LauchView_Previews: PreviewProvider {
    static var previews: some View {
        LauchView()
    }
}
