//
//  TeammateController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/9.
//

import UIKit

class TeammateViewController: BaseViewController {
    
    var cache: [String: UserInfo]?
    
    var groupInfo: Group?
    
    private var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    // MARK: - View Life Cycle
    
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
    
    // MARK: - Action
    
    func setNavigationBar() {
        
        self.title = "\(groupInfo?.groupName ?? "揪團") - 成員"
        
        UINavigationBar.appearance().backgroundColor = .B1
        
        UINavigationBar.appearance().barTintColor = .B1
        
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                            NSAttributedString.Key.font: UIFont.medium(size: 22) ?? UIFont.systemFont(ofSize: 22)]
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let button = UIButton()
        
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        let image = UIImage(systemName: "chevron.left")
        
        button.setImage(image, for: .normal)
        
        button.layer.cornerRadius = button.frame.height / 2
        
        button.layer.masksToBounds = true
        
        button.tintColor = .B1
        
        button.backgroundColor = .white
        
        button.addTarget(self, action: #selector(backToPreviousVC), for: .touchUpInside)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: button), animated: true)
        
    }
    
    @objc func backToPreviousVC() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension TeammateViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let num =  groupInfo?.userIds.count else { fatalError() }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier, for: indexPath) as? MemberCell
                
        else {fatalError("Could not create Cell")}
        
        if let group = groupInfo,
           let userInfo = cache?[group.userIds[indexPath.row]] {
            
            cell.setUpCell(group: group, userInfo: userInfo)
            
            cell.rejectButton.addTarget(self, action: #selector(blockUser), for: .touchUpInside)
            
            cell.rejectButton.tag = indexPath.row
        }
        
        return cell
    }
    
    @objc func blockUser (_ sender: UIButton) {
        
        let controller = UIAlertController(title: "要封鎖該用戶", message: "你將看不到該使用者的訊息及揪團" , preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let blockAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            
            if let blockUserId = self.groupInfo?.userIds[sender.tag] {
                
                UserManager.shared.blockUser(blockUserId: blockUserId)
                
                UserManager.shared.userInfo.blockList?.append(blockUserId)
            }
            
            sender.isEnabled = false
            
            sender.alpha = 0.5
        }
        
        controller.addAction(cancelAction)
        
        controller.addAction(blockAction)
        
        self.present(controller, animated: true, completion: nil)
    }
}
