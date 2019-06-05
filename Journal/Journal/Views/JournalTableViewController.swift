//
//  JournalTableViewController.swift
//  Journal
//
//  Created by Kobe McKee on 6/3/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import UIKit
import CoreData

class JournalTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let entryController = EntryController()
    
    // Mark: TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! EntryTableViewCell
        
        cell.entry = fetchedResultsController.object(at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            entryController.deleteEntry(entry: fetchedResultsController.object(at: indexPath))
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name
    }
    
    
    
    // Mark: FetchResults
    
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        
        let fetchRequset: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequset.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true), NSSortDescriptor(key: "mood", ascending: true)]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequset, managedObjectContext: moc, sectionNameKeyPath: "mood", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
        
        
    }()

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let oldIndexPath = indexPath,
            let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            
        default:
            break
        }
    }
    

    // Mark: Segues
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewEntrySegue" {
            let destinationVC = segue.destination as! EntryDetailViewController
            destinationVC.entryController = entryController
        } else if segue.identifier == "EntryDetailSegue" {
            let destinationVC = segue.destination as! EntryDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.entry = fetchedResultsController.object(at: indexPath)
            }
            destinationVC.entryController = entryController
        }
    }
    

}
