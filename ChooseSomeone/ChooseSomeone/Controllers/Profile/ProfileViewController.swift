//
//  ProfileViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/5.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    enum ActionSheet: String {
        
        case camera = "相機"
        case library = "圖庫"
        case cancel = "取消"
    }
    
    @IBOutlet weak var gradientView: UIView! {
        didSet {
            gradientView.applyGradient(
                colors: [.B2, .C4],
                locations: [0.0, 1.0], direction: .leftSkewed)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            tableView.delegate = self
            
            tableView.dataSource = self
            
            tableView.backgroundColor = .clear
            
            tableView.isScrollEnabled = false
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var profileView: ProfileView!
    
    private var textInTextfield: String = ""
    
    private let userInfo = UserManager.shared.userInfo
    
    private let items = ProfileFeat.allCases
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.registerCellWithNib(identifier: ProfileCell.identifier, bundle: nil)
        
        setUpProfileView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Methods -
    
    @IBAction func editName(_ sender: UIButton) {
        
        if profileView.isEditting == false {
            
            profileView.isEditting.toggle()
            
        } else {
            
            if let name = profileView.editNameTextField.text {
                
                profileView.editNameTextField.text = name
                
                updateUserInfo(name: name)
            }
            
            profileView.isEditting.toggle()
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
            
            guard let loginVC = UIStoryboard.login.instantiateViewController(
                identifier: LoginViewController.identifier) as? LoginViewController else { return }
            
            loginVC.modalPresentationStyle = .fullScreen
            
            present(loginVC, animated: true, completion: nil)
        }
    }
    
    func updateUserInfo(imageData: Data) {
        
        UserManager.shared.uploadUserPicture(imageData: imageData) { result in
            
            switch result {
                
            case .success:
                
                print("Upload user picture successfully")
                
            case .failure(let error):
                
                print("Upload failure: \(error)")
            }
        }
    }
    
    func updateUserInfo(name: String) {
        
        UserManager.shared.updateUserName(name: name)
    }
    
    // MARK: - UI Settings -
    
    func setUpProfileView() {
        
        profileView.setUpProfileView(userInfo: userInfo)
        
        profileView.editImageButton.delegate = self
        
        profileView.editNameTextField.delegate = self
        
        profileView.editNameTextField.addTarget(
            self,
            action: #selector(self.textFieldDidChange(_:)),
            for: .editingChanged)
    }
}

// MARK: - TableView Delegate -

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat((items.count + 1))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            
            let segueId = ProfileSegue.allCases[indexPath.row].rawValue
            
            performSegue(withIdentifier: segueId, sender: nil)
            
        case 2:
            
            guard let policyVC = UIStoryboard.policy.instantiateViewController(
                identifier: PolicyViewController.identifier) as? PolicyViewController else { return }
            
            policyVC.policyType = .privacy
            
            present(policyVC, animated: true, completion: nil)
            
        default:
            return
        }
    }
}

// MARK: - TableView DataSource -

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ProfileCell = tableView.dequeueCell(for: indexPath)
        
        cell.setUpCell(indexPath: indexPath)
        
        return cell
    }
}

// MARK: - TextField DataSource -

extension ProfileViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        textInTextfield = textField.text ?? ""
    }
}

// MARK: - ImagePicker Delegate -

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showPickerController() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.modalPresentationStyle = .fullScreen
        
        imagePickerController.allowsEditing = true
        
        let actionSheet = UIAlertController(
            title: "選擇照片來源",
            message: nil,
            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(
            title: ActionSheet.camera.rawValue,
            style: .default,
            handler: { ( UIAlertAction ) in
                
                imagePickerController.sourceType = .camera
                
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: ActionSheet.library.rawValue,
            style: .default,
            handler: { ( UIAlertAction ) in
                
                imagePickerController.sourceType = .photoLibrary
                
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: ActionSheet.cancel.rawValue,
            style: .cancel,
            handler: { ( UIAlertAction ) in
                
                self.dismiss(animated: true, completion: nil)
            }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        
        UIView.animate(withDuration: 0.2) {
            self.profileView.userImage.image = image
        }
        
        updateUserInfo(imageData: imageData)
        
        dismiss(animated: true)
    }
}

extension ProfileViewController: ImagePickerDelegate {
    
    func presentImagePicker() {
        
        showPickerController()
    }
}
