
import UIKit
import CoreData

class FavoritesTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate  {
    
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchTextField
        tableView.register(UINib.init(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "Word")
        print("viewDidLoad")
        searchingFavorites("")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchingFavorites(searchText)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWordDetailID {
            print("prepare(for segue")
            if let navigationVC = segue.destination as? UINavigationController, let wordDetailVC = navigationVC.topViewController as? WordDetailVC {
                wordDetailVC.managedObjectContext = managedObjectContext
                wordDetailVC.word = selectedWord
            }
        } else if segue.identifier == showFavorites {
            
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
        let word = words[indexPath.row]
        cell.configure(with: word, at: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        return cell
    }
    
    
    // MARK: - searching funcs
    func searchingFavorites(_ text: String?) {
        let searchFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        if text != "", text != nil {
            searchFetch.predicate =  NSPredicate(format: "name contains[c] %@ and favorite = true", text!)
        } else {
            searchFetch.predicate =  NSPredicate(format: "favorite = true")
        }
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        searchFetch.sortDescriptors = [sortDescriptor]
        do {
            words = try managedObjectContext.fetch(searchFetch) as! [Word]
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
        let word = Word(context: managedObjectContext)
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
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet { searchTextField.delegate = self }
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
        searchingFavorites(searchText) } }
    let showWordDetailID = "ShowWordDetail"
    let showFavorites = "showFavorites"
}