//
//  BuildTeamViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class BuildTeamViewController: UIViewController {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBOutlet weak var trailNameTextField: UITextField!
    
    @IBOutlet weak var numOfPeopleTextfield: UITextField!
    
    @IBOutlet weak var notedTextView: UITextView!
    
    @IBOutlet weak var sendPostButton: UIButton!
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButton()
    }
    
    func setUpButton() {
        sendPostButton.addTarget(self, action: #selector(sendPost), for: .touchUpInside)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sendPost(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

