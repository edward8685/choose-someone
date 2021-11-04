//
//  ChatRoomViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore

class ChatRoomViewController: UIViewController {
 
    let userId = UserManager.shared.userInfo.uid

    private var userName = UserManager.shared.userInfo.userName
    
    private var messages = [Message]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    private var newMessage = Message()
      
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var groupInfo: Group?
    
    var textField = UITextField() {
        didSet {
            textField.delegate = self
        }
    }
    
    var textFieldMessage: String?
    
    func addMessageListener() {
        
        guard let groupInfo = groupInfo else { return }
        
        GroupRoomManager.shared.fetchMessages(groupId: groupInfo.groupId) { [weak self] result in
            
            switch result {
            
            case .success(let messages):
                
                self?.messages = messages
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: GroupChatCell.identifier, bundle: nil)
        
        setUpHeaderView()
        
        setUpTableView()
        
        setUpTextField()
        
        addMessageListener()

    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 170),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 60)
        ])
        tableView.separatorStyle = .none
    }
    
    func setUpHeaderView() {
        
        guard let headerView = Bundle.main.loadNibNamed(GroupChatHeaderCell.identifier, owner: self, options: nil)?.first as? GroupChatHeaderCell
        else { fatalError("Could not create HeaderView") }
        
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 170)
        ])
        headerView.requestButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)

        headerView.backButton.addTarget(self, action: #selector(backToPreviousVC), for: .touchUpInside)
        headerView.infoButton.addTarget(self, action: #selector(showMembers), for: .touchUpInside)
        
        if let groupInfo = groupInfo {
        headerView.setUpCell(groups: groupInfo)
        }
    }
    
    @objc func backToPreviousVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showMembers() {
    }
    
    func setUpTextField() {
        
        let textFieldView = UIView()
        view.addSubview(textFieldView)
        
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            textFieldView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textFieldView.heightAnchor.constraint(equalToConstant: 60)
        ])
        textFieldView.backgroundColor = .green
        
        textFieldView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            textField.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: -10),
            
            textField.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor, constant: 10),
            
            textField.widthAnchor.constraint(equalToConstant: UIScreen.width - 10 * 2 - 10 - 30)
        ])
        textField.textAlignment = .left
        textField.backgroundColor = .white
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.layer.masksToBounds = true
        
        let sendButton = UIButton()
        
        textFieldView.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            sendButton.heightAnchor.constraint(equalToConstant: 30),
            
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            
            sendButton.centerYAnchor.constraint(equalTo: textFieldView.centerYAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor, constant: -10)
        ])
        
        let image = UIImage(systemName: "paperplane")
        
        sendButton.setBackgroundImage(image, for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
//        sendButton.backgroundColor = .lightGray
        sendButton.layer.cornerRadius = sendButton.frame.width / 2
        sendButton.layer.masksToBounds = true

    }
    
    @objc func sendRequest(_ sender: UIButton) {
        
        guard let groupInfo = groupInfo else { return }
        
        let joinRequest = Request(groupId: groupInfo.groupId,
                                  groupName: groupInfo.groupName,
                                  hostId: groupInfo.hostId,
                                  requestId: userId,
                                  createdTime: Timestamp())

        GroupRoomManager.shared.sendRequest(request: joinRequest) { result in
            
            switch result {
            
            case .success:
                
                print("send request successfully")
                
                let controller = UIAlertController(title: "成功申請囉", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)

            case .failure(let error):
                
                print("send request failure: \(error)")
            }
        }
            
    }
    
    @objc func sendMessage(_ sender: UIButton) {
        textFieldDidEndEditing(textField)
        guard let text = textField.text,
              let groupInfo = groupInfo else { return }
            
        newMessage.body = text
        newMessage.groupId = groupInfo.groupId
        newMessage.userId = userId
        
        GroupRoomManager.shared.sendMessage(groupId: newMessage.groupId, message: newMessage) { result in
               
               switch result {
               
               case .success:
                   print("send message successfully")
                   self.textField.text = ""

               case .failure(let error):
                   
                   print("send message failure: \(error)")
               }
           }
    }
}

extension ChatRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupInfo?.userIds.contains(userId) == true {
        return messages.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatCell.identifier, for: indexPath) as? GroupChatCell
                
        else { fatalError("Could not create Cell") }
        
        cell.setUpCell(messages: messages, indexPath: indexPath)
        
        return cell
    }
}

extension ChatRoomViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldMessage = textField.text
    }
}
