//
//  TeammateController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/9.
//

import UIKit

class TeammateViewController: BaseViewController {
    
    // MARK: - Class Properties -
    
    var cache: [String: UserInfo]?
    
    var groupInfo: Group?
    
    private var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: MemberCell.identifier, bundle: nil)
        
        view.stickSubView(tableView)
        
        setNavigationBar(title: "\(groupInfo?.groupName ?? "揪團") - 成員")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
}

// MARK: - TableView Delegate & Data Source -

extension TeammateViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let num =  groupInfo?.userIds.count else { fatalError() }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MemberCell = tableView.dequeueCell(for: indexPath)
        
        if let group = groupInfo,
           let userInfo = cache?[group.userIds[indexPath.row]] {
            
            cell.setUpCell(group: group, userInfo: userInfo)
            
            cell.rejectButton.addTarget(self, action: #selector(blockUser), for: .touchUpInside)
            
            cell.rejectButton.tag = indexPath.row
        }
        
        return cell
    }
    
    @objc func blockUser (_ sender: UIButton) {
        
        if let blockUserId = self.groupInfo?.userIds[sender.tag] {
            
            showBlockAlertAction(uid: blockUserId)
        }
    }
}
