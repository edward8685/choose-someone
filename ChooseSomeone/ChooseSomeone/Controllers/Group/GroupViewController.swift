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
    
    // MARK: - Class Properties -
    
    private var userInfo: UserInfo { UserManager.shared.userInfo }
    
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
            isSearching = true
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
    
    private var isSearching = false
    
    // MARK: - View Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override var isHideNavigationBar: Bool { return true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        headerView?.groupSearchBar.endEditing(true)
    }
    
    // MARK: - Action -
    
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
            
            performSegue(withIdentifier: SegueIdentifier.requestList.rawValue, sender: requests)
            
        } else {
            
            headerView?.requestListButton.shake()
        }
    }
    
    @objc func changeSearchText(notification: Notification) {
        
        if let trailName = notification.userInfo as? [String: String] {
            
            if let trailName = trailName["trailName"] {
                
                self.searchText = trailName
                
                if onlyUserGroup {
                    
                    searchGroups = filtGroupBySearchName(groups: myGroups)
                    
                } else {
                    
                    searchGroups = filtGroupBySearchName(groups: inActiveGroups)
                }
                
                headerView?.groupSearchBar.text = trailName
            }
        }
        
        tableView.reloadData()
    }
    
    func filtGroupBySearchName(groups: [Group]) -> [Group] {
        
        let fitledGroups = groups.filter {
            $0.trailName.lowercased().prefix(searchText.count) == searchText.lowercased()
        }
        
        return fitledGroups
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
                
                var filteredGroups = [Group]()
                
                for group in groups where self.userInfo.blockList?.contains(group.hostId) == false {
                    
                    filteredGroups.append(group)
                }
                
                self.myGroups = filteredGroups.filter {
                    $0.userIds.contains(self.userInfo.uid)
                }
                
                self.inActiveGroups = filteredGroups.filter { $0.isExpired == false }
                
                self.rearrangeMyGroup(groups: self.myGroups)
                
                filteredGroups.forEach { group in
                    
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
        
        GroupManager.shared.addRequestListener { result in
            
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
    
    // MARK: - UI Settings -
    
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
        
        let headerView: GroupHeaderCell = .loadFromNib()
        
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
        
        if segue.identifier == SegueIdentifier.groupChat.rawValue {
            if let chatRoomVC = segue.destination as? ChatRoomViewController {
                
                if let groupInfo = sender as? Group {
                    
                    chatRoomVC.groupInfo = groupInfo
                    
                    chatRoomVC.cache = cache
                }
            }
        }
        
        if segue.identifier == SegueIdentifier.requestList.rawValue {
            
            if let requestVC = segue.destination as? JoinRequestViewController {
                
                if let requests = sender as? [Request] {
                    
                    requestVC.requests = requests
                }
            }
        }
    }
    
    func setBuildTeamButton() {
        
        let button = BuildTeamButton()
        
        let width = UIScreen.width
        
        let height = UIScreen.height
        
        button.frame = CGRect(x: width * 0.8, y: height * 0.8, width: width * 0.18, height: width * 0.18)
        
        button.addTarget(self, action: #selector(buildNewTeam), for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    @objc func buildNewTeam() {
        performSegue(withIdentifier: SegueIdentifier.buildTeam.rawValue, sender: nil)
    }
}

// MARK: - TableView Delegate -

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
        
        var sender = [Group]()
        
        if isSearching {
            
            sender = searchGroups
            
        } else {
            
            if onlyUserGroup {
                
                sender = myGroups
                
            } else {
                
                sender = inActiveGroups
            }
        }
        performSegue(withIdentifier: SegueIdentifier.groupChat.rawValue, sender: sender[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let index = indexPath.row
        
        var userId = ""
        
        if isSearching {
            
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
            
        } else { return nil }
    }
}

// MARK: - TableView Data Source -

extension GroupViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            
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
        
        let cell: GroupInfoCell = tableView.dequeueCell(for: indexPath)
        
        var group = Group()
        
        if isSearching {
            
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

// MARK: - SearchBar Delegate -

extension GroupViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        
        if onlyUserGroup {
            
            searchGroups = filtGroupBySearchName(groups: myGroups)
            
        } else {
            
            searchGroups = filtGroupBySearchName(groups: inActiveGroups)
        }
        
        isSearching = true
        
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        isSearching = false
        
        searchBar.endEditing(true)
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}
