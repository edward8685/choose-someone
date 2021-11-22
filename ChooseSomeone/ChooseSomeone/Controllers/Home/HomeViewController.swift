//
//  HomeViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Lottie

class HomeViewController: BaseViewController {
    
    private var userInfo = UserManager.shared.userInfo
    
    var isHeaderViewCreated: Bool = false
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func updateUserInfo(notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String: UserInfo] {

            if let userInfo = userInfo[self.userInfo.uid] {
                self.userInfo = userInfo
            }
            guard let headerView = headerView else { return }
            
            headerView.updateUserInfo(user: self.userInfo)

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
        
        TrailManager.shared.fetchTrails { result in
            
            switch result {
                
            case .success(let trails):
                
                self.trails = trails
                
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
        
        isHeaderViewCreated = true
        
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
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrailThemes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrailThemeCell.identifier, for: indexPath) as? TrailThemeCell
                
        else {fatalError("Could not create Cell")}
        
        cell.setUpCell(theme: TrailThemes.allCases[indexPath.row].rawValue, image: TrailThemes.allCases[indexPath.row].image)
        
        if indexPath.row % 2 == 1 {
            cell.themeLabel.textColor = .black
        }
        
        return cell
    }
}
