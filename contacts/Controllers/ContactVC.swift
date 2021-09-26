//
//  ViewController.swift
//  contacts
//
//  Created by Benderskii Kirill on 21.09.2021.
//

import UIKit
import CoreData

class ContactVC: UIViewController, DataEnteredDelegate{
    //MARK: Delegate from ProfileVC
    func userDidEnterInformation(backPassedPerson: Person) {
        //i dont know how to do it clear without hardcoding 
        if sentPerson != nil {
            if showFavoriteOnly == .no{
                personArray[indexSentPerson] = backPassedPerson
            }
            else{
                for i in 0...personArray.count{
                    if personArray[i] == sentPerson{
                        personArray[i] = backPassedPerson
                        break
                    }
                }
            }
        }
        else{
            personArray.append(backPassedPerson)
        }
        prepareData(isFavorite: showFavoriteOnly)
        tableView.reloadData()
        
    }
    

    //MARK: Variables
    private var navBarTitle = "All contacts"
    private var searchController = UISearchController(searchResultsController: nil)
    private var favoriteImage: UIImage = UIImage(named: "starUnfill")!
    private var addImage: UIImage = UIImage(systemName: "plus.circle")!
    
    private var indexSentPerson : Int = 0
    private var sentPerson: Person?
    private var showFavoriteOnly: IsFavoriteEnum = .no
    private var personArray: [Person] = []
    private var filteredPersonArray: [Person] = []
    private var onlyFavoriteContactsArray: [Person] = []
    private var contactFavoritesDictionary = [String: Bool]()
    private let indexLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var contactNamesDictionary = [String: [String]]()
    var indexLettersInContactsArray = [String]()
    var namesArray = [String]()
    
    @IBOutlet weak private var tableView: UITableView!
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExample()
        tableView.delegate = self
        tableView.dataSource = self
        setupNavBar()
        prepareData(isFavorite: showFavoriteOnly)
    }

    
    //MARK: Setup UI and example
    func setupExample(){
        personArray.append(Person(firstName: "Kirill", secondName: "Benderskii", dateOfBirth: "28/08/2000", company: "ISTU", email: "example@mail.ru", number: "+7 (964) 184-03-10",isFavorite: true))
        personArray.append(Person(firstName: "Peter", secondName: "Parker", dateOfBirth: "28/09/2000", company: "Daily Bugle", email: "example@mail.ru", number: "+7 (964) 184-03-10",isFavorite: false))
        personArray.append(Person(firstName: "Mary", secondName: "Jane", dateOfBirth: "28/10/2000", company: "Cafe", email: "example@mail.ru", number: "+7 (964) 184-03-10",isFavorite: true))
        personArray.append(Person(firstName: "Otto", secondName: "Octavius", dateOfBirth: "28/11/2000", company: "Oscorp", email: "example@mail.ru", number: "+7 (964) 184-03-10",isFavorite: true))
        personArray.append(Person(firstName: "Harry", secondName: "Osborn", dateOfBirth: "28/12/2000", company: "Oscorp", email: "example@mail.ru", number: "+7 (964) 184-03-10",isFavorite: false))
    }
    
    func setupNavBar(){
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = navBarTitle
        
        let favoriteBtn = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(showFavorite))
        favoriteBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let addBtn = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(navigateToProfileVC))
        addBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.navigationItem.leftBarButtonItem = favoriteBtn
        self.navigationItem.rightBarButtonItem = addBtn
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
    }
    @objc private func showFavorite(){
        switch showFavoriteOnly {
        case .no:
            showFavoriteOnly = .yes
            navBarTitle = "Favorites"
            favoriteImage = UIImage(named: "starFill")!
            setupNavBar()
            prepareData(isFavorite: showFavoriteOnly)
            tableView.reloadData()
            
        case .yes:
            showFavoriteOnly = .no
            navBarTitle = "All contacts"
            favoriteImage = UIImage(named: "starUnfill")!
            setupNavBar()
            prepareData(isFavorite: showFavoriteOnly)
            tableView.reloadData()
        }
    }
    
    @objc private func navigateToProfileVC(){
        self.performSegue(withIdentifier: "addNewToProfileVC", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editToProfileVC"{
            guard let destinationProfileVC = segue.destination as? ProfileVC else {return}
            destinationProfileVC.isCanEdit = false
            destinationProfileVC.isFavorite = sentPerson!.isFavorite
            destinationProfileVC.currentPerson = sentPerson
            destinationProfileVC.delegate = self
            
        }
        else if segue.identifier == "addNewToProfileVC"{
            guard let destinationProfileVC = segue.destination as? ProfileVC else {return}
            destinationProfileVC.isCanEdit = true
            destinationProfileVC.isFavorite = false
            destinationProfileVC.delegate = self
            sentPerson = nil
           
            
        }
    }
    
     
}

//MARK: Extensions for tableView
extension ContactVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var count = Int()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            count = 1
        } else {
            count = contactNamesDictionary.keys.count
        }
        
        return count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            count = filteredPersonArray.count
        } else {
            let letter = indexLettersInContactsArray[section]
            
            if let names = contactNamesDictionary[letter] {
                count = names.count
            }
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactCell else { return UITableViewCell() }
        
        var isFavoriteBool = Bool()
        var fullName = String()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if let firstName = filteredPersonArray[indexPath.row].firstName?.capitalized, let lastName = filteredPersonArray[indexPath.row].secondName?.capitalized {
                
                let favoriteBool = filteredPersonArray[indexPath.row].isFavorite
                let text = "\(firstName) \(lastName)"
               
                fullName = text
                isFavoriteBool = favoriteBool
            }
            
        }else{
            let letter = indexLettersInContactsArray[indexPath.section]
            
            if var names = contactNamesDictionary[letter.uppercased()] {
                names = names.sorted()
                
                let text = names[indexPath.row]
                fullName = text
                let favoriteBool = contactFavoritesDictionary[text]
                isFavoriteBool = favoriteBool!
            }
        }
        cell.contactName.text = fullName
        cell.isFavoriteImage.isHidden = !(isFavoriteBool)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        personArray.sort{
            $0.firstName! < $1.firstName!
        }
        let indexPath = tableView.indexPathForSelectedRow
        var selectedRow = indexPath!.row
        for i in 0..<indexPath!.section {
            selectedRow += self.tableView.numberOfRows(inSection: i)
        }
        if showFavoriteOnly == .no{
            sentPerson = personArray[selectedRow]
        }
        else{
            sentPerson = onlyFavoriteContactsArray[selectedRow]
        }
        indexSentPerson = selectedRow
        self.performSegue(withIdentifier: "editToProfileVC", sender: self)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let sortedDict = contactNamesDictionary.sorted { $0.key < $1.key }
            let dictKey = Array(sortedDict[indexPath.section].key)
            
            let arrayCount = contactNamesDictionary[String(dictKey)]?.count
            
            if arrayCount == 1 { // remove section
                
                self.removeContact(atIndexPath: indexPath)
                self.prepareData(isFavorite: showFavoriteOnly)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                
                tableView.deleteSections(indexSet as IndexSet, with: .automatic)
                tableView.endUpdates()
                
            } else {
                
                self.removeContact(atIndexPath: indexPath)
                self.prepareData(isFavorite: showFavoriteOnly)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchController.isActive && searchController.searchBar.text != "" || showFavoriteOnly == .yes {
            return false
        }
        
        return true
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionTitle = String()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            sectionTitle = "Top Name Matches"
        } else {
            sectionTitle = indexLettersInContactsArray[section]
        }
        
        return sectionTitle
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexLetters
    }
}

//MARK: Search Bar
extension ContactVC: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContacts(text: searchController.searchBar.text!)
    }
    
    private func filterContacts(text: String, scope: String = "All") {
        
        filteredPersonArray = personArray.filter({ (person) -> Bool in
            
            let fullName = "\(person.firstName?.lowercased() ?? "") \(person.secondName?.lowercased() ?? "")"
            
            return fullName.contains(text.lowercased())
        })
        
        tableView.reloadData()
    }
}

//MARK: Data managment
extension ContactVC {
    func prepareData(isFavorite: IsFavoriteEnum){
        namesArray.removeAll()
        personArray = personArray.sorted(by: { (a, b) -> Bool in
            return a.firstName! < b.firstName!
        })
        onlyFavoriteContactsArray = personArray.filter( {$0.isFavorite == true})
        var tempContactsArray: [Person] = []
        
        if showFavoriteOnly == .yes {
            tempContactsArray = onlyFavoriteContactsArray
        } else if showFavoriteOnly == .no {
            tempContactsArray = personArray
        }
        for i in tempContactsArray {
            
            var fullName = String()
            fullName = "\(i.firstName!) \(i.secondName!)"
                   
            let isFavorite = i.isFavorite
            namesArray.append(fullName)
            contactFavoritesDictionary[fullName] = isFavorite
        }
        createNameDictionary()
    }
    
    func createNameDictionary() {
        
        contactNamesDictionary.removeAll()
        for name in namesArray {

            let firstLetter = "\(name[name.startIndex])"
            let uppercasedLetter = firstLetter.uppercased()
            
            if var separateNamesArray = contactNamesDictionary[uppercasedLetter] {
                separateNamesArray.append(name)
                contactNamesDictionary[uppercasedLetter] = separateNamesArray
            } else {
                contactNamesDictionary[uppercasedLetter] = [name]
            }
        }
        
        indexLettersInContactsArray = [String](contactNamesDictionary.keys)
        indexLettersInContactsArray = indexLettersInContactsArray.sorted()
    }
    
    private func removeContact(atIndexPath indexPath: IndexPath) {
               
        var selectedRow = indexPath.row
        for i in 0..<indexPath.section {
            selectedRow += self.tableView.numberOfRows(inSection: i)
        }
        personArray = personArray.sorted(by: { (a, b) -> Bool in
            return a.firstName! < b.firstName!
        })
        personArray.remove(at: selectedRow)
        namesArray.remove(at: selectedRow)
    }
}
