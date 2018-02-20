//
//  SelectionCollectionView.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class SelectionCollectionView: UICollectionView {
    /// The number of items to display for the collection view.
    var numberOfItems = { 0 }
    /// The cell identifier to dequeue cells with.
    var cellReuseIdentifier: String?
    /// Configures cell with data before being displayed.
    var configureCell: ((_ index: Int, _ cell: UICollectionViewCell) -> Void)?
    /// Called when a cell at an index did get selected.
    var didSelectIndex: ((_ index: Int) -> Void)?
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = .greatestFiniteMagnitude
        }
        backgroundColor = .white
        alwaysBounceHorizontal = true
        
        dataSource = self
        delegate = self
    }
}

extension SelectionCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let identifier = cellReuseIdentifier {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            configureCell?(indexPath.row, cell)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectIndex?(indexPath.row)
    }
}
