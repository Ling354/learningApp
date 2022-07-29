//
//  ResumeView.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-06-22.
//

import SwiftUI

struct ResumeView: View {
    
    @EnvironmentObject var model: ContentView
    
    let user = UserService.shared.user
    
    var resumeTitle: String {
        
        let model = model.modules[user.lastModule ?? 0]
        
        if user.lastLesson != 0 {
            // Resume a lesson
            return "Learn \(model.category): Lesson \(user.lastLesson! + 1)"
        } else {
            // Resume test
            return "\(model.category) Test: Question \(user.lastQuestion! + 1)"
        }
        
    }
    
    var body: some View {
        
        ZStack {
            
            RectangleCard(color: .white)
                .frame(height: 66)
            
            HStack {
                VStack (alignment: .leading) {
                    Text("Continue where you left off:")
                    Text(resumeTitle)
                        .bold()
                }
                    Spacer()
                Image(systemName: "play")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            .padding()
        }
        
    }
}

struct ResumeView_Previews: PreviewProvider {
    static var previews: some View {
        ResumeView()
    }
}
