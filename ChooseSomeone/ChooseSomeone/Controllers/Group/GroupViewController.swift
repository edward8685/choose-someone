//
//  ViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import Firebase
import MJRefresh
import MASegmentedControl
import FirebaseAuth
import FirebaseFirestore

class GroupViewController: BaseViewController {
    
    private var userInfo = UserManager.shared.userInfo
    
    private var headerView: GroupHeaderCell?
    
    private lazy var inActiveGroups = [Group]()
    
    private lazy var myGroups = [Group]() {
        
        didSet {
            updateUserHistory()
        }
    }
    
    private var searchGroups = [Group]()
    
    private lazy var requests = [Request]() {
        
        didSet {
            checkRequestsNum()
        }
    }
    
    private lazy var cache = [String: UserInfo]() {
        
        didSet {
            tableView.reloadData()
        }
    }
    
    private var searchText: String = "" {
        
        didSet {
            searching = true
        }
    }
    
    private let header = MJRefreshNormalHeader()
    
    private var tableView: UITableView! {
        
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private var onlyUserGroup = false
    
    private var searching = false

    // MARK: - View Life Cycle
    
    override var isHideNavigationBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: NSNotification.userInfoDidChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeSearchText), name: NSNotification.checkGroupDidTaped, object: nil)
        
        self.view.applyGradient(colors: [.B2, .B6], locations: [0.0, 1.0], direction: .leftSkewed)
        
        fetchGroupData()
        
        addRequestListener()
        
        setUpHeaderView()
        
        setUpTableView()
        
        setBuildTeamButton()
        
        header.setRefreshingTarget(self, refreshingAction: #selector(self.headerRefresh))
        
        tableView.mj_header = header
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        headerView?.groupSearchBar.endEditing(true)
    }
    
    // MARK: - Action
    func rearrangeMyGroup(groups: [Group]) {
        
        var expiredGroup = [Group]()
        var unexpiredGroup = [Group]()
        
        for group in groups {
            
            if group.isExpired == true {
                
                expiredGroup.append(group)
                
            } else {
                
                unexpiredGroup.append(group)
            }
        }
        expiredGroup.sort { $0.date.seconds < $1.date.seconds }
        
        unexpiredGroup.sort { $0.date.seconds < $1.date.seconds }
        
        myGroups =  unexpiredGroup + expiredGroup
    }
    
    func updateUserHistory() {
        
        var numOfGroups = 0
        
        var numOfPartners = 0
        
        myGroups.forEach { group in
            
            if group.isExpired == true {
                
                numOfGroups += 1
                
                numOfPartners += (group.userIds.count - 1) // -1 for self
            }
        }
        
        UserManager.shared.updateUserGroupRecords(numOfGroups: numOfGroups, numOfPartners: numOfPartners)
    }
    
    func checkRequestsNum() {
        
        guard let headerView = headerView else { return }
        
        if requests.count == 0 {
            
            headerView.badgeView.isHidden = true
            
        } else {
            
            headerView.requestListButton.shake()
            
            headerView.badgeView.isHidden = false
        }
    }
    
    @objc func checkRequestList(_ sender: UIButton) {
        
        if requests.count != 0 {
            
            performSegue(withIdentifier: "toRequestList", sender: requests)
            
        } else {
            
            headerView?.requestListButton.shake()
        }
    }
    
    @objc func changeSearchText(notification: Notification) {
        
        if let trailName = notification.userInfo as? [String: String] {
            
            if let trailName = trailName["trailName"] {
                
                self.searchText = trailName
                
                if onlyUserGroup {
                    searchGroups = myGroups.filter {
                        $0.trailName.lowercased().prefix(searchText.count) == searchText.lowercased() }
                } else {
                    searchGroups = inActiveGroups.filter {
                        $0.trailName.lowercased().prefix(searchText.count) == searchText.lowercased() }
                }
            
                headerView?.groupSearchBar.text = trailName
            }
        }
        
        tableView.reloadData()
    }
    
    func filtGroupBySearchName(groups: [Group]) -> [Group] {
        
        let fitledGroups = groups.filter { $0.trailName.lowercased().prefix(searchText.count) == searchText.lowercased() }
        
        return fitledGroups
    }
    
    @objc func updateUserInfo(notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String: UserInfo] {
            
            if let userInfo = userInfo[self.userInfo.uid] {
                self.userInfo = userInfo
            }
        }
    }
    
    func fetchUserData(uid: String) {
        
        UserManager.shared.fetchUserInfo(uid: uid, completion: { result in
            
            switch result {
                
            case .success(let user):
                
                self.cache[uid] = user
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        })
    }
    
    func fetchGroupData() {
        
        GroupManager.shared.fetchGroups { result in
            
            switch result {
                
            case .success(let groups):
                
                var filtedGroups = [Group]()
                
                for group in groups where self.userInfo.blockList?.contains(group.hostId) == false {
                    
                    filtedGroups.append(group)
                }
                
                self.myGroups = filtedGroups.filter { $0.userIds.contains(self.userInfo.uid) }
                
                self.inActiveGroups = filtedGroups.filter { $0.isExpired == false }
                
                self.rearrangeMyGroup(groups: self.myGroups)
                
                filtedGroups.forEach { group in
                    
                    guard self.cache[group.hostId] != nil else {
                        
                        self.fetchUserData(uid: group.hostId)
                        
                        return
                    }
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    func addRequestListener() {
        
        GroupManager.shared.fetchRequest { result in
            
            switch result {
                
            case .success(let requests):
                
                var filtedRequests = [Request]()
                
                for request in requests where self.userInfo.blockList?.contains(request.requestId) == false {
                    
                    filtedRequests.append(request)
                }
                
                self.requests = filtedRequests
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    @objc func headerRefresh() {
        
        fetchGroupData()
        
        tableView.reloadData()
        
        self.tableView.mj_header?.endRefreshing()
    }
    
    func setUpTableView() {
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: GroupInfoCell.identifier, bundle: nil)
        
        view.addSubview(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setUpHeaderView() {
        
        guard let headerView = Bundle.main.loadNibNamed(GroupHeaderCell.identifier, owner: self, options: nil)?.first as? GroupHeaderCell
        else {fatalError("Could not create HeaderView")}
        
        self.headerView = headerView
        
        headerView.groupSearchBar.delegate = self
        
        headerView.groupSearchBar.searchTextField.text = searchText
        
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        headerView.requestListButton.addTarget(self, action: #selector(checkRequestList), for: .touchUpInside)
        
        headerView.textSegmentedControl.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        
        headerView.groupSearchBar.searchTextField.text = searchText
    }
    
    @objc func segmentValueChanged(_ sender: MASegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            onlyUserGroup = false
            
        case 1 :
            onlyUserGroup = true
            
        default:
            return
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toGroupChatVC" {
            if let chatRoomVC = segue.destination as? ChatRoomViewController {
                
                if let groupInfo = sender as? Group {
                    
                    chatRoomVC.groupInfo = groupInfo
                    
                    chatRoomVC.cache = cache
                }
            }
        }
        
        if segue.identifier == "toRequestList" {
            
            if let requestVC = segue.destination as? JoinRequestViewController {
                
                if let requests = sender as? [Request] {
                    
                    requestVC.requests = requests
                }
            }
        }
    }
    
    func setBuildTeamButton() {
        
        let buildTeamButton = UIButton()
        
        buildTeamButton.addTarget(self, action: #selector(buildNewTeam), for: .touchUpInside)
    
        view.addSubview(buildTeamButton)
    }
    
    @objc func buildNewTeam() {
        performSegue(withIdentifier: "toBuildTeamVC", sender: nil)
    }
}

extension GroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0.03 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
            })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searching {
            
            performSegue(withIdentifier: "toGroupChatVC", sender: searchGroups[indexPath.row])
            
        } else {
            
            if onlyUserGroup {
                
                performSegue(withIdentifier: "toGroupChatVC", sender: myGroups[indexPath.row])
                
            } else {
                
                performSegue(withIdentifier: "toGroupChatVC", sender: inActiveGroups[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let index = indexPath.row
        
        var userId = ""
        
        if searching {
            
            userId = searchGroups[index].hostId
            
        } else {
            
            if onlyUserGroup {
                
                userId = myGroups[index].hostId
                
            } else {
                
                userId = inActiveGroups[index].hostId
            }
        }
        
        let identifier = "\(index)" as NSString
        
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

extension GroupViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            
            return searchGroups.count
            
        } else {
            
            if onlyUserGroup {
                
                return myGroups.count
                
            } else {
                
                return inActiveGroups.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupInfoCell.identifier, for: indexPath) as? GroupInfoCell
        else {fatalError("Could not create Cell")}
        
        var group = Group()
        
        if searching {
            
            group = searchGroups[indexPath.row]
            
        } else {
            
            if onlyUserGroup {
                
                group = myGroups[indexPath.row]
                
            } else {
                
                group = inActiveGroups[indexPath.row]
            }
        }
        
        cell.setUpCell(group: group, hostname: cache[group.hostId]?.userName ?? "使用者")
        return cell
    }
}

extension GroupViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if onlyUserGroup {
            searchGroups = myGroups.filter {
                $0.trailName.lowercased().prefix(searchText.count) == searchText.lowercased() }
        } else {
            searchGroups = inActiveGroups.filter {
                $0.trailName.lowercased().prefix(searchText.count) == searchText.lowercased() }
        }
        
        searching = true
        
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searching = false
        
        searchBar.endEditing(true)
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        
        searchBar.resignFirstResponder()
    }
}
