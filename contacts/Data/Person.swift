//
//  Person.swift
//  contacts
//
//  Created by Benderskii Kirill on 23.09.2021.
//

import Foundation

struct Person: Equatable{
    var firstName: String?
    var secondName : String?
    var dateOfBirth: String?
    var company: String?
    var email: String?
    var number: String?
    var isFavorite: Bool
    
    init(firstName: String, secondName: String, dateOfBirth: String, company: String, email: String, number: String, isFavorite: Bool){
        self.firstName = firstName
        self.secondName = secondName
        self.dateOfBirth = dateOfBirth
        self.company = company
        self.email = email
        self.number = number
        self.isFavorite = isFavorite
    }
    
}
