
import UIKit
import CoreData

class WordsTableVC: UITableViewController, UITextFieldDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        searching("")
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWordDetailID {
            print("prepare(for segue")
            if let navigationVC = segue.destination as? UINavigationController,
                let wordDetailVC = navigationVC.topViewController as? WordDetailVC,
                let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                wordDetailVC.managedObjectContext = managedObjectContext
                selectedWord = words[indexPath.row]
                wordDetailVC.word = selectedWord
            }
        }
    }
    
    // MARK: - tableView funcs
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
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
        cell.configure(with: word)
        return cell
    }

    // MARK: - searching funcs
    func searching(_ text: String?) {
        let searchFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        if searchText != "" { searchFetch.predicate =  NSPredicate(format: "name BEGINSWITH %@", text!) }
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
    
    // MARK: - @IBO and @IBA
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
        searching(searchText)
        title = searchText } }
    let showWordDetailID = "ShowWordDetail"
    
    
}
