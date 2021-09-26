//
//  Validation.swift
//  contacts
//
//  Created by Kirill Benderskii on 26.09.2021.
//

import Foundation
struct Validation{
    private let emailPattern = #"^\S+@\S+\.\S+$"#
    private let numberPattern = #"\+7 \(\d\d\d\) \d\d\d-\d\d-\d\d"#
    private let letters = NSCharacterSet.letters
    func validateBirthdayDate(_ date: String?) throws->String{
        guard let date = date else { throw ValidationError.invalidDate }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard (dateFormatter.date(from: date) != nil) else {throw ValidationError.invalidDate}
            
        return date
    }
    func validateEmail(_ email: String?) throws->String{
        guard let email = email else {throw ValidationError.invalidEmail}
        let result = email.range(of: emailPattern, options: .regularExpression)
        guard (result != nil) else {throw ValidationError.invalidEmail}
        return email
    }
    func validateNumber(_ number: String?) throws->String{
        guard let number = number else {throw ValidationError.invalidNumber}
        let result = number.range(of: numberPattern, options: .regularExpression)
        guard (result != nil) else {throw ValidationError.invalidNumber}
        return number
    }
    func validateFirstName(_ firstName:String?) throws->String{
        guard let firstName = firstName else { throw ValidationError.invalidFirstName}
        let range = firstName.rangeOfCharacter(from: letters)
        guard (range != nil) else {throw ValidationError.invalidFirstName}
        return firstName
    }
    func validateSecondName(_ secondName:String?) throws->String{
        guard let secondName = secondName else { throw ValidationError.invalidSecondName}
        
        return secondName
    }
    func validateCompany(_ company:String?) throws->String{
        guard let company = company else { throw ValidationError.invalidCompany}
        
        return company
    }
}

enum ValidationError: LocalizedError {
    case invalidFirstName
    case invalidSecondName
    case invalidCompany
    case invalidDate
    case invalidEmail
    case invalidNumber
    var errorDescription: String?{
        switch  self {
        case .invalidFirstName:
            return "You have entered an invalid first name"
        case .invalidSecondName:
            return "You have entered an invalid second name"
        case .invalidCompany:
            return "You have entered an invalid company"
        case .invalidNumber:
            return "You have entered an invalid phone number"
        case .invalidDate:
            return "You have entered an invalid birthday date"
        case .invalidEmail:
            return "Your email is incorrect"
        }
    }
}
