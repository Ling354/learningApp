//
//  ContentViewModel.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-03-23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Firebase

class ContentView: ObservableObject {
    
    //Authentication
    @Published var loggedIn = false
    
    // Reference to Firebase Database
    let db = Firestore.firestore()
    
    // List of Modules
    @Published var modules = [Module]()
    
    // Current Module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current Lesson
    @Published var currentLesson: Lessons?
    var currentLessonIndex = 0
    
    // Current question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current lesson description
    @Published var codeText = NSAttributedString()
    
    var styleData: Data?
    
    // Current selected content and test
    @Published var currentContentSelected:Int?
    @Published var currentTestSelected:Int?
    
    init() {
    }
    
    // MARK: - Account Methods
    func checkLogin() {
        
        // Check to see if there is a current user and determin logged in status
        loggedIn = Auth.auth().currentUser != nil ? true : false
        
        // Check if user meta data has been fetched.
        if UserService.shared.user.name == "" {
            getUserData()
        }
        
    }
    
    // MARK: - Data Methods
    
    func saveData (writeToDatabase:Bool = false) {
        
        if let loggedInUser = Auth.auth().currentUser {
            
            // Save the progress locally
            let user = UserService.shared.user
            
            user.lastModule = currentModuleIndex
            user.lastLesson = currentLessonIndex
            user.lastQuestion = currentQuestionIndex
            
            if writeToDatabase == true {
                
                // Save to the database
                let db = Firestore.firestore()
                let ref = db.collection("users").document(loggedInUser.uid)
                ref.setData(["lastModule": user.lastModule ?? NSNull(),
                             "lastLesson": user.lastLesson ?? NSNull(),
                             "lastQuestion": user.lastQuestion ?? NSNull()], merge: true)
                
            }
            
        }
        
    }
    
    func getUserData() {
        
        // Check that there is a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        // get the meta data for user
        let db = Firestore.firestore()
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        ref.getDocument { snapshot, error in
            guard error == nil else {
                return
            }
            
            // Parse the data out and set the user meta data
            let data = snapshot!.data()
            let user = UserService.shared.user
            user.lastModule = data?["lastModule"] as? Int
            user.lastLesson = data?["lastLesson"] as? Int
            user.lastQuestion = data?["lastQuestion"] as? Int
        }
    }
    
    func getLessons(module: Module, completion: @escaping () -> Void) {
        
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("lessons")
        
        // Get documents
        collection.getDocuments {snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Creates an array of lessons
                var lessons = [Lessons]()
                
                // Loops trhough the documents returned
                for doc in snapshot!.documents {
                    
                    // New lesson
                    var l = Lessons()
                    
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    
                    // Add the lessons to array
                    lessons.append(l)
                    
                }
                
                // Setting the lessons to the module
                // Loop through published modules array and find the one that matches the id of the copy that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    //Find the module we want
                    if m.id == module.id {
                        
                        // Set the lessons
                        self.modules[index].content.lessons = lessons
                        
                        // Call the completion closure
                        completion()
                        
                    }
                }
            }
        }
    }
    
    func getQuestions(module: Module, completion: @escaping () -> Void) {
        
        // Specify the path
        let collection = db.collection("modules").document(module.id).collection("questions")
        
        //Get documents
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Create an array of questions
                var question = [Question]()
                
                // Loop through the questions
                for doc in snapshot!.documents {
                    
                    var q = Question()
                    
                    q.id = doc["id"] as? String ?? UUID().uuidString
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.answers = doc["answers"] as? [String] ?? [""]
                    
                    // Append questions array
                    question.append(q)
                    
                }
                
                for (index, m) in self.modules.enumerated() {
                    
                    if m.id == module.id {
                        
                        // Set the questions
                        self.modules[index].test.questions = question
                        
                        // Call completion
                        completion()
                    }
                    
                }
            }
            
            
        }
        
    }
    
    
    func getDatabaseModules() {
        
        // Parse local json data
        getLocalStyles()
        
        // Specify path
        let collection = db.collection("modules")
        
        // Get Documents
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Create an array
                var modules = [Module]()
                
                //Loop through the documents returned
                for doc in snapshot!.documents {
                    
                    // Create a new module instance
                    var m = Module()
                    
                    // Parse out the value from the document into the module instance
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    // Parse the lesson content
                    let contentMap = doc["content"] as! [String:Any]
                    
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""
                    
                    // Parse the test content
                    let testMap = doc["test"] as! [String:Any]
                    
                    m.test.id = contentMap["id"] as? String ?? ""
                    m.test.description = testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                    
                    // Add it to our array
                    modules.append(m)
                    
                }
                
                // Assign our modules to
                DispatchQueue.main.async {
                    self.modules = modules
                }
            }
        }
    }
    
    func getLocalStyles() {
        /*
         //get a url to the json file
         let jsonUrl = Bundle.main.url(forResource: "data",  withExtension: "json")
         
         do {
         // Read the file into a data object
         let jsonData = try Data(contentsOf: jsonUrl!)
         
         let jsonDecoder = JSONDecoder()
         
         let modules = try jsonDecoder.decode([Module].self, from: jsonData)
         
         self.modules = modules
         }
         catch {
         
         print("Couldn't parse local data")
         
         }
         */
        
        // Parse the style data
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            
            // Read the file into a data object
            let styleData = try Data(contentsOf: styleUrl!)
            
            self.styleData = styleData
            
        }
        catch {
            print("Could not parse style data")
        }
    }
    
    func getRemoteData() {
        
        // String path
        let urlString = "https://ling354.github.io/learningAppData/data2.json"
        
        // create a url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            return
        }
        
        // Create a url request
        let request = URLRequest(url: url!)
        
        // Get the session and kick off task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            // Check if there is an error
            guard error == nil else {
                // There was an error
                return
            }
            
            do {
                // Handle the response
                let decorder = JSONDecoder()
                
                // Decode
                let modules = try decorder.decode([Module].self, from: data!)
                
                // Append parsed modules into modules property
                self.modules += modules
            }
            catch {
                // Couldn't parse data
            }
        }
        
        dataTask.resume()
    }
    
    // MARK: - Module navigation methods
    func beginModule (_ moduleid:String) {
        
        // Find the index for this module id
        for index in 0..<modules.count {
            
            if modules[index].id == moduleid {
                
                // Found the matching module
                currentModuleIndex = index
                break
            }
        }
        
        // Set the current module
        currentModule = modules[currentModuleIndex]
        
    }
    
    func beginLesson(_ lessonIndex: Int) {
        
        // Check that the lesson index is within range of module lessons
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex = lessonIndex
        }
        else {
            currentLessonIndex = 0
        }
        
        // Set current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        codeText = addStyling(currentLesson!.explanation)
    }
    
    func nextLesson() {
        
        // Advance the lesson index
        currentLessonIndex += 1
        
        // Check that it is in within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            
            // Set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
            
        }
        else {
            // Reset the lesson state
            currentLessonIndex = 0
            currentLesson = nil
        }
        
        // Save the progress
        saveData()
    }
    
    func hasNextLesson () -> Bool {
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
        
    }
    
    func beginTest (_ moduleId:String) {
        
        // Set current module
        beginModule(moduleId)
        
        // Set the current question
        currentQuestionIndex = 0
        
        // If there are questions, set the current question to the first one
        if currentModule?.test.questions.count ?? 0 > 0 {
            currentQuestion = currentModule?.test.questions[currentQuestionIndex]
            
            // Set question for test
            codeText = addStyling(currentQuestion!.content)
        }
    }
    
    func nextQuestion() {
        
        // Advance the question index
        currentQuestionIndex += 1
        
        // Check that it's within the range of questions
        if currentQuestionIndex < currentModule!.test.questions.count {
            
            // Set the current question
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
            
        } else {
            // If not, then reset the properties
            currentQuestionIndex = 0
            currentQuestion = nil
        }
        
        // Save progress
        saveData()
    }
    
    // MARK: Code Styling
    
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        // Add styling data
        if styleData != nil {
            data.append(styleData!)
        }
        
        // Add the html data
        data.append(Data(htmlString.utf8))
        
        // convert to attribute string
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil) {
            resultString = attributedString
        }
        
        return resultString
        
    }
}
