//
//  BuildTeamViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import RSKPlaceholderTextView
import FirebaseAuth

class BuildTeamViewController: BaseViewController {
    
    // MARK: - Class Properties -
    
    @IBOutlet weak var dimmingView: UIView! {
        
        didSet {
            
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(handleTap(recognizer:)))
            
            dimmingView.addGestureRecognizer(recognizer)
        }
    }
    
    private var group = Group()
    
    private var textsWerefilled: Bool = false {
        
        didSet {
            
            sendPostButton.isUserInteractionEnabled = textsWerefilled
            
            sendPostButton.alpha = textsWerefilled ? 1.0 : 0.5
        }
    }
    
    @IBOutlet weak var buildTeamView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var groupNameTextField: UITextField! {
        
        didSet {
            
            groupNameTextField.delegate = self
            
            groupNameTextField.setLeftPaddingPoints(8)
        }
    }
    
    @IBOutlet weak var trailNameTextField: UITextField! {
        
        didSet {
            
            trailNameTextField.delegate = self
            
            trailNameTextField.setLeftPaddingPoints(8)
        }
    }
    
    @IBOutlet weak var travelDate: UIDatePicker!
    
    @IBOutlet weak var numOfPeopleTextfield: UITextField! {
        
        didSet {
            
            numOfPeopleTextfield.delegate = self
            
            numOfPeopleTextfield.setLeftPaddingPoints(8)
        }
    }
    
    @IBOutlet weak var noteTextView: RSKPlaceholderTextView! {
        
        didSet {
            
            noteTextView.delegate = self
        }
    }
    
    @IBOutlet weak var sendPostButton: UIButton! {
        
        didSet {
            
            sendPostButton.isUserInteractionEnabled = false
            sendPostButton.alpha = 0.5
        }
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        headerView.applyGradient(colors: [.U2, .U1], locations: [0.0, 1.0], direction: .topToBottom)
        
        headerView.roundCornersTop(cornerRadius: 15)
        
        setUpTextView()
    }
    
    // MARK: - Methods -
    
    func checkTextsFilled() {
        
        let textfields = [ groupNameTextField, trailNameTextField, numOfPeopleTextfield]
        
        if noteTextView.text != nil {
            
            textsWerefilled = textfields.allSatisfy { $0?.text?.isEmpty  == false }
        }
    }
    
    @objc func sendPost() {
        
        guard let hostId = Auth.auth().currentUser?.uid else { return }
        
        textViewDidEndEditing(noteTextView)
        
        group.hostId = hostId
        
        group.date = Timestamp(date: travelDate.date)
        
        group.userIds = [hostId]
        
        if group.date.checkIsExpired() {
            
            buildTeamView.shake()
            
            showAlertAction(title: "??????????????????", message: "???????????????")
            
        } else {
            
            GroupManager.shared.buildTeam(group: &group) { result in
                
                switch result {
                    
                case .success:
                    
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    showAlertAction(title: "???????????????", message: nil, actions: [okAction])
                    
                case .failure(let error):
                    
                    print("build team failure: \(error)")
                }
            }
        }
    }
    
    // MARK: - UI Settings -
    
    func setUpTextView() {
        
        noteTextView.placeholder = "?????????????????????.."
        
        noteTextView.clipsToBounds = true
        
        noteTextView.layer.cornerRadius = 10
        
        noteTextView.textContainer.maximumNumberOfLines = 3
        
        noteTextView.textContainer.lineBreakMode = .byWordWrapping
    }
    
    func setUpButton() {
        
        sendPostButton.addTarget(self, action: #selector(sendPost), for: .touchUpInside)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TextField & TextView Delegate -

extension BuildTeamViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        var maxLength = 12
        
        if textField == numOfPeopleTextfield {
            maxLength = 2
        }
        
        let currentString: NSString = (textField.text ?? "") as NSString
        
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maxLength
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let text = textView.text,
              !text.isEmpty else {
                  return
              }
        
        group.note = text
        checkTextsFilled()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        
        switch textField {
            
        case groupNameTextField:
            
            group.groupName = text
            
        case trailNameTextField:
            
            group.trailName = text
            
        case numOfPeopleTextfield:
            
            group.upperLimit = Int(text) ?? 1
            
        default:
            
            return
        }
        
        checkTextsFilled()
    }
}
