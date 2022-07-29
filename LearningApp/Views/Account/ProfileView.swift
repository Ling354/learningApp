//
//  ProfileView.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-06-13.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct ProfileView: View {
    
    @EnvironmentObject var model: ContentView
    
    var body: some View {
        
        VStack {
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
        Button  {
            try! Auth.auth().signOut()
            
            // Change the view
            model.checkLogin()
        } label: {
            Text("Sign Out")
        }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
