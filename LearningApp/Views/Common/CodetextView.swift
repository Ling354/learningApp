//
//  CodetextView.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-06-06.
//

import SwiftUI

struct CodetextView: UIViewRepresentable {
   
    @EnvironmentObject var model: ContentView
    
    func makeUIView(context: Context) -> UITextView {
        
        let textView = UITextView()
        textView.isEditable = false
        
        return textView
    }
    
    func updateUIView(_ textView: UIViewType, context: Context) {
        
        // Set the attributed text for the lesson
        textView.attributedText = model.codeText
        
        // Scroll back to the top
        textView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        
    }
    
}

struct CodetextView_Previews: PreviewProvider {
    static var previews: some View {
        CodetextView()
    }
}
