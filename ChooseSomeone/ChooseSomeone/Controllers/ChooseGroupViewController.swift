//
//  ViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import Firebase
import MJRefresh

class ChooseGroupViewController: UIViewController {
    
    let header = MJRefreshNormalHeader()
    
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private var groups = [Group]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.lk_registerCellWithNib(identifier: GroupInfoCell.identifier, bundle: nil)
        
        tableView.lk_registerCellWithNib(identifier: GroupHeaderCell.identifier, bundle: nil)
        
        setUpHeaderView()
        
        setUpTableView()
        
        setUpButton()
        
        fetchGroupData()
        
        navigationController?.isNavigationBarHidden = true
        
        header.setRefreshingTarget(self, refreshingAction: #selector(self.headerRefresh))
        self.tableView.mj_header = header
        
    }
    
    @objc func headerRefresh(){
        fetchGroupData()
        self.tableView.mj_header?.endRefreshing()
    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 120),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
            
            headerView.heightAnchor.constraint(equalToConstant: 120)
        ])
        headerView.requestListButton.addTarget(self, action: #selector(checkRequestList), for: .touchUpInside)
    }
    @objc func checkRequestList(_ sender: UIButton){
        performSegue(withIdentifier: "toRequestList", sender: nil)
    }
    
    func setUpButton() {
        
        let buildTeamButton = UIButton()
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        buildTeamButton.frame = CGRect(x: width - 70, y: height - 120, width: 50, height: 50)
        buildTeamButton.backgroundColor = UIColor(red: 46 / 255 , green: 13 / 255 , blue: 128 / 255 , alpha: 1.00)
        let plusImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))
        buildTeamButton.setImage(plusImage, for: .normal)
        buildTeamButton.tintColor = .white
        buildTeamButton.layer.cornerRadius = 25
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
        if segue.identifier == "toGroupChatVC"{
            if let chatRoomVC = segue.destination as? ChatRoomViewController{
                
                if let groupInfo = sender as? Group {
                    chatRoomVC.groupInfo = groupInfo
                }
            }
        }
    }
}

extension ChooseGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupInfoCell.identifier, for: indexPath) as? GroupInfoCell
                
        else {fatalError("Could not create Cell")}
        
        cell.setUpCell(groups: groups, indexPath: indexPath)
        return cell
    }

}
