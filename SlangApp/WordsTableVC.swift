
import UIKit
import CoreData
import Firebase
import FirebaseDatabase

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

class WordsTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate, CreateWordVCDelegate, UISearchResultsUpdating, UITabBarControllerDelegate, SearchWordByHashtagDelegate {
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewDidLoad")
        installSearchController()
        installTableView()
        firstFetching()
        self.tabBarController?.delegate = self
        selectedTabBarIndex = self.tabBarController?.selectedIndex
        words.shuffle()
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
            //print("prepare(for segue) in WordsTableVC")
            if let wordDetailVC = segue.destination as? WordDetailVC {
                wordDetailVC.managedObjectContext = managedObjectContext
                wordDetailVC.word = selectedWord
                
                if trendsVC != nil {
                    //print("wordDetailVC.delegate = trendsVC")
                    wordDetailVC.delegate = trendsVC
                } else {
                    //print("wordDetailVC.delegate = else nil")
                }
                
                indicator.stopAnimating()
                indicator.hidesWhenStopped = true
            }
        } else if segue.identifier == createEditWordID {
            if let navigationVC = segue.destination as? UINavigationController,
                let createEditWordVC = navigationVC.topViewController as? CreateEditWordVC {
                createEditWordVC.managedObjectContext = managedObjectContext
                createEditWordVC.delegate = self
                createEditWordVC.delegate1 = trendsVC
            }
        }
    }
    
    // MARK: - TableView Funcs
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == resultsController.tableView || isShuffled {
            return 1
        } else {
            return sectionNames.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsController.tableView {
            return filteredWords.count
        } else if isShuffled {
            return words.count
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
                    cell.favoriteButton.imageView?.image = filteredWords[indexPath.row].favorite ? #imageLiteral(resourceName: "purpleStarFilled") : #imageLiteral(resourceName: "purpleStar")

                    //print("indexPath.row: \(indexPath.row)")
                    //print("word.name: \(filteredWords[indexPath.row].name)")
                    
                }
            }
        } else if isShuffled {
            cell.configure(with: words[indexPath.row], at: indexPath)
        } else if tableView == self.tableView {
            let wordKey = sectionNames[indexPath.section]
            if let sectionWords = wordsBySection[wordKey] {
                cell.configure(with: sectionWords[indexPath.row], at: indexPath)
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hudNeeded {
            indicator.startAnimating()
            indicator.backgroundColor = UIColor.white
        }
        if tableView == resultsController.tableView {
            if filteredWords.count < 4,
                indexPath.row == filteredWords.count {
                addNewWordButtonPressed()
                return
            } else {
                selectedWord = filteredWords[indexPath.row]
            }
        } else if isShuffled {
            selectedWord = words[indexPath.row]
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
        if tableView == resultsController.tableView || isShuffled {
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
            filteredWords = sortedWords
            titleButton.setTitle("Словарь сленг-слов", for: .normal)
        } else {
            var tempWords = [Word]()
            filteredWords = sortedWords.filter({ (word:Word) -> Bool in
                if word.name.lowercased(with: NSLocale.current).hasPrefix(text!) {
                    return true
                } else {
                    if word.name.lowercased(with: NSLocale.current).contains(text!) {
                        tempWords.append(word)
                    }
                    return false
                }
            })
            filteredWords.append(contentsOf: tempWords)
            //filteredWords.sort(by: beginsWithWordLettersSort)
            titleButton.setTitle(text, for: .normal)
        }
        resultsController.tableView.reloadData()
    }
    func firstFetching() {
        let nameBeginsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        do {
            sortedWords = (try managedObjectContext.fetch(nameBeginsFetch) as! [Word])
            sortedWords.sort(by: sorting)
        } catch {
            fatalError("Failed to fetch words: \(error)")
        }
        words = sortedWords
        calculateWordsBySections()
        filteredWords = words
        tableView.reloadData()
    }
    func sorting(word1: Word, word2: Word) -> Bool {
        return word1.name.lowercased().localizedCaseInsensitiveCompare(word2.name.lowercased()) == .orderedAscending
    }
    func calculateWordsBySections() {
        for index in 0 ..< sectionNames.count {
            wordsBySection[sectionNames[index]] = [Word]()
        }
        for word in words {
            if word.name == "" {
                managedObjectContext.delete(word)
                continue }
            let key = "\(word.name[word.name.startIndex])"
            if wordsBySection[key] != nil {
                wordsBySection[key]!.append(word)
            } else {
                wordsBySection["#"]?.append(word)
            }
        }
    }
    func updateSearchResultsByHashtag(_ hashtag: String) {
        
    }
    
    // MARK: - WordTableViewCellDelegate
    func shareWord(_ controller: WordTableViewCell, word: Word) {
        let text = word.textViewString()
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    func reloading(_ controller: WordTableViewCell, indexPath: IndexPath) {
        do {
            try managedObjectContext.save()
        } catch {
            print ("There was managedObjectContext.save() error")
        }
        resultsController.tableView.reloadRows(at: [indexPath], with: .none)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView != resultsController.tableView && !isShuffled {            let wordKey = sectionNames[indexPath.section]
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
        searchController.searchBar.text = ""
    }
    
    @IBAction func shufflePressed() {
        if isShuffled {
            words = sortedWords//.sort(by: sorting)
            isShuffled = false
            self.tableView.reloadData()
            shuffleButton.title = "Случайно"
        } else {
            words.shuffle()
            isShuffled = true
            self.tableView.reloadData()
            shuffleButton.title = "А-Я"
        }
        scrollToHeader()
    }
    @IBAction func titleTapped(_ sender: Any) {
        scrollToHeader()
    }
    
    @IBOutlet weak var shuffleButton: UIBarButtonItem!
    @IBOutlet weak var titleButton: UIButton!
    // MARK: - VARS and LETS
    var sectionNames = ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ы", "Э", "Ю", "Я", "#"]
    var wordsBySection = [String: [Word]]()
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    var managedObjectContext: NSManagedObjectContext!
    var words = [Word]()
    var sortedWords = [Word]()
    var filteredWords = [Word]()
    var selectedWord: Word!
    var selectedTabBarIndex: Int!
    var isShuffled = true
    var trendsVC: TrendsTableVC!
    var hudNeeded = true
    var indicator = UIActivityIndicatorView()
    let showWordDetailID = "ShowWordDetail"
    let createEditWordID = "CreateEditWord"
    let ref = Database.database().reference()

}
