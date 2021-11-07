//
//  ProfileViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/5.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    var textInTextfield: String?
    
    let userInfo = UserManager.shared.userInfo
    
    let items = ProfileFeat.allCases
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var profileView: ProfileView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerCellWithNib(identifier: ProfileCell.identifier, bundle: nil)
        
        tableView.backgroundColor = .clear
        
        tableView.isScrollEnabled = false
        
        tableView.separatorStyle = .none
        
        profileView.setUpProfileView(userInfo: userInfo)
        
        profileView.editImageButton.delegate = self
        
        profileView.editNameTextField.isHidden = true
        
        profileView.editNameTextField.delegate = self
        
        profileView.editNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @IBAction func editName(_ sender: UIButton) {
        if profileView.isEditing == false {
            profileView.isEditing.toggle()
        } else {
            let name = profileView.editNameTextField.text
            profileView.userName.text = name
            if let name = textInTextfield {
                UserManager.shared.updateUserName(name: name)
                profileView.isEditing.toggle()
            }
        }
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        
        let firebaseAuth = Auth.auth()
        
        do {
            
            try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
            
            print("Error signing out: %@", signOutError)
            
        }
        
        if Auth.auth().currentUser == nil {
            
            guard let loginVC = UIStoryboard.login.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else { return }
            
            loginVC.modalPresentationStyle = .fullScreen
            
            present(loginVC, animated: true, completion: nil)
        }
        
    }
    
    func setUpUserInfo() {
        
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat((items.count))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let segueId = ProfileSegue.allCases[indexPath.row].rawValue
            
            performSegue(withIdentifier: segueId, sender: nil)
        }
    }
}


extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell
                
        else {fatalError("Could not create Cell")}
        
        cell.setUpCell(indexPath: indexPath)
        
        return cell
    }
    
}

extension ProfileViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        textInTextfield = textField.text
        
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    enum ActionSheet: String{
        
        case camera = "Camera"
        case library = "Library"
        case cancel = "Cancel"
        
    }
    
    func showPickerController() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Choose a source", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: ActionSheet.camera.rawValue, style: .default, handler:{ (UIAlertAction)in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: ActionSheet.library.rawValue, style: .default, handler:{ (UIAlertAction)in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: ActionSheet.cancel.rawValue, style: .cancel, handler:{ (UIAlertAction)in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        guard let imageData = image.pngData() else { return }
        
        profileView.userImage.image = image
        
        UserManager.shared.uploadUserPicture(imageData: imageData) { result in
            
            switch result {
                
            case .success:
                
                print("Upload user picture successfully")
                
            case .failure(let error):
                
                print("Upload failure: \(error)")
            }
        }
        
        dismiss(animated: true)
        
    }
    
}

extension ProfileViewController: ImagePickerDelegate {
    
    func presentImagePicker() {
        showPickerController()
    }
}
