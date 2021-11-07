//
//  TrackRecordsViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import UIKit

class TrackRecordsViewController: UIViewController {
    
    // MARK: - DataSource & DataSourceSnapshot typelias -
    typealias DataSource = UITableViewDiffableDataSource<Section, Record>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Record>
    
    enum Section {
        case section
    }
    

    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    var records = [Record](){
        didSet{
            tableView.reloadData()
        }
    }

    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
        fetchRecords()
        
        navigationController?.isNavigationBarHidden = true
    
    }
    
    func setUpTableView() {
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.registerCellWithNib(identifier: TrackRecordCell.identifier, bundle: nil)
  
        view.stickSubView(tableView)
        
        tableView.backgroundColor = .lightGray
        
//        configureDataSource()
//        
//        configureSnapshot()

    }
    
    func fetchRecords() {
        RecordManager.shared.fetchRecords { [weak self] result in
            
            switch result {
                
            case .success(let records):
                
                self?.records = records
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
        }
extension TrackRecordsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toUserRecord", sender: records[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserRecord" {
            if let recordVC = segue.destination as? UserRecordViewController {
                
                if let record = sender as? Record {
                    recordVC.record = record
                }
            }
        }
    }
    
}

extension TrackRecordsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "My records"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackRecordCell.identifier, for: indexPath) as? TrackRecordCell else {
            fatalError("Cannot create new cell")
        }
        
        cell.setUpCell(model: self.records[indexPath.row])

        return cell
    }
    
}

extension TrackRecordsViewController {
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { (tableView, indexPath, model) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackRecordCell.identifier, for: indexPath) as? TrackRecordCell else {
                fatalError("Cannot create new cell")
            }
            
            cell.setUpCell(model: self.records[indexPath.row])
            cell.backgroundColor = .green

            return cell
        })
        tableView.dataSource = dataSource
    }
    
    func configureSnapshot() {
        
        snapshot.appendSections([.section])
        snapshot.appendItems(records, toSection: .section)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
