//
//  ContentListView.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-05-20.
//

import SwiftUI

struct ContentListView: View {
    
    @EnvironmentObject var model: ContentView
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
                // Confirm that currentModule is set
                
                if model.currentModule != nil {
                    
                    ForEach(0..<model.currentModule!.content.lessons.count) { index in
                        
                        NavigationLink(destination:
                                        ContentDetailView()
                            .onAppear(perform: {
                                model.beginLesson(index)
                            }),
                                       label: {
                            ContentViewRow(index: index)

                        })
                    }
                }
                
            }
            .accentColor(.black)
            .padding()
            .navigationTitle("Learn \(model.currentModule?.category ?? "")")
        }
        
        
    }
}
