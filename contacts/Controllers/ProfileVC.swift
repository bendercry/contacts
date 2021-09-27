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
    
    
    weak var delegate: DataEnteredDelegate? = nil
    private let validation: Validation
    private let acceptImage = UIImage(systemName: "checkmark")
    private let cancelImage = UIImage(systemName: "xmark")
    private let editImage = UIImage(systemName: "pencil.and.ellipsis.rectangle")
    
    init(validation: Validation){
        self.validation = validation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.validation = Validation()
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        updateUI()
        birthdayDateField.maskTemplate = "dd/MM/YYYY"
        firstNameField.autocapitalizationType = .sentences
        secondNameField.autocapitalizationType = .sentences
    }
    //MARK: @IBAOutlets
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
    @IBOutlet weak var birthdayDateField: AKMaskField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var favoriteBtn: UIButton!
    
    @IBOutlet weak var fieldStackView: UIStackView!
    @IBOutlet weak var labelStackView: UIStackView!
    
    //MARK: @IBActions funcs
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
   
    
    //MARK: Update UI funcs
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
            firstNameLabel.text = currentPerson?.firstName
            secondNameLabel.text = currentPerson?.secondName
            companyLabel.text = currentPerson?.company
            phoneNumberLabel.text = currentPerson?.number
            birthdayDateLabel.text = currentPerson?.dateOfBirth
            emailLabel.text = currentPerson?.email
            
            firstNameField.text = currentPerson?.firstName
            secondNameField.text = currentPerson?.secondName
            companyField.text = currentPerson?.company
            phoneNumberField.text = currentPerson?.number
            birthdayDateField.text = currentPerson?.dateOfBirth
            emailField.text = currentPerson?.email
            
            if currentPerson!.isFavorite {
                favoriteBtn.setImage(UIImage(named: "starFill"), for: .normal)
                isFavorite = true
            }
            else {
                favoriteBtn.setImage(UIImage(named: "starUnfill"), for: .normal)
                isFavorite = false
            }
        }
    }
    @objc private func editProfileVC(){
        isCanEdit = !isCanEdit
        updateUI()
    }
    @objc private func acceptEditProfileVC(){
        if validateInfo(){
            isCanEdit = false
            updateUI()
            delegate?.userDidEnterInformation(backPassedPerson: currentPerson!)
        }
    }
    @objc private func cancelEditProfileVC(){
        isCanEdit = false
        if currentPerson == nil{
            self.performSegue(withIdentifier: "toContactVC", sender: self)
        }
        updateUI()
    }
   
    
}
//MARK: Validation
extension ProfileVC{
    func validateInfo()->Bool{
        do{
            let date = try validation.validateBirthdayDate(birthdayDateField.text)
            let email = try validation.validateEmail(emailField.text)
            let number = try validation.validateNumber(phoneNumberField.text)
            let firstName = try validation.validateFirstName(firstNameField.text)
            let secondName = try validation.validateSecondName(secondNameField.text)
            let company = try validation.validateCompany(companyField.text)
            currentPerson = Person(firstName: firstName, secondName: secondName, dateOfBirth: date, company: company, email: email, number: number, isFavorite: isFavorite)
            return true
        }
        catch{
            present(error)
            return false
        }
    }
}
//MARK: Alerts setup
extension UIViewController {
    
    private func present(_ dismissableAlert: UIAlertController) {
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        dismissableAlert.addAction(dismissAction)
        present(dismissableAlert, animated: true)
    }
    
    func presentAlert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert)
    }
    
    func present(_ error: Error) {
        presentAlert(with: error.localizedDescription)
    }
}
