//
//  Feedback.swift
//  SlangApp
//
//  Created by Kam Lotfull on 08.09.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import Foundation

class Feedback {
    init(name: String?,
         email: String?,
         feedback: String,
         rating: Int) {
        self.contacts = (name != nil ? name! + " " : "") + (email != nil ? email! : "")
        self.feedback = feedback
        self.rating = rating
    }
    
    var contacts: String
    var feedback: String
    var rating: Int
    
    func text() -> String {
        return "Contacts: \(contacts)\nFeedback: \(feedback)\nRating: \(rating)"
    }
}
