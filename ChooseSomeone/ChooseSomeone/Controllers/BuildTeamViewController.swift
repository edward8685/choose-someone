//
//  BuildTeamViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import RSKPlaceholderTextView

class BuildTeamViewController: UIViewController {
    
    private var group = Group()
    
    @IBOutlet weak var buildTeamView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var groupNameTextField: UITextField! {
        didSet {
            groupNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var trailNameTextField: UITextField! {
        didSet {
            trailNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var travelDate: UIDatePicker! {
        didSet {
  
        }
    }
    
    @IBOutlet weak var numOfPeopleTextfield: UITextField! {
        didSet {
            numOfPeopleTextfield.delegate = self
        }
    }

    @IBOutlet weak var noteTextView: RSKPlaceholderTextView! {
        didSet {
            noteTextView.delegate = self
        }
    }
    
    @IBOutlet weak var sendPostButton: UIButton!
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButton()
    }
    
    override func viewWillLayoutSubviews() {
        
        headerView.applyGradient(colors: [.U2, .U1], locations: [0.0, 1.0], direction: .topToBottom)
        
        headerView.roundCornersTop(cornerRadius: 25)
        
        noteTextView.placeholder = "對團員說些什麼.."
        noteTextView.layer.masksToBounds = false
        noteTextView.layer.shadowColor = UIColor.black.cgColor
        noteTextView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        noteTextView.layer.shadowOpacity = 0.2

    }
    
    func setUpButton() {
        sendPostButton.addTarget(self, action: #selector(sendPost), for: .touchUpInside)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sendPost() {
        
        let hostId = UserManager.shared.userInfo.uid
        
        textViewDidEndEditing(noteTextView)
        group.hostId = hostId
        group.date = Timestamp(date: travelDate.date)
        group.userIds = [hostId]
        
        GroupRoomManager.shared.buildTeam(group: &group) { result in
            
            switch result {
            
            case .success:
                
                print("build team success")
                
                let controller = UIAlertController(title: "開啟揪團囉", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)

            case .failure(let error):
                
                print("build team failure: \(error)")
            }
        }
    }
}

extension BuildTeamViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let text = textView.text,
              !text.isEmpty else {
                  return
              }
        group.note = text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text,
              !text.isEmpty else {
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
    }
}
