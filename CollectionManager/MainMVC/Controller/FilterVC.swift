//
//  FilterVC.swift
//  CollectionManager
//
//  Created by Vadim Katenin on 14.04.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
    func filterViewController(
        filter: FilterVC,
        didSelectPredicate predicate: NSPredicate?,
        sortDescriptor: NSSortDescriptor?)
}

class FilterVC: UITableViewController {
    
    // MARK: - Count labels
    @IBOutlet weak var firsCatCountLbl: UILabel!
    @IBOutlet weak var secondCatCountLbl: UILabel!
    @IBOutlet weak var thirdCatCountLbl: UILabel!
    @IBOutlet weak var totalCountLbl: UILabel!
    
    // MARK: - Sections labels
    @IBOutlet weak var aZnameCell: UITableViewCell!
    @IBOutlet weak var zAnameCell: UITableViewCell!
    @IBOutlet weak var oldestCell: UITableViewCell!
    @IBOutlet weak var latestCell: UITableViewCell!
    
    @IBOutlet weak var showAllCell: UITableViewCell!
    @IBOutlet weak var firstCatCell: UITableViewCell!
    @IBOutlet weak var secondCatCell: UITableViewCell!
    @IBOutlet weak var thirdCatCell: UITableViewCell!
    
    @IBOutlet weak var applyButton: UIBarButtonItem!
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    
    var selectedIndexPath: IndexPath? = nil
    var indexPathsArray: [IndexPath] = []
    var sortCellArray: [UITableViewCell] = []
    var filterCellArray: [UITableViewCell] = []
    
    lazy var firstPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Collection.category), "1")
    }()
    
    lazy var secondPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Collection.category), "2")
    }()
    
    lazy var thirdPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Collection.category), "3")
    }()
    
    lazy var nameASortDescriptor: NSSortDescriptor = {
        let compareSelector =
            #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Collection.name),
                                ascending: true,
                                selector: compareSelector)
    }()
    
    lazy var nameZSortDescriptor: NSSortDescriptor = {
        let compareSelector =
            #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Collection.name),
                                ascending: false,
                                selector: compareSelector)
    }()
    
    lazy var oldestSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Collection.date),
                                ascending: true,
                                selector: nil)
    }()
    
    lazy var latestSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Collection.date),
                                ascending: false,
                                selector: nil)
    }()
    
    weak var delegate: FilterViewControllerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyButton.isEnabled = false
        
        if coreDataStack != nil {
            print("Not nil")
            populateShowAllLabel()
            populateFirstCountLabel()
            populateSecondCountLabel()
            populateThirdCountLabel()
        } else {
            print("Core data stack is nil")
        }
    }
}

// MARK: - IBAction
extension FilterVC {
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func applyAction(_ sender: UIBarButtonItem) {
        delegate?.filterViewController(
            filter: self,
            didSelectPredicate: selectedPredicate,
            sortDescriptor: selectedSortDescriptor)
        
        dismiss(animated: true)
    }
}



// MARK: - UITableViewDelegate
extension FilterVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        switch cell {
        case aZnameCell:
            sortCellCheck(cellToCheck: aZnameCell, descriptor: nameASortDescriptor)
            zAnameCell.accessoryType = .none
            oldestCell.accessoryType = .none
            latestCell.accessoryType = .none
        case zAnameCell:
            sortCellCheck(cellToCheck: zAnameCell, descriptor: nameZSortDescriptor)
            aZnameCell.accessoryType = .none
            oldestCell.accessoryType = .none
            latestCell.accessoryType = .none
        case oldestCell:
            sortCellCheck(cellToCheck: oldestCell, descriptor: oldestSortDescriptor)
            aZnameCell.accessoryType = .none
            zAnameCell.accessoryType = .none
            latestCell.accessoryType = .none
        case latestCell:
            sortCellCheck(cellToCheck: latestCell, descriptor: latestSortDescriptor)
            aZnameCell.accessoryType = .none
            zAnameCell.accessoryType = .none
            oldestCell.accessoryType = .none
            case firstCatCell:
                filterCellCheck(cellToCheck: firstCatCell, predicate: firstPredicate)
            secondCatCell.accessoryType = .none
            thirdCatCell.accessoryType = .none
            showAllCell.accessoryType = .none
            case secondCatCell:
                filterCellCheck(cellToCheck: secondCatCell, predicate: secondPredicate)
            firstCatCell.accessoryType = .none
            thirdCatCell.accessoryType = .none
            showAllCell.accessoryType = .none
            case thirdCatCell:
                filterCellCheck(cellToCheck: thirdCatCell, predicate: thirdPredicate)
            firstCatCell.accessoryType = .none
            secondCatCell.accessoryType = .none
            showAllCell.accessoryType = .none
            case showAllCell:
            filterCellCheck(cellToCheck: showAllCell, predicate: nil)
            firstCatCell.accessoryType = .none
            secondCatCell.accessoryType = .none
            thirdCatCell.accessoryType = .none
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Cell logic functions
    // sortCells
    func sortCellCheck(cellToCheck: UITableViewCell, descriptor: NSSortDescriptor) {
        if sortCellArray.contains(cellToCheck) {
            guard let index = sortCellArray.firstIndex(of: cellToCheck) else {return}
            sortCellArray.remove(at: index)
            cellToCheck.accessoryType = .none
            selectedSortDescriptor = nil
            if filterCellArray.isEmpty {
                applyButton.isEnabled = false
            }
        } else {
            sortCellArray.removeAll()
            sortCellArray.append(cellToCheck)
            cellToCheck.accessoryType = .checkmark
            selectedSortDescriptor = nil
            selectedSortDescriptor = descriptor
            applyButton.isEnabled = true
        }
    }
    // filterCells
    func filterCellCheck(cellToCheck: UITableViewCell, predicate: NSPredicate?) {
        if sortCellArray.isEmpty {
            applyButton.isEnabled = false
        }
        
        if filterCellArray.contains(cellToCheck) {
            guard let index = filterCellArray.firstIndex(of: cellToCheck) else {return}
            filterCellArray.remove(at: index)
            cellToCheck.accessoryType = .none
            selectedPredicate = nil
            if sortCellArray.isEmpty {
                applyButton.isEnabled = false
            }
        } else {
            filterCellArray.removeAll()
            filterCellArray.append(cellToCheck)
            cellToCheck.accessoryType = .checkmark
            selectedPredicate = nil
            selectedPredicate = predicate
            applyButton.isEnabled = true
        }
        
    }
    
    
    
}

// MARK: - Populate functions
extension FilterVC {
    
    func populateShowAllLabel() {
        let fetchRequest =
            NSFetchRequest<NSNumber>(entityName: "Collection")
        fetchRequest.resultType = .countResultType
        do {
            let countResult =
                try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            totalCountLbl.text = "items: \(count)"
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
        }
    }
    
    func populateFirstCountLabel() {
        let fetchRequest =
            NSFetchRequest<NSNumber>(entityName: "Collection")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = firstPredicate
        do {
            let countResult =
                try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            firsCatCountLbl.text = "items: \(count)"
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
        }
    }
    
    func populateSecondCountLabel() {
        let fetchRequest =
            NSFetchRequest<NSNumber>(entityName: "Collection")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = secondPredicate
        do {
            let countResult =
                try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            secondCatCountLbl.text = "items: \(count)"
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
        }
    }
    
    func populateThirdCountLabel() {
        let fetchRequest =
            NSFetchRequest<NSNumber>(entityName: "Collection")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = thirdPredicate
        do {
            let countResult =
                try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            thirdCatCountLbl.text = "items: \(count)"
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
        }
    }
}
