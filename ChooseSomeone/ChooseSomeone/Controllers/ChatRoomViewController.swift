//
//  ChatRoomViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import RSKPlaceholderTextView

class ChatRoomViewController: UIViewController {
    
    private let userId = UserManager.shared.userInfo.uid
    
    private var userInfo = UserManager.shared.userInfo
    
    var groupInfo: Group?
    
    var userStatus: GroupStatus = .notInGroup
    
    private var textViewMessage: String? {
        didSet {
            if textViewMessage != nil {
                sendButton.isEnabled = true
            } else {
                sendButton.isEnabled = false
            }
        }
    }
    
    private var messages = [Message]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var newMessage = Message()
    
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
        }
    }
    
    private let textViewView = UIView()
    
    private let sendButton = UIButton()
    
    private var isInGroup: Bool = false {
        didSet {
            textViewView.isHidden = isInGroup ? false : true
            textView.isHidden = isInGroup ? false : true
            sendButton.isHidden = isInGroup ? false : true
        }
    }
    
    private var textView = RSKPlaceholderTextView() {
        didSet {
            textView.delegate = self
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: GroupChatCell.identifier, bundle: nil)
        
        setUpHeaderView()
        
        setUpTextView()
        
        setUpTableView()
        
        addMessageListener()
        
        setNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkUserStatus()
        
        navigationController?.isNavigationBarHidden = false
    }
  
    override func viewWillLayoutSubviews() {
        
        textView.layer.cornerRadius = textView.frame.height / 2
        textView.layer.masksToBounds = true
        
    }
    
    // MARK: - Action
    
    func checkUserStatus() {
        
        guard let groupInfo = groupInfo else { return }
        
        if groupInfo.hostId == userId {
            
            userStatus = .ishost
            
        } else {
            
                if groupInfo.userIds.contains(userId) {
                    
                    userStatus = .isInGroup
                    
                } else {
                    
                    userStatus = .notInGroup
                    
                }
        }
        
    }
    
    func addMessageListener() {
        
        guard let groupInfo = groupInfo else { return }
        
        GroupRoomManager.shared.addSnapshotListener(groupId: groupInfo.groupId) { result in
            
            switch result {
                
            case .success(let messages):
                
                var filtedmessages = [Message]()
                
                for message in messages where self.userInfo.blockList?.contains(message.userId) == false {
                    filtedmessages.append(message)
                }
                
                self.messages = filtedmessages
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    @objc func sendRequest(_ sender: UIButton) {
        
        switch userStatus {
            
        case .notInGroup:
            
            sendJoinRequest()
            
        case .isInGroup:
            
            leaveGroup()
            
        case .ishost:
            
            editGroupInfo()
        }
    }
        
    func sendJoinRequest() {
        
        guard let groupInfo = groupInfo else { return }
        
        let joinRequest = Request(groupId: groupInfo.groupId,
                                  groupName: groupInfo.groupName,
                                  hostId: groupInfo.hostId,
                                  requestId: userId,
                                  createdTime: Timestamp())
        
        GroupRoomManager.shared.sendRequest(request: joinRequest) { result in
            
            switch result {
                
            case .success:
                
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
    
    func leaveGroup() {
        
        guard let groupInfo = groupInfo else { return }
        
        GroupRoomManager.shared.leaveGroup(groupId: groupInfo.groupId) { result in
        
            switch result {
                
            case .success:
                
                print("User leave group Successfully")
                
                let controller = UIAlertController(title: "已退出揪團QQ", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
                
            case .failure(let error):
                
                print("leave group failure: \(error)")
            }
  
        }
    }
    
    func editGroupInfo() {
        
    }
    
    @objc func sendMessage(_ sender: UIButton) {
        textViewDidEndEditing(textView)
        guard let text = textView.text,
              let groupInfo = groupInfo else { return }
        
        newMessage.body = text
        newMessage.groupId = groupInfo.groupId
        newMessage.userId = userId
        
        GroupRoomManager.shared.sendMessage(groupId: newMessage.groupId, message: newMessage) { result in
            
            switch result {
                
            case .success:
                print("send message successfully")
                self.textView.text = ""
                
            case .failure(let error):
                
                print("send message failure: \(error)")
            }
        }
    }
    
    func setNavigationBar() {
        
        self.title = "\(groupInfo?.groupName ?? "揪團隊伍")"
        
        UINavigationBar.appearance().backgroundColor = .B1
        
        UINavigationBar.appearance().barTintColor = .B1
        
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                            NSAttributedString.Key.font: UIFont.medium(size: 22) ?? UIFont.systemFont(ofSize: 22)]
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let leftButton = UIButton()
        
        leftButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
     
        let chevroImage = UIImage(systemName: "chevron.left")
        
        leftButton.setImage(chevroImage, for: .normal)
        
        leftButton.layer.cornerRadius = leftButton.frame.height / 2
        
        leftButton.layer.masksToBounds = true
        
        leftButton.tintColor = .B1
        
        leftButton.backgroundColor = .white
        
        leftButton.addTarget(self, action: #selector(backToPreviousVC), for: .touchUpInside)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: leftButton), animated: true)
        
        let rightButton = UIButton()
        
        rightButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
     
        let infoImage = UIImage(systemName: "info")
        
        rightButton.setImage(infoImage, for: .normal)
        
        rightButton.layer.cornerRadius = rightButton.frame.height / 2
        
        rightButton.layer.masksToBounds = true
        
        rightButton.tintColor = .B1
        
        rightButton.backgroundColor = .white
        
        rightButton.addTarget(self, action: #selector(showMembers), for: .touchUpInside)
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: rightButton), animated: true)
        
    }
    
    @objc func backToPreviousVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showMembers() {
        
        if let teammateVC = self.storyboard?.instantiateViewController(withIdentifier: "TeammateViewController") as? TeammateViewController {
        
        teammateVC.groupInfo = groupInfo
        
        navigationController?.pushViewController(teammateVC, animated: true)
            
        }

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
            
            headerView.heightAnchor.constraint(equalToConstant: 220)
        ])
        headerView.requestButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
        
        if let groupInfo = groupInfo {
            headerView.setUpCell(group: groupInfo)
        }
    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: textViewView.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    func setUpTextView() {
        
        view.addSubview(textViewView)
        
        textView.placeholder = "輸入訊息..."
        
        textViewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            textViewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textViewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            textViewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textViewView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        textViewView.backgroundColor = .B1
        
        textViewView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            textView.heightAnchor.constraint(equalToConstant: 30),
            
            textView.bottomAnchor.constraint(equalTo: textViewView.bottomAnchor, constant: -10),
            
            textView.leadingAnchor.constraint(equalTo: textViewView.leadingAnchor, constant: 10),
            
            textView.widthAnchor.constraint(equalToConstant: UIScreen.width - 10 * 2 - 10 - 30)
        ])
        textView.textAlignment = .left
        
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 5, right: 5);
        
        textView.backgroundColor = .white
        
        textViewView.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            sendButton.heightAnchor.constraint(equalToConstant: 30),
            
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            
            sendButton.centerYAnchor.constraint(equalTo: textViewView.centerYAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: textViewView.trailingAnchor, constant: -10)
        ])
        
        let image = UIImage(systemName: "paperplane")
        
        sendButton.setBackgroundImage(image, for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.tintColor = .white
        
    }
    
}

extension ChatRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupInfo?.userIds.contains(userId) == true {
            isInGroup = true
            return messages.count
        } else {
            isInGroup = false
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

extension ChatRoomViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewMessage = textView.text
    }
}
