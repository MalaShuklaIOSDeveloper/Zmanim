//
//  CalendarCollectionView.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class CalendarCollectionView: UICollectionView {
    /// Configures cell with data before being displayed.
    var configureCell: ((_ index: Int, _ cell: CalendarCell) -> Void)?
    /// Called when a cell at an index did get selected.
    var didSelectIndex: ((_ index: Int) -> Void)?
    
    enum CellIdentifier: String {
        case calendarCell
    }
    
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
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = .greatestFiniteMagnitude
        }
        backgroundColor = .white
        alwaysBounceHorizontal = true
        
        dataSource = self
        delegate = self
    }
}

extension CalendarCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.calendarCell.rawValue, for: indexPath) as! CalendarCell
        cell.layer.cornerRadius = 10
        configureCell?(indexPath.row, cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height - 20
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectIndex?(indexPath.row)
    }
}
