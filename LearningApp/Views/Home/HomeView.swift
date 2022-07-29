//
//  ContentView.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-03-22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model: ContentView
    
    let user = UserService.shared.user
    
    var navTitle: String {
        if user.lastLesson != nil || user.lastQuestion != nil {
            return "Welcome Back!"
        } else {
            return "Get Started"
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                if user.lastLesson != nil && user.lastLesson! > 0 || user.lastQuestion != nil && user.lastQuestion! > 0 {
                    
                    // Show the resume view
                    ResumeView()
                        .padding(.leading)
                    
                } else {
                    Text("What do you want to do today?")
                        .padding(.leading)
                }
                
                
                
                ScrollView {
                    
                    LazyVStack {
                        
                        ForEach(model.modules) { module in
                            
                            VStack (spacing: 30){
                                
                                // Learning Card
                                NavigationLink(destination:
                                                ContentListView()
                                    .onAppear(perform: {
                                        model.getLessons(module: module) {
                                            model.beginModule(module.id)
                                        }
                                        
                                    }),
                                               tag: module.id.hash,
                                               selection: $model.currentContentSelected,
                                               label: {
                                    
                                    
                                    HomeViewRow(image: module.content.image, title: ("Learn \(module.category)"), description: module.content.description, count: ("\(module.content.lessons.count)"), time: module.content.time)
                                })
                                
                                // Test Card
                                NavigationLink(destination:
                                                TestView()
                                    .onAppear(perform: {
                                        model.getQuestions(module: module) {
                                            model.beginTest(module.id)
                                        }
                                    }),
                                               tag: module.id.hash,
                                               selection: $model.currentTestSelected) {
                                    
                                    
                                    HomeViewRow(image: module.test.image, title: ("\(module.category) Test"), description: module.test.description, count: ("\(module.test.questions.count)"), time: module.test.time)
                                }
                            }
                            .foregroundColor(.black)
                            .padding(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(navTitle)
        }
        .navigationViewStyle(.stack)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ContentView())
    }
}
