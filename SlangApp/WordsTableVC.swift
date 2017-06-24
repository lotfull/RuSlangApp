
import UIKit
import CoreData

class WordsTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate, CreateWordVCDelegate, UISearchResultsUpdating {
    
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        installSearchController()
        installTableView()
        firstFetching()
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
        //searchController.hidesNavigationBarDuringPresentation = false
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWordDetailID {
            print("prepare(for segue")
            if let wordDetailVC = segue.destination as? WordDetailVC {
                wordDetailVC.managedObjectContext = managedObjectContext
                wordDetailVC.word = selectedWord
            }
        } else if segue.identifier == showFavoritesID {
            
        } else if segue.identifier == createEditWordID {
            if let navigationVC = segue.destination as? UINavigationController,
                let createEditWordVC = navigationVC.topViewController as? CreateEditWordVC {
                createEditWordVC.managedObjectContext = managedObjectContext
                createEditWordVC.delegate = self
            }
        }
    }
    
    // MARK: - TableView Funcs
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsController.tableView {
            return filteredWords.count
        } else {
            return words.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath) as! WordTableViewCell
        
        if tableView == resultsController.tableView {
            cell.configure(with: filteredWords[indexPath.row], at: indexPath)
        } else {
            cell.configure(with: words[indexPath.row], at: indexPath)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWord = filteredWords[indexPath.row]
        print("didSelectRowAt")
        if tableView == resultsController.tableView {
            print("********************")
            //searchController.dismiss(animated: true, completion: nil)
            //resultsController.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: showWordDetailID, sender: nil)
        } else {
            self.performSegue(withIdentifier: showWordDetailID, sender: nil)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }

    // MARK: - searching funcs
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        if text == nil || text == "" {
            filteredWords = words
        } else {
            filteredWords = words.filter({ (word:Word) -> Bool in
                return word.name.contains(text!) ? true : false
            })
        }
        resultsController.tableView.reloadData()
    }
    func firstFetching() {
        let nameBeginsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        do {
            words = try managedObjectContext.fetch(nameBeginsFetch) as! [Word]
        } catch {
            fatalError("Failed to fetch words: \(error)")
        }
        filteredWords = words
        tableView.reloadData()
    }
    
    func clearAllData() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try managedObjectContext.execute(request)
            try managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
    }
    func addWord(_ wordName: String) {
        let word = Word()
        word.name = wordName
        word.definition = "Значение слова \(wordName)"
        word.examples = "Сегодня я выучила \(wordName) на уроке английского"
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
        tableView.reloadRows(at: [indexPath], with: .none)
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
        managedObjectContext.delete(words[indexPath.row])
        saveManagedObjectContext()
        words.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("error tableView(_ tableView: UITableView, commit editingStyle \(error)")
        }
    }
    
    // MARK: - VARS and LETS
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    var dictWords = [String:String]()
    var arrayWords = NSMutableArray()
    var managedObjectContext: NSManagedObjectContext!
    var words = [Word]()
    var filteredWords = [Word]()
    var selectedWord: Word!
    
    let showWordDetailID = "ShowWordDetail"
    let showFavoritesID = "ShowFavorites"
    let createEditWordID = "CreateEditWord"
}
