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
    
    // MARK: - Class Properties -
    
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
    
    private var headerView: HomeHeaderCell?
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUserInfo),
            name: NSNotification.userInfoDidChanged,
            object: nil
        )
        
        setUpTableView()
        
        fetchTrailData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func updateUserInfo(notification: Notification) {

            guard let headerView = headerView else { return }
            
            headerView.updateUserInfo(user: UserManager.shared.userInfo)
    }
    
    // MARK: - Methods -
    
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
    // clasfied by Trail_difficult
    func manageTrailData() {
        
        for trail in trails {
            
            switch trail.trailLevel {
                
            case 1:
                
                easyTrails.append(trail)
                
            case 2...3:
                
                mediumTrails.append(trail)
                
            case 4...5:
                
                hardTrails.append(trail)
                
            default:
                return
            }
        }
    }
    
    // MARK: - UI Settings -
    
    func setUpTableView() {
        
        tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.registerCellWithNib(identifier: TrailThemeCell.identifier, bundle: nil)
        
        view.stickSubView(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.separatorStyle = .none
    }
}

// MARK: - TableView Delegate -

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: HomeHeaderCell = .loadFromNib()
        
        self.headerView = headerView
        
        headerView.updateUserInfo(user: UserManager.shared.userInfo)
        
        return self.headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var sender = [Trail]()
        
        switch indexPath.row {
            
        case 0:
            
            sender = easyTrails
            
        case 1:
            
            sender = mediumTrails
            
        case 2:
            
            sender = hardTrails
            
        default:
            return
        }
        
        performSegue(withIdentifier: SegueIdentifier.trailList.rawValue, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.trailList.rawValue {
            if let trailListVC = segue.destination as? TrailListViewController {
                
                if let trails = sender as? [Trail] {
                    
                    trailListVC.trails = trails
                }
            }
        }
    }
}

// MARK: - TableView Data Source -

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrailThemes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TrailThemeCell = tableView.dequeueCell(for: indexPath)
        
        cell.setUpCell(
            theme: TrailThemes.allCases[indexPath.row].rawValue,
            image: TrailThemes.allCases[indexPath.row].image)
        
        if indexPath.row % 2 == 1 {
            cell.themeLabel.textColor = .black
        }
        
        return cell
    }
}
