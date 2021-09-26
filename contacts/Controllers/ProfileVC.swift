//
//  ProfileVC.swift
//  contacts
//
//  Created by Kirill Benderskii on 24.09.2021.
//

import UIKit
import AKMaskField

protocol DataEnteredDelegate: AnyObject {
    func userDidEnterInformation(backPassedPerson: Person)
}

class ProfileVC: UIViewController {
    var isFavorite = false
    var isCanEdit = false
    var currentPerson: Person?
    var copyPerson: Person?
    
    weak var delegate: DataEnteredDelegate? = nil
    private let acceptImage = UIImage(systemName: "checkmark")
    private let cancelImage = UIImage(systemName: "xmark")
    private let editImage = UIImage(systemName: "pencil.and.ellipsis.rectangle")
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        updateUI()
        copyPerson = currentPerson
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var birthdayDateLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var secondNameField: UITextField!
    @IBOutlet weak var phoneNumberField: AKMaskField!
    @IBOutlet weak var companyField: UITextField!
    @IBOutlet weak var birthdayDateField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var favoriteBtn: UIButton!
    
    @IBOutlet weak var fieldStackView: UIStackView!
    @IBOutlet weak var labelStackView: UIStackView!
    
    @IBAction func favoriteBtnPressed(_ sender: Any) {
        if isCanEdit{
            if isFavorite {
                favoriteBtn.setImage(UIImage(named: "starUnfill"), for: .normal)
                isFavorite = false
            }
            else {
                favoriteBtn.setImage(UIImage(named: "starFill"), for: .normal)
                isFavorite = true
            }
        }
    }
    
    
    private func setupNavBar(){
        if(isCanEdit){
            let acceptBtn = UIBarButtonItem(image: acceptImage, style: .plain, target: self, action: #selector(acceptEditProfileVC))
            let cancelBtn = UIBarButtonItem(image: cancelImage, style: .plain, target: self, action: #selector(cancelEditProfileVC))
            acceptBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cancelBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            navigationItem.rightBarButtonItem = acceptBtn
            navigationItem.leftBarButtonItem = cancelBtn
        }
        else{
            let editBtn = UIBarButtonItem(image: editImage, style: .plain, target: self, action: #selector(editProfileVC))
            editBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationItem.rightBarButtonItem = editBtn
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
            
        }
    }
    private func updateUI(){
        
        if isCanEdit{
            labelStackView.isHidden = true
            fieldStackView.isHidden = false
        }
        else{
            fieldStackView.isHidden = true
            labelStackView.isHidden = false
        }
        setupNavBar()
        if currentPerson == nil{
            
        }
        else {
            firstNameLabel.text = currentPerson!.firstName
            secondNameLabel.text = currentPerson!.secondName
            companyLabel.text = currentPerson!.company
            phoneNumberLabel.text = format(with: "+X (XXX) XXX-XX-XX", phone: currentPerson!.number ?? "")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/YYYY"
            birthdayDateLabel.text = dateFormatter.string(from: currentPerson!.dateOfBirth ?? Date(timeIntervalSinceReferenceDate: 0))
            emailLabel.text = currentPerson!.email
            
            firstNameField.text = currentPerson!.firstName
            secondNameField.text = currentPerson!.secondName
            companyField.text = currentPerson!.company
            phoneNumberField.text = format(with: "+X (XXX) XXX-XX-XX", phone: currentPerson!.number ?? "")
            birthdayDateField.text = dateFormatter.string(from: currentPerson!.dateOfBirth ?? Date(timeIntervalSinceReferenceDate: 0))
            emailField.text = currentPerson?.email
            if currentPerson!.isFavorite {
                favoriteBtn.setImage(UIImage(named: "starFill"), for: .normal)
                isFavorite = false
            }
            else {
                favoriteBtn.setImage(UIImage(named: "starUnfill"), for: .normal)
                isFavorite = true
            }
        }
    }
    @objc private func editProfileVC(){
        isCanEdit = !isCanEdit
        updateUI()
    }
    @objc private func acceptEditProfileVC(){
        delegate?.userDidEnterInformation(backPassedPerson: currentPerson!)
        isCanEdit = false
        updateUI()
    }
    @objc private func cancelEditProfileVC(){
        isCanEdit = false
        if currentPerson == nil{
            self.performSegue(withIdentifier: "toContactVC", sender: self)
        }
        updateUI()
    }
   
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
