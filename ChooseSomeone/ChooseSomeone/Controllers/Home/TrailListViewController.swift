//
//  TrailListViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

class TrailListViewController: BaseViewController {
    
    // MARK: - DataSource & DataSourceSnapshot typelias -
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Trail>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Trail>
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
        }
    }
    
    var themes = ["", "", ""] {
        didSet{
            setUpLabel()
        }
    }
    private var themeLabel = ""
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    enum Section {
        case section
    }
    
    var trails = [Trail]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupCollectionView()
        
        setUpButton()
        
        setUpThemeTag()
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    private func setupCollectionView() {
        
        collectionView.registerCellWithNib(reuseIdentifier: TrailCell.reuseIdentifier, bundle: nil)
        
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        
        configureDataSource()
        configureSnapshot()
    }
    
    func setUpButton() {
        
        let returnButton = UIButton()
        
        let radius = UIScreen.width * 13 / 107
        
        returnButton.frame = CGRect(x: 40, y: 40, width: radius, height: radius)
        
        returnButton.backgroundColor = .white
        
        let image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        
        returnButton.setImage(image, for: .normal)
        
        returnButton.tintColor = .B1
        
        returnButton.layer.cornerRadius = radius / 2
        
        returnButton.layer.masksToBounds = true
        
        returnButton.addTarget(self, action: #selector(returnToPreviousPage), for: .touchUpInside)
        
        self.view.addSubview(returnButton)
    }
    
    func setUpLabel() {
        
        if let label = trails.first?.trailLevel {
            
            switch label {
                
            case 1:
                
                themeLabel = themes[0]
                
            case 2...3:
                
                themeLabel = themes[1]
                
            case 4...5:
                
                themeLabel = themes[2]
                
            default:
                
                return
            }
        }
    }
    
    @objc func returnToPreviousPage() {
        
        navigationController?.popViewController(animated: true)
    }
    
    func setUpThemeTag() {
        
        let view = UIView(frame: CGRect(x: -20, y: 80, width: UIScreen.width / 2 + 10, height: 40))
        
        let label = UILabel(frame: CGRect(x: 20, y: 83, width: 120, height: 35))
        
        view.backgroundColor = .U2
        
        view.layer.cornerRadius = 20
        
        view.layer.masksToBounds = true
        
        label.text = themeLabel
        
        label.textColor = .black
        
        label.textAlignment = .center
        
        label.font = UIFont.regular(size: 18)
        
        collectionView.addSubview(view)
        
        collectionView.addSubview(label)
    }
    
}

extension TrailListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toTrailInfo", sender: trails[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTrailInfo" {
            
            if let trailInfoVC = segue.destination as? TrailInfoViewController {
                
                if let trail = sender as? Trail {
                    
                    trailInfoVC.trail = trail
                }
            }
        }
    }
}

// MARK: - Collection View -

func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    
    return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let height: CGFloat = 300
        
        let groupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { (env) -> [NSCollectionLayoutGroupCustomItem] in
            
            let size = env.container.contentSize
            
            let spacing: CGFloat = 10.0
            
            let itemWidth = (size.width-spacing * 3) / 2
            
            return [
                
                NSCollectionLayoutGroupCustomItem(frame: CGRect(x: (itemWidth+spacing * 2), y: 0, width: itemWidth, height: height * 0.9)),
                
                NSCollectionLayoutGroupCustomItem(frame: CGRect(x: spacing, y: height / 2, width: itemWidth, height: height * 0.9))
            ]
        }
        //        group.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
}
// MARK: - Diffable Data Source -

extension TrailListViewController {
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, model) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrailCell.reuseIdentifier, for: indexPath) as? TrailCell else {
                fatalError("Cannot create new cell")
            }
            cell.setUpCell(model: model)
            
            cell.checkGroupButton.tag = indexPath.row
            
            cell.checkGroupButton.addTarget(self, action: #selector(self.toGroupPage), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func toGroupPage(_ sender: UIButton) {
                self.tabBarController?.selectedIndex = 1
        
        guard let groupVC = UIStoryboard.group.instantiateViewController(identifier: ChooseGroupViewController.identifier) as? ChooseGroupViewController else { return }
        
        groupVC.searchText = trails[sender.tag].trailName
        groupVC.headerView?.groupSearchBar.text = trails[sender.tag].trailName
    
    }
    
    func configureSnapshot() {
        
        snapshot.appendSections([.section])
        
        snapshot.appendItems(trails, toSection: .section)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
