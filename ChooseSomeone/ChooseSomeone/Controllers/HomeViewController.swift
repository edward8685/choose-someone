//
//  HomeViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/23.
//

import UIKit
import FirebaseFirestore
import grpc

class HomeViewController: UIViewController {
    
    private var userId = "1357988"
    
    private let themes = ["愜意的走", "想流點汗", "百岳行前訓"]
    
    private let images = ["", "", ""]
    
    private var trails = [Trail]()
    
    var user = User(
        uid: "",
        userName: "Ed Chang",
        userEmail: "",
        joinedRoomIds: [],
        totalKilos: 100,
        totalFriends: 20,
        totalGroups: 5)
    
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
        fetchTrailData()
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    func setUpTableView() {
        
        tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.lk_registerCellWithNib(identifier: TrailThemeCell.identifier, bundle: nil)
        
        view.stickSubView(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.separatorStyle = .none
    
    }
    
    func fetchTrailData() {
        
        TrailManager.shared.fetchTrails { [weak self] result in
            
            switch result {
                
            case .success(let trails):
                
                self?.trails = trails
                print(trails)
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}


extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = Bundle.main.loadNibNamed(HomeHeaderCell.identifier, owner: self, options: nil)?.first as? HomeHeaderCell
        else {fatalError("Could not create HeaderView")}
        
        headerView.setUpHeaderView(user: user)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toTrailList", sender: nil)
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
        themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrailThemeCell.identifier, for: indexPath) as? TrailThemeCell
                
        else {fatalError("Could not create Cell")}
        
        cell.setUpCell(theme: themes, image: images, indexPath: indexPath)
    
        return cell
    }
}
