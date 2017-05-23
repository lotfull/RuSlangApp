
import UIKit
import CoreData

class WordsTableVC: UITableViewController  {

    var dictWords = [String:String]()
    var arrayWords = NSMutableArray()
    var managedObjectContext: NSManagedObjectContext!
    var words = [Word]()
    var selectedWord: Word!
    
    //var wordsArray = [Word]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearAllData()
        addWord("слово 1")
        addWord("слово 2")
        addWord("слово 3")
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        let fetchRequest = NSFetchRequest<Word>()
        let entity = Word.entity()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            words = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
        selectedWord = words[0]
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWord = words[indexPath.row]
    }
    
    @IBOutlet weak var isFavoriteSwitch: UISwitch!
    /*@IBAction func isFavoriteChanged(_ sender: UISwitch) {
        if let smth = sender.superview as? UITableViewCell {
            print("smth == UITableViewCell")
        } else if let smth = sender.superview as? UITableViewController {
            print("smth == UITableViewController")
        } else if let smth = sender.superview as? UIStackView {
            print("smth == UIStackView")
        } else if let smth = sender.superview as? UIContentContainer {
            print("smth == UIContentContainer")
        } else {
            print("I DONT KNOW")
        }
        
     }@IBAction func isFavoriteChanged(_ sender: UISwitch) {
     if let smth = sender.superview as? UIStackView {
     print("smth == UIStackView")
     }
     
     }*/
    
    

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWordDetail" {
            if let navigationVC = segue.destination as? UINavigationController,
                let wordDetailVC = navigationVC.topViewController as? WordDetailVC {
                wordDetailVC.managedObjectContext = managedObjectContext
                wordDetailVC.word = selectedWord
            }
        }
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
    
}
