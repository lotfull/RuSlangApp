
import UIKit
import CoreData

class WordsTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate, CreateWordVCDelegate {

    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchTextField
        tableView.register(UINib.init(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "Word")
        print("viewDidLoad")
        searching(searchText)
        tableView.dataSource = self
        tableView.delegate = self
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
                //wordDetailVC.word = selectedWord
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needToUpdate {
            searching(searchText)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWord = words[indexPath.row]
        print("didSelectRowAt")
        self.performSegue(withIdentifier: showWordDetailID, sender: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath) as! WordTableViewCell
        cell.configure(with: words[indexPath.row], at: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        return cell
    }
    

    // MARK: - searching funcs
    func searching(_ text: String?) {
        let nameBeginsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        if text != "", text != nil { nameBeginsFetch.predicate =  NSPredicate(format: "name BEGINSWITH %@", text!) }
        let nameContainsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        if text != "", text != nil { nameContainsFetch.predicate =  NSPredicate(format: "(NOT (name BEGINSWITH %@)) AND (name CONTAINS[c] %@)", text!, text!) }
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        nameBeginsFetch.sortDescriptors = [sortDescriptor]
        nameContainsFetch.sortDescriptors = [sortDescriptor]
        do {
            words = try managedObjectContext.fetch(nameBeginsFetch) as! [Word]
            words.append(contentsOf: try managedObjectContext.fetch(nameContainsFetch) as! [Word])
        } catch {
            fatalError("Failed to fetch words: \(error)")
        }
        tableView.reloadData()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        print("***shouldChangeCharactersIn")
        searchText = newText
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("***textFieldShouldReturn")
        searchText = textField.text
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchText = ""
        return true
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
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet { searchTextField.delegate = self }
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
            try managedObjectContext.save() // <- remember to put this :)
        } catch {
            fatalError("error tableView(_ tableView: UITableView, commit editingStyle \(error)")
        }
    }
    
    // MARK: - VARS and LETS

    var dictWords = [String:String]()
    var arrayWords = NSMutableArray()
    var managedObjectContext: NSManagedObjectContext!
    var words = [Word]()
    var selectedWord: Word!
    var searchText: String? { didSet {
        print("***didSet searchText")
        words.removeAll()
        searching(searchText)
        title = searchText != "" ? searchText : "Словарь молодежных слов" } }
    //var needToUpdate = false
    let showWordDetailID = "ShowWordDetail"
    let showFavoritesID = "ShowFavorites"
    let createEditWordID = "CreateEditWord"
}
