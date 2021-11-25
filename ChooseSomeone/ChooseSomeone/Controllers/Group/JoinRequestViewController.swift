//
//  JoinRequestViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import UIKit

class JoinRequestViewController: BaseViewController {
    
    // MARK: - DataSource & DataSourceSnapshot typelias -
    typealias DataSource = UITableViewDiffableDataSource<Section, Request>
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Request>
    
    enum Section {
        case section
    }
    
    private var dataSource: DataSource!
    
    lazy var requests = [Request]() {
        
        didSet {
            
            requests.forEach { request in
                
                fetchUserData(uid: request.requestId)
            }
        }
    }
    
    lazy var cache = [String: UserInfo]() {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    private var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
        }
    }
    
    lazy var dimmingView = UIView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpDimmingView()
        
        setUpTableView()
        
        setUpButton()
        
        configureDataSource()
        
        configureSnapshot()
    }
    
    func setUpDimmingView() {
        
        view.stickSubView(dimmingView)
        
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
        
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func addRequestListener() {
        
        GroupManager.shared.fetchRequest { result in
            
            switch result {
                
            case .success(let requests):
                
                self.requests = requests
                
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
    
    func setUpTableView() {
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: MemberCell.identifier, bundle: nil)
        
        view.addSubview(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setUpButton() {
        
        let dismissButton = UIButton()
        
        dismissButton.frame = CGRect(x: UIScreen.width - 50, y: 30, width: 30, height: 30)
        
        dismissButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        dismissButton.backgroundColor = UIColor.hexStringToUIColor(hex: "64696F")
        
        let image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular))
        
        dismissButton.setImage(image, for: .normal)
        
        dismissButton.tintColor = .white
        
        dismissButton.layer.cornerRadius = dismissButton.frame.height / 2
        
        dismissButton.layer.masksToBounds = true
        
        dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        view.addSubview(dismissButton)
    }
    
    @objc func dismissVC() {
        
        dismiss(animated: true, completion: nil)
    }
}

extension JoinRequestViewController: UITableViewDelegate {
    
    @objc func acceptRequest(_ sender: UIButton) {
        
        GroupManager.shared.addUserToGroup(
            groupId: requests[sender.tag].groupId,
            userId: requests[sender.tag].requestId
        ) { result in
            
            switch result {
                
            case .success:
                
                print("add user to group succesfully")
                
            case .failure(let error):
                
                print("add user to group failure: \(error)")
            }
        }
        
        GroupManager.shared.removeRequest(
            groupId: requests[sender.tag].groupId,
            userId: requests[sender.tag].requestId
        ) { result in
            switch result {
                
            case .success:
                
                print("accept succesfully")
                self.requests.remove(at: sender.tag)
                
                self.configureSnapshot()
                
            case .failure(let error):
                
                print("accept failure: \(error)")
                
            }
        }
    }
    
    @objc func rejectRequest(_ sender: UIButton) {
        
        GroupManager.shared.removeRequest(
            groupId: requests[sender.tag].groupId,
            userId: requests[sender.tag].requestId
        ) { result in
            
            switch result {
                
            case .success:
                
                print("reject succesfully")
                
                self.requests.remove(at: sender.tag)
                self.configureSnapshot()
                
            case .failure(let error):
                
                print("reject failure: \(error)")
            }
        }
    }
}

extension JoinRequestViewController {
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { (tableView, indexPath, model) ->UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier, for: indexPath) as? MemberCell else {
                fatalError("Cannot create new cell")
            }
            
            if let user = self.cache[self.requests[indexPath.row].requestId] {
                
                cell.setUpCell(model: model, userInfo: user)
                
            }
            
            cell.acceptButton.addTarget(self, action: #selector(self.acceptRequest), for: .touchUpInside)
            
            cell.acceptButton.tag = indexPath.row
            
            cell.rejectButton.addTarget(self, action: #selector(self.rejectRequest), for: .touchUpInside)
            
            cell.rejectButton.tag = indexPath.row
            
            return cell
        }
    }
    
    func configureSnapshot() {
        
        var snapshot = DataSourceSnapshot()
        
        snapshot.appendSections([.section])
        
        snapshot.appendItems(requests, toSection: .section)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
