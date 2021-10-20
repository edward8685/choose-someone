//
//  ChatRoomViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit


class ChatRoomViewController: UIViewController, UITextFieldDelegate {
    
    private var messages = [Message]() {
        didSet{
            tableView.reloadData()
        }
    }

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
    
    func fetchMessageData() {
        
        GroupRoomManager.shared.fetchMessages { [weak self] result in
            
            switch result {
            
            case .success(let messages):
                
                self?.messages = messages
                print(messages)
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.lk_registerCellWithNib(identifier: GroupChatCell.identifier, bundle: nil)
        
        setUpHeaderView()
        
        setUpTableView()
        
        setUpTextField()
        
        fetchMessageData()
        
    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 150),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 40)
        ])
    }
    
    func setUpHeaderView() {
        
        guard let headerView = Bundle.main.loadNibNamed(GroupChatHeaderCell.identifier, owner: self, options: nil)?.first as? GroupChatHeaderCell
        else {fatalError("Could not create HeaderView")}
        
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 150)
        ])
        headerView.requestButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)

        headerView.backButton.addTarget(self, action: #selector(backToPreviousVC), for: .touchUpInside)
        headerView.infoButton.addTarget(self, action: #selector(showMembers), for: .touchUpInside)
        
        if let groupInfo = groupInfo {
        headerView.setUpCell(groups: groupInfo)
        }
    }
    
    @objc func backToPreviousVC(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showMembers(){
    }
    
    func setUpTextField() {
        
        let textFieldView = UIView()
        view.addSubview(textFieldView)
        
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            textFieldView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textFieldView.heightAnchor.constraint(equalToConstant: 50)
        ])
        textFieldView.backgroundColor = .green
        
        textFieldView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            textField.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor,constant: -10),
            
            textField.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor,constant: 10),
            
            textField.widthAnchor.constraint(equalToConstant: UIScreen.width - 10 * 2 - 5 - 40)
        ])
        textField.textAlignment = .left
        textField.backgroundColor = .white
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.layer.masksToBounds = true
        
        let sendButton = UIButton()
        
        textFieldView.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            
            sendButton.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor,constant: -10),
            
            sendButton.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor, constant: -10)
        ])
        sendButton.setImage(UIImage(named: "paperplane"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.backgroundColor = .lightGray
        sendButton.tintColor = .green
        sendButton.layer.cornerRadius = sendButton.frame.width / 2
        sendButton.layer.masksToBounds = true

    }

    
    @objc func sendRequest(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func sendMessage(_ sender: UIButton) {
        
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

        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatCell.identifier, for: indexPath) as? GroupChatCell
                
        else {fatalError("Could not create Cell")}
        
        cell.setUpCell(messages: messages, indexPath: indexPath)
        
        return cell
    }
}

extension ChatRoomViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textFieldMessage = textField.text
    }
}
