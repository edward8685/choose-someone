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

class ChooseGroupViewController: UIViewController {
    
    let userId = UserManager.shared.userInfo.uid
    
    var searchText: String = "" {
        didSet {
            searching = true
        }
    }
    
    let header = MJRefreshNormalHeader()
    
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private var groups = [Group]() {
        didSet {
            myGroups = groups.filter { $0.userIds.contains(userId)
            }
            groupsToDisplay = groups
            tableView.reloadData()
        }
    }
    
    private var myGroups = [Group]()
    
    private var groupsToDisplay = [Group]()
    
    private var searching = false
    private var searchGroups = [Group]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyGradient(colors: [.B2, .B6], locations: [0.0, 1.0], direction: .leftSkewed)
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: GroupInfoCell.identifier, bundle: nil)
        
        setUpHeaderView()
        
        setUpTableView()
        
        setUpButton()
        
        fetchGroupData()
        
        header.setRefreshingTarget(self, refreshingAction: #selector(self.headerRefresh))
        self.tableView.mj_header = header
        
        groupsToDisplay = groups
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    // MARK: - Action
    
    @objc func headerRefresh() {
        fetchGroupData()
        tableView.reloadData()
        self.tableView.mj_header?.endRefreshing()
    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.separatorStyle = .none
        
    }
    
    func setUpHeaderView() {
        
        guard let headerView = Bundle.main.loadNibNamed(GroupHeaderCell.identifier, owner: self, options: nil)?.first as? GroupHeaderCell
        else {fatalError("Could not create HeaderView")}
        
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
        
        headerView.groupSearchBar.delegate = self
        
    }
    
    @objc func segmentValueChanged(_ sender: MASegmentedControl) {
  
        switch sender.selectedSegmentIndex {
        case 0:
            groupsToDisplay = groups
            
        case 1 :
            groupsToDisplay = myGroups

        default:
            groupsToDisplay = groups
        }
        tableView.reloadData()
    }
    
    @objc func checkRequestList(_ sender: UIButton) {
        performSegue(withIdentifier: "toRequestList", sender: nil)
    }
    
    func setUpButton() {
        
        let buildTeamButton = UIButton()
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        buildTeamButton.frame = CGRect(x: width * 0.8, y: height * 0.8, width: width * 0.15, height: width * 0.15)
        buildTeamButton.backgroundColor = UIColor.hexStringToUIColor(hex: "72E717")
        let plusImage = UIImage(named: "choose_button")

        buildTeamButton.setImage(plusImage, for: .normal)
        buildTeamButton.tintColor = .white
        buildTeamButton.layer.cornerRadius = width * 0.075
        buildTeamButton.layer.masksToBounds = true
        
        buildTeamButton.addTarget(self, action: #selector(buildNewTeam), for: .touchUpInside)
        
        view.addSubview(buildTeamButton)
    }
    
    @objc func buildNewTeam() {
        performSegue(withIdentifier: "toBuildTeamVC", sender: nil)
    }
    
    func fetchGroupData() {
        
        GroupRoomManager.shared.fetchGroups { [weak self] result in
            
            switch result {
                
            case .success(let groups):
                
                self?.groups = groups
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}

extension ChooseGroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toGroupChatVC", sender: groups[indexPath.row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGroupChatVC" {
            if let chatRoomVC = segue.destination as? ChatRoomViewController {
                
                if let groupInfo = sender as? Group {
                    chatRoomVC.groupInfo = groupInfo
                }
            }
        }
    }
}

extension ChooseGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            
            return searchGroups.count
            
        } else {
            
            return groupsToDisplay.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupInfoCell.identifier, for: indexPath) as? GroupInfoCell
                
        else {fatalError("Could not create Cell")}
        
        if searching {
            
            cell.setUpCell(group: searchGroups[indexPath.row], indexPath: indexPath)
            
        } else {
            
            cell.setUpCell(group: groupsToDisplay[indexPath.row], indexPath: indexPath)
            
        }
        
        return cell
        
    }
}

extension ChooseGroupViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchGroups = groupsToDisplay.filter {
            $0.trailName.lowercased().prefix(searchText.count) == searchText.lowercased() }
        
        searching = true
        
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        resignFirstResponder()
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searching = false
        
        searchBar.text = ""
        
        tableView.reloadData()
        
        resignFirstResponder()
    }
}
