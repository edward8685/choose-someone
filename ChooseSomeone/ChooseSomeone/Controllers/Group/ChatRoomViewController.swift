//
//  ChatRoomViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import RSKPlaceholderTextView
import FirebaseAuth

class ChatRoomViewController: BaseViewController {
    
    private let userId = UserManager.shared.userId
    
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
    
    var cache = [String: UserInfo]()
    
    private var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    private let textViewView = UIView()
    
    private var headerView: GroupChatHeaderCell?
    
    private let sendButton = UIButton()
    
    private var isInGroup: Bool = false {
        
        didSet {
            
            textViewView.isHidden = isInGroup ? false : true
            
            self.navigationItem.rightBarButtonItem?.isEnabled = isInGroup ? true : false
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
        
        checkUserStatus()
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: GroupChatCell.identifier, bundle: nil)
        
        setUpTextView()
        
        setUpTableView()
        
        addMessageListener()
        
        setNavigationBar()
        
        setUpStatusBarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkUserStatus()
        
        navigationController?.isNavigationBarHidden = false
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        
        textView.layer.cornerRadius = textView.frame.height / 2
        textView.layer.masksToBounds = true
    }
    
    // MARK: - Action
    
    func setUpStatusBarView() {
        
        let statusBarFrame = UIApplication.shared.statusBarFrame
        
        let statusBarView = UIView(frame: statusBarFrame)
        
        self.view.addSubview(statusBarView)
        
        statusBarView.backgroundColor = .white
    }
    
    func checkUserStatus() {
        
        guard let groupInfo = groupInfo else { return }
        
        if groupInfo.hostId == userId {
            
            userStatus = .ishost
            
            isInGroup = true
            
        } else {
            
            guard let userId = userId else { fatalError() }
            
            userStatus = groupInfo.userIds.contains(userId) ? .isInGroup : .notInGroup
            isInGroup = groupInfo.userIds.contains(userId) ? true : false
        }
    }
    
    func addMessageListener() {
        
        guard let groupInfo = groupInfo else { fatalError() }
        
        GroupRoomManager.shared.addSnapshotListener(groupId: groupInfo.groupId) { result in
            
            switch result {
                
            case .success(let messages):
                
                var filtedmessages = [Message]()
                
                for message in messages where self.userInfo.blockList?.contains(message.userId) == false {
                    
                    filtedmessages.append(message)
                    
                    guard self.cache[message.userId] != nil else {
                        
                        self.fetchUserData(uid: message.userId)
                        
                        return
                    }
                }
                
                self.messages = filtedmessages
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    func fetchMessages() {
        
        guard let groupInfo = groupInfo else { return }
        
        GroupRoomManager.shared.fetchMessages(groupId: groupInfo.groupId) { result in
            
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
    
    func fetchUserData(uid: String) {
        
        UserManager.shared.fetchUserInfo(uid: uid, completion: { result in
            
            switch result {
                
            case .success(let user):
                
                self.cache[user.uid] = user
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        })
    }
    
    @objc func didTappedButton(_ sender: UIButton) {
        
        switch userStatus {
            
        case .notInGroup:
            
            sendJoinRequest()
            
            headerView?.requestButton.setTitle("已送出申請", for: .normal)
            
            headerView?.requestButton.isEnabled = false
            
        case .isInGroup:
            
            leaveGroup()
            
        case .ishost:
            
            headerView?.isEditting.toggle()
            
            if headerView?.isEditting == true {
                
                headerView?.requestButton.setTitle("完成編輯", for: .normal)
                
            } else {
                
                headerView?.requestButton.setTitle("編輯資訊", for: .normal)
                
                if let group = headerView?.groupInfo {
                    
                    editGroupInfo(groupInfo: group)
                }
            }
        }
    }
    
    func sendJoinRequest() {
        
        guard let groupInfo = groupInfo,
              let userId = userId else { return }
        
        let joinRequest = Request(groupId: groupInfo.groupId,
                                  groupName: groupInfo.groupName,
                                  hostId: groupInfo.hostId,
                                  requestId: userId,
                                  createdTime: Timestamp())
        
        GroupRoomManager.shared.sendRequest(request: joinRequest) { result in
            
            switch result {
                
            case .success:
                
                let controller = UIAlertController(title: "成功申請囉", message: nil, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                
                controller.addAction(okAction)
                
                self.present(controller, animated: true, completion: nil)
                
            case .failure(let error):
                
                print("send request failure: \(error)")
            }
        }
    }
    
    func leaveGroup() {
        
        let controller = UIAlertController(title: "確定要退出嗎", message: nil, preferredStyle: .alert)
        
        let leaveAction = UIAlertAction(title: "退出", style: .destructive) { _ in
            
            guard let groupInfo = self.groupInfo else { return }
            
            GroupRoomManager.shared.leaveGroup(groupId: groupInfo.groupId) { result in
                
                switch result {
                    
                case .success:
                    
                    print("User leave group Successfully")
                    
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    
                    print("leave group failure: \(error)")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(cancelAction)
        
        controller.addAction(leaveAction)
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func editGroupInfo(groupInfo: Group) {
        
        GroupRoomManager.shared.updateTeam(group: groupInfo, completion: { result in
            
            switch result {
                
            case .success:
                
                let controller = UIAlertController(title: "編輯成功", message: nil, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default)
                
                controller.addAction(okAction)
                
                self.present(controller, animated: true, completion: nil)
                
            case .failure(let error):
                
                print("edit group failure: \(error)")
            }
        })
    }
    
    @objc func sendMessage(_ sender: UIButton) {
        
        textViewDidEndEditing(textView)
        
        guard let text = textView.text,
              text.count != 0,
              let groupInfo = groupInfo,
              let userId = userId else { return }
        
        newMessage.body = text
        
        newMessage.groupId = groupInfo.groupId
        
        newMessage.userId = userId
        
        newMessage.createdTime = Timestamp()
        
        GroupRoomManager.shared.sendMessage(groupId: newMessage.groupId, message: newMessage) { result in
            
            switch result {
                
            case .success:
                
                print("send message successfully")
                
                self.textView.text = ""
                
                if messages.count != 0 {
                    tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
                }
                
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
        
        leftButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let chevroImage = UIImage(systemName: "chevron.left")
        
        leftButton.setImage(chevroImage, for: .normal)
        
        leftButton.layer.cornerRadius = leftButton.frame.height / 2
        
        leftButton.layer.masksToBounds = true
        
        leftButton.tintColor = .B1
        
        leftButton.backgroundColor = .white
        
        leftButton.addTarget(self, action: #selector(backToPreviousVC), for: .touchUpInside)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: leftButton), animated: true)
        
        let rightButton = UIButton()
        
        rightButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
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
        
        if let teammateVC = self.storyboard?.instantiateViewController(withIdentifier: TeammateViewController.identifier) as? TeammateViewController {
            
            teammateVC.groupInfo = groupInfo
            
            teammateVC.cache = cache
            
            navigationController?.pushViewController(teammateVC, animated: true)
            
        }
    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        if #available(iOS 15.0, *) {
            
            tableView.sectionHeaderTopPadding = 0
            
        }
        
        tableView.backgroundColor = .white
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.separatorStyle = .none
        
        tableView.bounces = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: textViewView.topAnchor)
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
        
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 5, right: 5)
        
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

// MARK: - UITableViewDelegate

extension ChatRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = Bundle.main.loadNibNamed(GroupChatHeaderCell.identifier, owner: self, options: nil)?.first as? GroupChatHeaderCell
        else { fatalError("Could not create HeaderView") }
        
        self.headerView = headerView
        
        
        headerView.requestButton.addTarget(self, action: #selector(didTappedButton), for: .touchUpInside)
        
        if let groupInfo = groupInfo,
           let userInfo = cache[groupInfo.hostId] {
            
            headerView.setUpCell(group: groupInfo, cache: userInfo, userStatus: userStatus)
        }
        //        headerView.hostBadgeButton.addTarget(self, action: #selector(foldHeaderView), for: .touchUpInside)
        
        return headerView.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        220
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let index = indexPath.row
        let userId = messages[index].userId
        let identifier = "\(index)" as NSString
        
        if userId != self.userId {
            
            return UIContextMenuConfiguration(
                identifier: identifier, previewProvider: nil) { _ in
                    
                    let blockAction = UIAction(title: "封鎖使用者",
                                               image: UIImage(systemName: "person.fill.xmark"),
                                               attributes: .destructive) { _ in
                        
                        self.showBlockAlertAction(uid: userId)
                    }
                    
                    return UIMenu(title: "",
                                  image: nil,
                                  children: [blockAction])
                }
            
        } else {
            
            return nil
        }
    }
}


extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userId = userId else { fatalError() }
        
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
        
        let message = messages[indexPath.row]
        
        if let memberInfo = cache[message.userId] {
            
            cell.setUpCell(message: message, memberInfo: memberInfo)
            
        }
        return cell
    }
}

extension ChatRoomViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let text = textView.text,
              !text.isEmpty else {
                  return
              }
        textViewMessage = text
    }
}
