//
//  LoginView.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-06-13.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

struct LoginView: View {
    
    @EnvironmentObject var model: ContentView
    @State var loginMode = Constants.LoginMode.login
    @State var email = ""
    @State var name = ""
    @State var password = ""
    @State var errorMessage: String?
    
    var buttonText: String {
        if loginMode == Constants.LoginMode.login {
            return "Login"
        } else {
            return "Create an Account"
        }
    }
    
    var body: some View {
        
        VStack (spacing: 10) {
            
            Spacer()
            
            // Logo
            Image(systemName: "book")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 150)
            
            // Title
            Text("Coding With Chris")
            
            Spacer()
            
            //Picker
            Picker(selection: $loginMode) {
                
                Text("Login")
                    .tag(Constants.LoginMode.login)
                
                Text("Sign Up")
                    .tag(Constants.LoginMode.createAccount)
                
            } label: {
                Text("Hey")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            
            // Form
            Group {
                TextField("Email", text: $email)
                
                
                if loginMode == Constants.LoginMode.createAccount {
                    TextField("Name", text: $name)
                }
                
                SecureField("Password", text: $password)
                
                if errorMessage != nil {
                    Text(errorMessage!)
                }
            }
            
            //Button
            Button {
                if loginMode == Constants.LoginMode.login {
                    
                    // Log the user in
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        
                        guard error == nil else {
                            errorMessage = error!.localizedDescription
                            return
                        }
                        // Clear error message
                        self.errorMessage = nil
                        
                        // Fetch user meta data
                        model.getUserData()
                        
                        // Check the view to logged in view
                        model.checkLogin()
                        
                        
                    }
                    
                } else {
                    // Create an account
                    Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        
                        // Check for error
                        guard error == nil else {
                            errorMessage = error!.localizedDescription
                            return
                        }
                        
                        // Clear error message
                        self.errorMessage = nil
                        
                        // Safe first name
                        let firebaseUser = Auth.auth().currentUser
                        let db = Firestore.firestore()
                        let ref = db.collection("users").document(firebaseUser!.uid)
                        
                        ref.setData(["name":name], merge: true)
                        
                        // Update the user meta data
                        let user = UserService.shared.user
                        user.name = name
                        
                        // Change the view to logged in view
                        model.checkLogin()
                        
                    }
                }
            } label: {
                
                ZStack {
                    
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(height: 40)
                        .cornerRadius(10)
                    
                    Text (buttonText)
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 40)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
