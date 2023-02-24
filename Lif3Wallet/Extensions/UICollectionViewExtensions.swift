

#if os(iOS) || os(tvOS)
import UIKit


// MARK: - Properties
public extension UICollectionView {
	
	/// SwifterSwift: Index path of last item in collectionView.
	public var indexPathForLastItem: IndexPath? {
		return indexPathForLastItem(inSection: lastSection)
	}
	
	/// SwifterSwift: Index of last section in collectionView.
	public var lastSection: Int {
		return numberOfSections > 0 ? numberOfSections - 1 : 0
	}
	
	/// SwifterSwift: Number of all items in all sections of collectionView.
	public var numberOfItems: Int {
		var section = 0
		var itemsCount = 0
		while section < self.numberOfSections {
			itemsCount += numberOfItems(inSection: section)
			section += 1
		}
		return itemsCount
	}
	
}


// MARK: - Methods
public extension UICollectionView {
    
	/// SwifterSwift: IndexPath for last item in section.
	///
	/// - Parameter section: section to get last item in.
	/// - Returns: optional last indexPath for last item in section (if applicable).
	public func indexPathForLastItem(inSection section: Int) -> IndexPath? {
		guard section >= 0 else {
			return nil
		}
		guard numberOfItems(inSection: section) > 0 else {
			return IndexPath(item: 0, section: section)
		}
		return IndexPath(item: numberOfItems(inSection: section) - 1, section: section)
	}
	
	/// Reload data with a completion handler.
	///
	/// - Parameter completion: completion handler to run after reloadData finishes.
	public func reloadData(_ completion: @escaping () -> Void) {
		UIView.animate(withDuration: 0, animations: {
			self.reloadData()
		}, completion: { _ in
			completion()
		})
	}
    
    /// SwifterSwift: Deque reusable UICollectionViewCell using class name.
    ///
    /// - Parameter name: UICollectionViewCell type.
    /// - Parameter indexPath: Location of cell in collectionView.
    /// - Returns: UICollectionViewCell object with associated class name.
    public func dequeReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as! T
    }
    
    /// SwifterSwift: Deque reusable UICollectionReusableView using class name.
    ///
    /// - Parameter ofKind: The kind of supplementary view to retrieve. This value is defined by the layout object.
    /// - Parameter name: UICollectionReusableView type.
    /// - Parameter indexPath: Location of cell in collectionView.
    /// - Returns: UICollectionReusableView object with associated class name.
    func dequeReusableSupplementaryView<T: UICollectionReusableView>(ofKind: String, withClass name: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: String(describing: name), for: indexPath) as! T
    }
    
    /// SwifterSwift: Register UICollectionReusableView using class name.
    ///
    /// - Parameter kind: The kind of supplementary view to retrieve. This value is defined by the layout object.
    /// - Parameter name: UICollectionReusableView type.
    func register<T: UICollectionReusableView>(supplementaryViewOfKind kind: String, withClass name: T.Type) {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: name))
    }
    
    
    /// SwifterSwift: Register UICollectionViewCell using class name.
    ///
    /// - Parameter nib: Nib file used to create the collectionView cell.
    /// - Parameter name: UICollectionViewCell type.
    func register<T: UICollectionViewCell>(nib: UINib?, forCellWithClass name: T.Type) {
        register(nib, forCellWithReuseIdentifier: String(describing: name))
    }
    
    /// SwifterSwift: Register UICollectionViewCell using class name.
    ///
    /// - Parameter name: UICollectionViewCell type.
    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }
    
    /// SwifterSwift: Register UICollectionReusableView using class name.
    ///
    /// - Parameter nib: Nib file used to create the reusable view.
    /// - Parameter kind: The kind of supplementary view to retrieve. This value is defined by the layout object.
    /// - Parameter name: UICollectionReusableView type.
    func register<T: UICollectionReusableView>(nib: UINib?, forSupplementaryViewOfKind kind: String, withClass name: T.Type) {
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: name))
    }

}
  
  // MARK: Reusable support for UICollectionView
  
  public extension UICollectionView {
    /**
     Register a NIB-Based `UICollectionViewCell` subclass (conforming to `Reusable` & `NibLoadable`)
     
     - parameter cellType: the `UICollectionViewCell` (`Reusable` & `NibLoadable`-conforming) subclass to register
     
     - seealso: `register(_:,forCellWithReuseIdentifier:)`
     */
    final func register<T: UICollectionViewCell>(cellType: T.Type)
      where T: Reusable & NibLoadable {
        self.register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Register a Class-Based `UICollectionViewCell` subclass (conforming to `Reusable`)
     
     - parameter cellType: the `UICollectionViewCell` (`Reusable`-conforming) subclass to register
     
     - seealso: `register(_:,forCellWithReuseIdentifier:)`
     */
    final func register<T: UICollectionViewCell>(cellType: T.Type)
      where T: Reusable {
        self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Returns a reusable `UICollectionViewCell` object for the class inferred by the return-type
     
     - parameter indexPath: The index path specifying the location of the cell.
     - parameter cellType: The cell class to dequeue
     
     - returns: A `Reusable`, `UICollectionViewCell` instance
     
     - note: The `cellType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - seealso: `dequeueReusableCell(withReuseIdentifier:,for:)`
     */
    final func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
      where T: Reusable {
        let bareCell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        guard let cell = bareCell as? T else {
          fatalError(
            "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
              + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
              + "and that you registered the cell beforehand"
          )
        }
        return cell
    }
    
    /**
     Register a NIB-Based `UICollectionReusableView` subclass (conforming to `Reusable` & `NibLoadable`)
     as a Supplementary View
     
     - parameter supplementaryViewType: the `UIView` (`Reusable` & `NibLoadable`-conforming) subclass
     to register as Supplementary View
     - parameter elementKind: The kind of supplementary view to create.
     
     - seealso: `register(_:,forSupplementaryViewOfKind:,withReuseIdentifier:)`
     */
    final func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String)
      where T: Reusable & NibLoadable {
        self.register(
          supplementaryViewType.nib,
          forSupplementaryViewOfKind: elementKind,
          withReuseIdentifier: supplementaryViewType.reuseIdentifier
        )
    }
    
    /**
     Register a Class-Based `UICollectionReusableView` subclass (conforming to `Reusable`) as a Supplementary View
     
     - parameter supplementaryViewType: the `UIView` (`Reusable`-conforming) subclass to register as Supplementary View
     - parameter elementKind: The kind of supplementary view to create.
     
     - seealso: `register(_:,forSupplementaryViewOfKind:,withReuseIdentifier:)`
     */
    final func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String)
      where T: Reusable {
        self.register(
          supplementaryViewType.self,
          forSupplementaryViewOfKind: elementKind,
          withReuseIdentifier: supplementaryViewType.reuseIdentifier
        )
    }
    
    /**
     Returns a reusable `UICollectionReusableView` object for the class inferred by the return-type
     
     - parameter elementKind: The kind of supplementary view to retrieve.
     - parameter indexPath:   The index path specifying the location of the cell.
     - parameter viewType: The view class to dequeue
     
     - returns: A `Reusable`, `UICollectionReusableView` instance
     
     - note: The `viewType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - seealso: `dequeueReusableSupplementaryView(ofKind:,withReuseIdentifier:,for:)`
     */
    final func dequeueReusableSupplementaryView<T: UICollectionReusableView>
      (ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T
      where T: Reusable {
        let view = self.dequeueReusableSupplementaryView(
          ofKind: elementKind,
          withReuseIdentifier: viewType.reuseIdentifier,
          for: indexPath
        )
        guard let typedView = view as? T else {
          fatalError(
            "Failed to dequeue a supplementary view with identifier \(viewType.reuseIdentifier) "
              + "matching type \(viewType.self). "
              + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
              + "and that you registered the supplementary view beforehand"
          )
        }
        return typedView
    }
  }
  
  
#endif
