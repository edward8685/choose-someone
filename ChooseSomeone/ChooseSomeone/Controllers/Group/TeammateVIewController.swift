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
        
        setNavigationBar()
        
        view.stickSubView(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI Settings -
    
    func setNavigationBar() {
        
        self.title = "\(groupInfo?.groupName ?? "揪團") - 成員"
        
        UINavigationBarAppearance().backgroundColor = .B1
        
        UINavigationBar.appearance().barTintColor = .B1
        
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.medium(size: 22) ?? UIFont.systemFont(ofSize: 22)
        ]
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let leftButton = PreviousPageButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let image = UIImage(systemName: "chevron.left")
        
        leftButton.setImage(image, for: .normal)
        
        leftButton.addTarget(self, action: #selector(popToPreviousPage), for: .touchUpInside)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: leftButton), animated: true)
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
