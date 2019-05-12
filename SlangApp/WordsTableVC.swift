import UIKit
import CoreData
import Firebase
import FirebaseDatabase

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else {
            return
        }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else {
                continue
            }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

class WordsTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate, CreateWordVCDelegate, UISearchResultsUpdating, UITabBarControllerDelegate, SearchWordByHashtagDelegate, setDictionaryDelegate {
    
    // MARK: - VARS and LETS
    var sectionNames = ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ы", "Э", "Ю", "Я", "#"]
    var wordsBySection = [String: [Word]]()
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    let delegate = UIApplication.shared.delegate as? AppDelegate
    lazy var managedObjectContext: NSManagedObjectContext = {
        return (delegate?.managedObjectContext)!
    }()
    lazy var words: [Word] = {
        return (delegate?.words)!
    }()
    var dictWords = [Word]()
    var filteredWords = [Word]()
    var selectedWord: Word!
    var selectedTabBarIndex: Int!
    var isShuffled = false
    var trendsVC: TrendsTableVC!
    var hudNeeded = true
    var indicator = UIActivityIndicatorView()
    let showWordDetailID = "ShowWordDetail"
    let createEditWordID = "CreateEditWord"
    let ref = Database.database().reference()
    var selectedDict = 0
    @IBOutlet weak var titleButton: UIButton!
    lazy var dictionaries = {
        return (delegate?.dictionaries)!
    }()
    var shuffledIndexes: [Int]!
    var focusSearchBar = false
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        installSearchController()
        installTableView()
        firstFetching()
        setBarTitle(self.dictionaries[selectedDict])
        self.tabBarController?.delegate = self
        selectedTabBarIndex = self.tabBarController?.selectedIndex
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if focusSearchBar {
            focusSearchBar = false
            searchController.searchBar.becomeFirstResponder()
            searchController.isActive = true
            updateSearchResults(for: searchController)
        }
    }

    func setBarTitle(_ name: String) {
        let name = NSMutableAttributedString(string: name)//, attributes: [NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14)!])
        let arrow = NSMutableAttributedString(string: "\u{2304}", attributes: [NSAttributedString.Key.font: UIFont(name: "Georgia", size: 20)!])
        
        let combination = NSMutableAttributedString(attributedString: name)
        combination.append(arrow)
        
        self.titleButton.setAttributedTitle(combination, for: .normal)
    }
    
    func setDictionary(_ dictionary: Int) {
        setBarTitle(self.dictionaries[dictionary])
        if selectedDict != dictionary {
            self.selectedDict = dictionary
            dictWords = words.filter({ (word: Word) -> Bool in
                return (selectedDict == 0) || (word.dictionaryId == selectedDict)
            })
            updateSearchResults(for: searchController)
            shuffledIndexes = Array(0...dictWords.count)
            shuffledIndexes.shuffle()
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tappedTabBarIndex = tabBarController.selectedIndex
        //print("previous: \(selectedTabBarIndex), tapped: \(tappedTabBarIndex)")
        if tappedTabBarIndex == selectedTabBarIndex {
            scrollToHeader()
        }
        selectedTabBarIndex = tappedTabBarIndex
    }
    
    func scrollToHeader() {
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    func installTableView() {
        tableView.register(UINib.init(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "Word")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func installSearchController() {
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        resultsController.tableView.register(UINib.init(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "Word")
        resultsController.tableView.keyboardDismissMode = .onDrag
        searchController.searchBar.placeholder = "Поиск слова"
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWordDetailID {
            if let wordDetailVC = segue.destination as? WordDetailVC {
                wordDetailVC.word = selectedWord
                wordDetailVC.wordsTableVCRef = self
                if trendsVC != nil {
                    wordDetailVC.delegate = trendsVC
                }
                indicator.stopAnimating()
                indicator.hidesWhenStopped = true
            }
        } else if segue.identifier == createEditWordID {
            if let navigationVC = segue.destination as? UINavigationController,
               let createEditWordVC = navigationVC.topViewController as? CreateEditWordVC {
                createEditWordVC.delegate = self
                createEditWordVC.delegate1 = trendsVC
            }
        } else if segue.identifier == "setDictionary" {
            if let setDictionaryVC = segue.destination as? SetDictionaryVC {
                setDictionaryVC.delegate = self
            }
        }
    }
    
    // MARK: - TableView Funcs
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == resultsController.tableView || isShuffled || selectedDict != 0 {
            return 1
        } else {
            return sectionNames.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsController.tableView {
            if filteredWords.count > 4 {
                return filteredWords.count
            } else {
                return filteredWords.count + 1
            }
        } else if isShuffled || selectedDict != 0 {
            return dictWords.count
        } else {
            let wordsKey = sectionNames[section]
            if let sectionWords = wordsBySection[wordsKey] {
                return sectionWords.count
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath) as! WordTableViewCell
        if tableView == resultsController.tableView {
            if filteredWords.count > 4 {
                cell.configure(with: filteredWords[indexPath.row], at: indexPath)
            } else {
                if indexPath.row == filteredWords.count {
                    cell.configure(withName: "Нет желаемого слова?", withDefinition: "Добавьте его сами и помогите найти его другим, нажав на эту ячейку.", at: indexPath)
                } else {
                    cell.configure(with: filteredWords[indexPath.row], at: indexPath)
                    cell.favoriteButton.imageView?.image = (filteredWords[indexPath.row].favorite ? #imageLiteral(resourceName: "star-4") : #imageLiteral(resourceName: "star-3")).withRenderingMode(.alwaysTemplate)
                }
            }
        } else if isShuffled {
            cell.configure(with: dictWords[shuffledIndexes[indexPath.row]], at: indexPath)
        } else if selectedDict != 0 {
            cell.configure(with: dictWords[indexPath.row], at: indexPath)
        } else if tableView == self.tableView {
            let wordKey = sectionNames[indexPath.section]
            if let sectionWords = wordsBySection[wordKey] {
                cell.configure(with: sectionWords[indexPath.row], at: indexPath)
            }
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hudNeeded {
            indicator.startAnimating()
            indicator.backgroundColor = UIColor.white
        }
        if tableView == resultsController.tableView {
            if filteredWords.count <= 4,
               indexPath.row == filteredWords.count {
                addNewWordButtonPressed()
                return
            } else {
                selectedWord = filteredWords[indexPath.row]
            }
        } else if isShuffled {
            selectedWord = words[shuffledIndexes[indexPath.row]]
        } else if selectedDict != 0 {
            selectedWord = dictWords[indexPath.row]
        } else {
            let wordsKey = sectionNames[indexPath.section]
            if let sectionWords = wordsBySection[wordsKey] {
                selectedWord = sectionWords[indexPath.row]
            }
        }
        //print("didSelectRowAt")
        self.performSegue(withIdentifier: showWordDetailID, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == resultsController.tableView || isShuffled || selectedDict != 0 {
            return nil
        } else {
            return sectionNames
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let temp = sectionNames as NSArray
        return temp.index(of: title)
    }
    
    // MARK: - searching funcs
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.lowercased(with: NSLocale.current)
        if text == nil || text == "" {
            filteredWords = dictWords.filter({ (word: Word) -> Bool in
                return (selectedDict == 0) || (word.dictionaryId == selectedDict)
            })
            self.titleButton.setTitle(self.dictionaries[self.selectedDict], for: .normal)
            self.tableView.reloadData()
        } else if text?.first! == "#" {
            filteredWords = dictWords.filter({ (word: Word) -> Bool in
                if (selectedDict == 0) || (word.dictionaryId == 1) {
                    if let wordHashtags = word.hashtags {
                        let hashtag = wordHashtags.components(separatedBy: " ")[0]
                        return hashtag.lowercased() == text!.lowercased()
                    }
                }
                return false
            })
            titleButton.setTitle(text!, for: .normal)
            resultsController.tableView.reloadData()
        } else {
            var tempWords = [Word]()
            filteredWords = dictWords.filter({ (word: Word) -> Bool in
                if (selectedDict == 0) || (word.dictionaryId == selectedDict) {
                    let wordName = word.name.lowercased(with: NSLocale.current)
                    if wordName.hasPrefix(text!) {
                        return true
                    } else if wordName.contains(text!) {
                        tempWords.append(word)
                    }
                }
                return false
            })
            filteredWords.append(contentsOf: tempWords)
            titleButton.setTitle("\(text!) (\(filteredWords.count) слов)", for: .normal)
            resultsController.tableView.reloadData()
        }
    }
    
    func firstFetching() {
        dictWords = words
        shuffledIndexes = Array(0...dictWords.count)
        shuffledIndexes.shuffle()
        calculateWordsBySections()
        filteredWords = dictWords
        tableView.reloadData()
    }
    
    func calculateWordsBySections() {
        for index in 0..<sectionNames.count {
            wordsBySection[sectionNames[index]] = [Word]()
        }
        for word in words {
            let key = "\(word.name[word.name.startIndex])"
            if wordsBySection[key] != nil {
                wordsBySection[key]!.append(word)
            } else if "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(key) {
                wordsBySection["F"]?.append(word)
            } else {
                wordsBySection["#"]?.append(word)
            }
        }
    }
    
    func updateSearch(_ wordName: String) {
        searchController.searchBar.text? = wordName
        focusSearchBar = true
    }
    
    // MARK: - WordTableViewCellDelegate
    func shareWord(word: Word) {
        let text = word.textViewString()
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func reloading(indexPath: IndexPath) {
        do {
            try managedObjectContext.save()
        } catch {
            print("There was managedObjectContext.save() error")
        }
        //resultsController.tableView.reloadRows(at: [indexPath], with: .none)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - CreateWordVCDelegate
    func createEditWordVCDidCancel(_ controller: CreateEditWordVC) {
        dismiss(animated: true, completion: nil)
    }
    
    func createEditWordVCDone(_ controller: CreateEditWordVC, adding word: Word) {
        tableView.reloadData()
        saveManagedObjectContext()
        dismiss(animated: true, completion: nil)
    }
    
    func createEditWordVCDone(_ controller: CreateEditWordVC, editing word: Word) {
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView != resultsController.tableView && !isShuffled {
            let wordKey = sectionNames[indexPath.section]
            if var sectionWords = wordsBySection[wordKey] {
                managedObjectContext.delete(sectionWords[indexPath.row])
                wordsBySection[wordKey]!.remove(at: indexPath.row)
            }
            saveManagedObjectContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("error tableView(_ tableView: UITableView, commit editingStyle \(error)")
        }
    }
    
    @IBAction func addNewWordButtonPressed() {
        performSegue(withIdentifier: createEditWordID, sender: nil)
    }
    
    @IBAction func shufflePressed() {
        if isShuffled {
            isShuffled = false
            self.tableView.reloadData()
            shuffleButton.title = "Случайно"
        } else {
            shuffledIndexes.shuffle()
            isShuffled = true
            self.tableView.reloadData()
            shuffleButton.title = "А-Я"
        }
        scrollToHeader()
    }
    
    @IBOutlet weak var dictPicker: UIPickerView!
    
    @IBOutlet weak var shuffleButton: UIBarButtonItem!
}
