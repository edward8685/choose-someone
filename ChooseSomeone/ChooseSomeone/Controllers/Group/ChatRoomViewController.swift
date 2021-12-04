//
//  ChatRoomViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatRoomViewController: BaseViewController {
    
    enum Section {
        case message
    }
    
    // MARK: - DataSource & DataSourceSnapshot typelias -
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Message>
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Message>
    
    // MARK: - Class Properties -
    
    private var dataSource: DataSource!
    
    private var userInfo: UserInfo { UserManager.shared.userInfo }
    
    var groupInfo: Group?
    
    private var messages = [Message]()
    
    var cache = [String: UserInfo]()
    
    private var userStatus: GroupStatus = .notInGroup // isInGroup
    
    private let chatTextView = ChatTextView()
    
    private var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
        }
    }
    
    private var headerView: GroupChatHeaderCell?
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserStatus()
        
        setUpChatTextView()
        
        setUpTableView()
        
        tableView.registerCellWithNib(identifier: GroupChatCell.identifier, bundle: nil)
        
        addMessageListener()
        
        setNavigationBar()
        
        setUpStatusBarView()
        
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkUserStatus()
        
        navigationController?.isNavigationBarHidden = false
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Actions -

    func setUpStatusBarView() {
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        let statusBarFrame = window?.windowScene?.statusBarManager?.statusBarFrame
        
        let statusBarView = UIView(frame: statusBarFrame!)
        
        self.view.addSubview(statusBarView)
        
        statusBarView.backgroundColor = .white
    }
    
    func checkUserStatus() {
        
        guard let groupInfo = groupInfo else { return }
        
        let isInGroup = groupInfo.userIds.contains(userInfo.uid)
        
        if groupInfo.hostId == userInfo.uid {
            
            userStatus = .ishost
            
        } else {
            
            userStatus = isInGroup ? .isInGroup : .notInGroup
            
            chatTextView.isHidden = isInGroup ? false : true
            
            self.navigationItem.rightBarButtonItem?.isEnabled = isInGroup ? true : false
        }
    }
    
    func addMessageListener() {
        
        guard let groupInfo = groupInfo else { fatalError() }
        
        GroupManager.shared.addSnapshotListener(groupId: groupInfo.groupId) { result in
            
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
                
                if groupInfo.userIds.contains(self.userInfo.uid) {
                    
                    self.messages = filtedmessages
                    
                }
                
                self.configureSnapshot()
                
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
    
    @objc func didTappedButton(_ sender: UIButton) { // headerView
        
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
        
        guard let groupInfo = groupInfo else { return }
        
        let joinRequest = Request(groupId: groupInfo.groupId,
                                  groupName: groupInfo.groupName,
                                  hostId: groupInfo.hostId,
                                  requestId: userInfo.uid,
                                  createdTime: Timestamp())
        
        GroupManager.shared.sendRequest(request: joinRequest) { result in
            
            switch result {
                
            case .success:
                
                showAlertAction(title: "已送出申請")
                
            case .failure(let error):
                
                print("send request failure: \(error)")
            }
        }
    }
    
    func leaveGroup() {
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let leaveAction = UIAlertAction(title: "退出", style: .destructive) { _ in
            
            guard let groupInfo = self.groupInfo else { return }
            
            GroupManager.shared.leaveGroup(groupId: groupInfo.groupId) { result in
                
                switch result {
                    
                case .success:
                    
                    print("User leave group Successfully")
                    
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    
                    print("leave group failure: \(error)")
                }
            }
        }

        showAlertAction(title: "確認退出", message: nil, actions: [cancelAction, leaveAction])
    }
    
    func editGroupInfo(groupInfo: Group) {
        
        GroupManager.shared.updateTeam(group: groupInfo, completion: { result in
            
            switch result {
                
            case .success:
                
                showAlertAction(title: "編輯成功")
                
            case .failure(let error):
                
                print("edit group failure: \(error)")
            }
        })
    }
    
    @objc func sendMessage(_ sender: UIButton) {
        
        textViewDidEndEditing(chatTextView.textView)
        
        guard let text = chatTextView.textView.text,
              text.count != 0,
              let groupInfo = groupInfo else { return }
        
        let newMessage = Message(groupId: groupInfo.groupId,
                                 userId: userInfo.uid,
                                 body: text,
                                 createdTime: Timestamp())
        
        GroupManager.shared.sendMessage(groupId: newMessage.groupId, message: newMessage) { result in
            
            switch result {
                
            case .success:
                
                print("send message successfully")
                
                self.chatTextView.textView.text = ""
                
                if messages.count != 0 {
                    
                    tableView.scrollToRow(
                        at: IndexPath(row: messages.count - 1, section: 0),
                        at: .bottom,
                        animated: true)
                }
                
            case .failure(let error):
                
                print("send message failure: \(error)")
            }
        }
    }
    
    @objc func showMembers() {
        
        if let teammateVC = self.storyboard?.instantiateViewController(
            withIdentifier: TeammateViewController.identifier
        ) as? TeammateViewController {
            
            teammateVC.groupInfo = groupInfo
            
            teammateVC.cache = cache
            
            navigationController?.pushViewController(teammateVC, animated: true)
        }
    }
    
    // MARK: - UI Settings -
    
    func setNavigationBar() {
        
        setNavigationBar(title: "\(groupInfo?.groupName ?? "揪團隊伍")")
        
        let rightButton = PreviousPageButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let infoImage = UIImage(systemName: "info")
        
        rightButton.setImage(infoImage, for: .normal)
        
        rightButton.addTarget(self, action: #selector(showMembers), for: .touchUpInside)
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: rightButton), animated: true)
    }
    
    func setUpTableView() {
        
        tableView = UITableView()
        
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
            
            tableView.bottomAnchor.constraint(equalTo: chatTextView.topAnchor)
        ])
    }
    
    func setUpChatTextView() {
        
        view.addSubview(chatTextView)
        
        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            chatTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            chatTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            chatTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            chatTextView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        chatTextView.textView.delegate = self
        
        chatTextView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
}

// MARK: - TableView Delegate -

extension ChatRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: GroupChatHeaderCell = .loadFromNib()
        
        self.headerView = headerView
        
        headerView.requestButton.addTarget(self, action: #selector(didTappedButton), for: .touchUpInside)
        
        if let groupInfo = groupInfo,
           let userInfo = cache[groupInfo.hostId] {
            
            headerView.setUpCell(group: groupInfo, cache: userInfo, userStatus: userStatus)
        }
        
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
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let userId = messages[indexPath.row].userId
        
        let identifier = "\(indexPath.row)" as NSString
        
        if userId != self.userInfo.uid {
            
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

// MARK: - TableView Diffable Datasource -

extension ChatRoomViewController {
    
    func configureDataSource() {
        
        dataSource = DataSource(tableView: tableView,
                                cellProvider: { ( tableView, indexPath, model) -> UITableViewCell? in
            
            let cell: GroupChatCell = tableView.dequeueCell(for: indexPath)
            
            if let memberInfo = self.cache[model.userId] {
                
                cell.setUpCell(message: model, memberInfo: memberInfo)
                
            }
            return cell
        })
    }
    
    func configureSnapshot() {
        
        var snapshot = DataSourceSnapshot()
        
        snapshot.appendSections([.message])
        
        snapshot.appendItems(messages, toSection: .message)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - TextView Delegate -

extension ChatRoomViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let text = textView.text,
              !text.isEmpty else {
                  return
              }
        
        chatTextView.sendButton.isEnabled = text != ""
    }
}
