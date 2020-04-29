//
//  MainTableVC.swift
//  CollectionManager
//
//  Created by Vadim Katenin on 14.04.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import UIKit
import CoreData

class MainTableVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortAction: UIBarButtonItem!
    
    lazy var coreDataStack = CoreDataStack(modelName: "CollectionManagerData")
   
    
    var fetchedResultsController: NSFetchedResultsController<Collection>!
    
    func loadCoreData() -> NSFetchedResultsController<Collection> {
        let fetchRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Collection.name), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        tableView.rowHeight = 150
        
        fetchedResultsController = loadCoreData()
        
        do {
            print("fetching")
            try fetchedResultsController.performFetch()
            print("fetched")
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "add":
             let navController = segue.destination as? UINavigationController
             let destinationVC = navController?.topViewController as? AddTableVC
            destinationVC?.coreDataStack = coreDataStack
        case "showDetails":
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destinationVC = segue.destination as? DetailsVC
            let selectedItem = fetchedResultsController.object(at: indexPath)
            destinationVC?.collection = selectedItem
        case "sortSegue":
           let navController = segue.destination as? UINavigationController
             let destinationVC = navController?.topViewController as? FilterVC
            destinationVC?.coreDataStack = coreDataStack
           destinationVC?.delegate = self
        default:
            return
        }
        
    }
    
    @IBAction func unwindToNotesList(_ segue: UIStoryboardSegue) {
        
//        tableView.reloadData()
        print("Unwinding to Notes List")
    }
    
}

// MARK: IBActions
extension MainTableVC {
    
    @IBAction func addNewPressed(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "add", sender: self)
    }
    
    @IBAction func sortActionPressed(_ sender: UIBarButtonItem) {
      performSegue(withIdentifier: "sortSegue", sender: self)
    }
}

// MARK: TableViewDelegate
extension MainTableVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let objectToDelite = fetchedResultsController.object(at: indexPath)
            coreDataStack.managedContext.delete(objectToDelite)
            coreDataStack.saveContext()
//            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



// MARK: TableViewDataSource
extension MainTableVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetch = fetchedResultsController.fetchedObjects?.count {
            return fetch
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)  as! CellMainTableVC 
        configure(cell: cell, for: indexPath)
        return cell
    }
}

// MARK: Cell configure
extension MainTableVC {
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? CellMainTableVC else { return }
        
        let data = fetchedResultsController.object(at: indexPath)
        cell.itemsName.text = data.name
        if let picture = data.pictureThumbnail {
        cell.itemsPhoto.image = UIImage(data: picture)
        }
    }
}


// MARK: - FetchedResultsControllerDelegate
extension MainTableVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            print("Insert")
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            print("delete")
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! CellMainTableVC
            configure(cell: cell, for: indexPath!)
            print("congigure")
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            print("moving")
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

// MARK: - FilterViewControllerDelegate
extension MainTableVC: FilterViewControllerDelegate {

  func filterViewController(filter: FilterVC, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
    
    
    func loadFilteredData() -> NSFetchedResultsController<Collection> {
        let fetchRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        
        if let newSortDescriptor = sortDescriptor {
                fetchRequest.sortDescriptors = [newSortDescriptor]
            } else {
                let oldSortDescriptor = NSSortDescriptor(key: #keyPath(Collection.name), ascending: true)
                fetchRequest.sortDescriptors = [oldSortDescriptor]
        }
        
        if let newPredicate = predicate {
            fetchRequest.predicate = newPredicate
        } else {
            fetchRequest.predicate = nil
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }
    
    fetchedResultsController = loadFilteredData()
    
    do {
        print("fetching")
        try fetchedResultsController.performFetch()
        print("fetched")
    } catch let error as NSError {
        print("Fetching error: \(error), \(error.userInfo)")
    }
    
    tableView.reloadData()
}
}
