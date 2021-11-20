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

class ChooseGroupViewController: BaseViewController {
    
    private var userInfo = UserManager.shared.userInfo
    
    var headerView: GroupHeaderCell?
    
    private lazy var inActiveGroups = [Group]()
    
    private lazy var myGroups = [Group]() {
        
        didSet {
            updateUserHistory()
        }
    }
    
    private lazy var requests = [Request]() {
        
        didSet {
            
            checkRequestsNum()
        }
    }
    
    lazy var cache = [String: UserInfo]() {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var searchText: String = "" {
        
        didSet {
            searching = true
            headerView?.groupSearchBar.delegate = self
        }
    }
    
    let header = MJRefreshNormalHeader()
    
    private var tableView: UITableView! {
        
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private var onlyUserGroup = false
    
    private var searching = false
    
    private var searchGroups = [Group]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: NSNotification.userInfoDidChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeSearchText), name: NSNotification.checkGroupDidTaped, object: nil)
        
        self.view.applyGradient(colors: [.B2, .B6], locations: [0.0, 1.0], direction: .leftSkewed)
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: GroupInfoCell.identifier, bundle: nil)
        
        fetchGroupData()
        
        setUpHeaderView()
        
        setUpTableView()
        
        setBuildTeamButton()
        
        addRequestListener()
        
        header.setRefreshingTarget(self, refreshingAction: #selector(self.headerRefresh))
        
        self.tableView.mj_header = header
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Action
    func manageMyGroup(groups: [Group]) {
        
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
    
    func updateUserHistory() {
        
        var numOfGroups = 0
        
        var numOfPartners = 0
        
        myGroups.forEach { group in
            
            if group.isExpired == true {
                
                numOfGroups += 1
                
                numOfPartners += (group.userIds.count - 1)
            }
        }
        UserManager.shared.updateUserGroupRecords(numOfGroups: numOfGroups, numOfPartners: numOfPartners)
    }
    
    func checkRequestsNum() {
        
        guard let headerView = headerView else { return }
        
        if requests.count == 0 {
            
            headerView.badgeView.isHidden = true
            
        } else {
            
            headerView.badgeView.isHidden = false
        }
        
    }
    
    @objc func checkRequestList(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toRequestList", sender: requests)
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
        
        GroupRoomManager.shared.fetchGroups { result in
            
            switch result {
                
            case .success(let groups):
                
                var filtedGroups = [Group]()
                
                for group in groups where self.userInfo.blockList?.contains(group.hostId) == false {
                    
                    filtedGroups.append(group)
                }
                
                self.myGroups = filtedGroups.filter { $0.userIds.contains(self.userInfo.uid) }
                
                self.inActiveGroups = filtedGroups.filter { $0.isExpired == false }
                
                self.manageMyGroup(groups: self.myGroups)
                
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
        
        GroupRoomManager.shared.fetchRequest { result in
            
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
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        buildTeamButton.frame = CGRect(x: width * 0.8, y: height * 0.8, width: width * 0.18, height: width * 0.18)
        
        let image = UIImage.asset(.choose)
        
        buildTeamButton.setImage(image, for: .normal)
        
        buildTeamButton.tintColor = .white
        
        buildTeamButton.layer.cornerRadius = width * 0.09
        
        buildTeamButton.layer.masksToBounds = true
        
        buildTeamButton.addTarget(self, action: #selector(buildNewTeam), for: .touchUpInside)
        
        view.addSubview(buildTeamButton)
    }
    
    @objc func buildNewTeam() {
        performSegue(withIdentifier: "toBuildTeamVC", sender: nil)
    }
    
}

extension ChooseGroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.5,
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

extension ChooseGroupViewController: UITableViewDataSource {
    
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
        
        if searching {
            let group = searchGroups[indexPath.row]
            
            cell.setUpCell(group: group, hostname: cache[group.hostId]?.userName ?? "使用者")
            
        } else {
            
            if onlyUserGroup {
                
                let group = myGroups[indexPath.row]
                
                cell.setUpCell(group: group, hostname: cache[group.hostId]?.userName ?? "使用者")
                
            } else {
                
                let group = inActiveGroups[indexPath.row]
                
                cell.setUpCell(group: group, hostname: cache[group.hostId]?.userName ?? "使用者")
            }
        }
        
        return cell
    }
}

extension ChooseGroupViewController: UISearchBarDelegate {
    
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
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searching = false
        
        searchBar.text = ""
        
        tableView.reloadData()
        
        searchBar.resignFirstResponder()
    }
}
