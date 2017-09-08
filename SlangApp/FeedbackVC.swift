//
//  FeedbackVC.swift
//  SlangApp
//
//  Created by Kam Lotfull on 07.09.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

protocol FreeDelegate: class {
    func printDick()
}

protocol SendingFeedbackDelegate: class {
    func sendFeedback(_ controller: FeedbackVC, _ feedback: Feedback)
}

class FeedbackVC: UITableViewController, UITextViewDelegate {

    weak var delegate: SendingFeedbackDelegate?
    weak var delegate1: FreeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.becomeFirstResponder()
        sendButton.isEnabled = false
        feedbackTextView.delegate = self
        nameField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        delegate1?.printDick()
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard
            let name = nameField.text, let email = emailField.text,
            !name.isEmpty || !email.isEmpty,
            let feedback = feedbackTextView.text, !feedback.isEmpty
            else {
                sendButton.isEnabled = false
                return
        }
        sendButton.isEnabled = true
    }
    
    func editingChanged(_ textField: UITextField) {
        guard
            let name = nameField.text, let email = emailField.text,
            !name.isEmpty || !email.isEmpty,
            let feedback = feedbackTextView.text, !feedback.isEmpty
            else {
                sendButton.isEnabled = false
                return
        }
        sendButton.isEnabled = true
    }
    
    @IBAction func feedbackSended(_ sender: Any) {
        let feedback = Feedback(name: nameField.text,
                                email: emailField.text,
                                feedback: feedbackTextView.text,
                                rating: ratingSegmentControl.selectedSegmentIndex + 1)
        print(feedback.text())
        delegate?.sendFeedback(self, feedback)
        _ = navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var ratingSegmentControl: UISegmentedControl!
    @IBOutlet weak var sendButton: UIBarButtonItem!

}
