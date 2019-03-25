//
//  Created by APPSfactory GmbH
//  Copyright © 2017 Appsfactory GmbH. All rights reserved.
//

import UIKit

public protocol Reusable {}


// MARK: - UICollectionViewCell

extension UICollectionReusableView: Reusable {}

public extension Reusable where Self: UICollectionViewCell {
	
	public static var nib: UINib {
		return UINib(nibName: self.reuseIdentifier, bundle: Bundle(for: self))
	}
    
    
	public static var reuseIdentifier: String {
		return String(describing: self)
	}
}


public extension Reusable where Self: UICollectionReusableView {
	
	public static var nib: UINib {
		return UINib(nibName: self.reuseIdentifier, bundle: Bundle(for: self))
	}
    
    
	public static var reuseIdentifier: String {
		return String(describing: self)
	}
}


// MARK: - UICollectionView

public extension UICollectionView {
	
	public func register<T: UICollectionViewCell>(cellType: T.Type) {
		self.register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
	}
	
    
	public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
		
		guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
			fatalError("Could not dequeue cell with identifier: \(cellType.reuseIdentifier)")
		}
		
		return cell
	}
	
    
	public func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) {
		self.register(supplementaryViewType.nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: supplementaryViewType.reuseIdentifier)
	}
	
    
	public func dequeueReusableSupplementaryView<T: UICollectionReusableView>
		(ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T {
		
		let dequeueView = self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath)
		guard let view = dequeueView as? T else {
			fatalError("Could not dequeue supplementary view with identifier: \(viewType.reuseIdentifier)")
		}
		
		return view
	}
}


// MARK: - UITableViewCell

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}

public extension Reusable where Self: UITableViewCell {
	
	public static var nib: UINib {
		return UINib(nibName: self.reuseIdentifier, bundle: Bundle(for: self))
	}
    
    
	public static var reuseIdentifier: String {
		return String(describing: self)
	}
}


public extension Reusable where Self: UITableViewHeaderFooterView {
	
	public static var nib: UINib {
		return UINib(nibName: self.reuseIdentifier, bundle: Bundle(for: self))
	}
    
    
	public static var reuseIdentifier: String {
		return String(describing: self)
	}
}


// MARK: - UITableView

public extension UITableView {
	
	public func register<T: UITableViewCell>(cellType: T.Type) {
		self.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
	}
	
    
	public func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
		
		guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
			fatalError("Could not dequeue cell with identifier: \(cellType.reuseIdentifier)")
		}
		
		return cell
	}
	
    
	public func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) {
		self.register(headerFooterViewType.nib, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
	}
	
    
	public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T? {
		
		guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T? else {
			fatalError("Could not dequeue header/footer with identifier: \(viewType.reuseIdentifier)")
		}
		
		return view
	}
}
