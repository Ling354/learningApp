//
//  UserService.swift
//  LearningApp
//
//  Created by Jeff Lingley on 2022-06-13.
//

import Foundation

class UserService {
    
    var user = User()
    static var shared = UserService()
    
    private init() {
        
    }
    
}
