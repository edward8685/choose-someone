//
//  HomeViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class HomeViewController: BaseViewController {
    
    private var uid = UserManager.shared.userInfo.uid
    
    private var userInfo = UserManager.shared.userInfo
    
    private let themes = ["愜意的走", "想流點汗", "百岳挑戰"]
    
    private let images = [UIImage.asset(.scene_1),
                          UIImage.asset(.scene_2),
                          UIImage.asset(.scene_3)]
    
    private var trails = [Trail]() {
        
        didSet {
            
            manageTrailData()
        }
    }
    
    private var easyTrails = [Trail]()
    
    private var mediumTrails = [Trail]()
    
    private var hardTrails = [Trail]()
    
    private var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    var headerView: HomeHeaderCell?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: NSNotification.userInfoDidChanged, object: nil)
        
        setUpTableView()
        
        fetchTrailData()
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    @objc func updateUserInfo(notification: NSNotification) {
        DispatchQueue.main.async {
            
            if let userInfo = notification.userInfo?[self.uid] as? UserInfo {
                
                self.headerView?.updateUserInfo(user: userInfo)
                
        }
            self.tableView.reloadData()
        }
    }
    
    func setUpTableView() {
        
        tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.registerCellWithNib(identifier: TrailThemeCell.identifier, bundle: nil)
        
        view.stickSubView(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.separatorStyle = .none
    
    }
    
    func fetchTrailData() {
        
        TrailManager.shared.fetchTrails { [weak self] result in
            
            switch result {
                
            case .success(let trails):
                
                self?.trails = trails
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    //clasfied by Trail_difficult
    func manageTrailData() {
        
        for trail in trails {
            
            switch trail.trailLevel {
                
            case 1:
                
                easyTrails.append(trail)
                
            case 2...3:
                
                mediumTrails.append(trail)
                
            default:
                
                hardTrails.append(trail)
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = Bundle.main.loadNibNamed(HomeHeaderCell.identifier, owner: self, options: nil)?.first as? HomeHeaderCell
        else {fatalError("Could not create HeaderView")}
        
        self.headerView = headerView
        
        headerView.updateUserInfo(user: userInfo)
        
        return self.headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            
            performSegue(withIdentifier: "toTrailList", sender: easyTrails)
            
        case 1:
            
            performSegue(withIdentifier: "toTrailList", sender: mediumTrails)
            
        case 2:
            
            performSegue(withIdentifier: "toTrailList", sender: hardTrails)
            
        default:
            
            return
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTrailList" {
            if let trailListVC = segue.destination as? TrailListViewController {
                
                if let trails = sender as? [Trail] {
                    
                    trailListVC.trails = trails
                }
                
                trailListVC.themes = themes
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrailThemeCell.identifier, for: indexPath) as? TrailThemeCell
                
        else {fatalError("Could not create Cell")}
        
        cell.setUpCell(theme: themes[indexPath.row], image: images[indexPath.row])
        
        if indexPath.row % 2 == 1 {
            cell.themeLabel.textColor = .black
        }

        return cell
    }
}
