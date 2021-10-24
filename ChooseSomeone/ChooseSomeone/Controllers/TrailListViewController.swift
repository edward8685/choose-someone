//
//  TrailListViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

class TrailListViewController: UIViewController {
    
    // MARK: - DataSource & DataSourceSnapshot typelias -
    typealias DataSource = UICollectionViewDiffableDataSource<Section, TrailInfo>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, TrailInfo>
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
        }
    }
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    enum Section {
        case section
    }
    
    struct TrailInfo : Hashable {
        var trailName : String
        //        var position : String
        //        var level : String
        //        var length : String
        //        var picture : UIImage
    }
    
    let trialsInfo = [
        TrailInfo(trailName:"Trail 1"),
        TrailInfo(trailName:"Trail 2"),
        TrailInfo(trailName:"Trail 3"),
        TrailInfo(trailName:"Trail 4"),
        TrailInfo(trailName:"Trail 5")
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupCollectionView()
        
        setUpButton()
        
        setUpThemeTag()
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    private func setupCollectionView() {
        
        collectionView.lk_registerCellWithNib(reuseIdentifier: TrailCell.reuseIdentifier, bundle: nil)
        
        
        collectionView.backgroundColor = .systemBlue
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        
        configureDataSource()
        configureSnapshot()
    }
    
    func setUpButton() {
        
        let returnButton = UIButton()
        
        let radius = UIScreen.width * 13 / 107
        returnButton.frame = CGRect(x: 20, y: 20, width: radius, height: radius)
        returnButton.backgroundColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
        let image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .heavy))
        returnButton.setImage(image, for: .normal)
        returnButton.tintColor = UIColor.hexStringToUIColor(hex: "19C3DA")
        returnButton.layer.cornerRadius = radius / 2
        returnButton.layer.masksToBounds = true
        
        returnButton.addTarget(self, action: #selector(returnToPreviousPage), for: .touchUpInside)
        
        collectionView.addSubview(returnButton)
    }
    
    @objc func returnToPreviousPage() {
        navigationController?.popViewController(animated: true)
    }
    
    func setUpThemeTag() {
        
        let view = UIView(frame: CGRect(x: -20, y: 80, width: UIScreen.width / 2 + 10, height: 40))
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: 105, height: 35))
        
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "CFFFDA")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)

        collectionView.addSubview(view)
        view.addSubview(label)
//        collectionView.addSubview(label)
    }
}

extension TrailListViewController: UICollectionViewDelegate {
    
}
    
// MARK: - Collection View -

func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
        
        let inset: CGFloat = 10
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        //            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        //        group.interItemSpacing = .flexible(8)
        
        let height: CGFloat = 280
        let groupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { (env) -> [NSCollectionLayoutGroupCustomItem] in
            let size = env.container.contentSize
            let spacing: CGFloat = 10.0
            let itemWidth = (size.width-spacing * 3) / 2
            return [
                NSCollectionLayoutGroupCustomItem(frame: CGRect(x: (itemWidth+spacing * 2), y: 0, width: itemWidth, height: height * 0.9)),
                NSCollectionLayoutGroupCustomItem(frame: CGRect(x: spacing , y: height / 2, width: itemWidth, height: height * 0.9))
            ]
        }
//        group.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        
        let section = NSCollectionLayoutSection(group: group)
        
//                section.orthogonalScrollingBehavior = .groupPaging
//                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//                section.interGroupSpacing = 20
        
        //        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        //        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        //        section.boundarySupplementaryItems = [sectionHeader]
        
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
            cell.trailName.text = model.trailName
            return cell
        }
    }
    
    func configureSnapshot() {
        
        snapshot.appendSections([.section])
        snapshot.appendItems(trialsInfo, toSection: .section)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}
