//
//  ViewController.swift
//  Vandelay
//
//  Created by Daniel Saidi on 06/07/2016.
//  Copyright © 2016 Daniel Saidi. All rights reserved.
//

/*
 
 This class intentionally contains most of the code to
 handle the export and import of todo items and photos,
 so that you do not have to jump between many files to
 follow what happens.
 
 When you build your own app, it is strongly suggested
 that you break up the functionality in smaller pieces,
 like a TodoItemExporter and a TodoItemImporter.
 
 */

import UIKit
import Vandelay
import VandelayDropbox
import VandelayQr


class MainViewController: UITableViewController {

    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavBarLogo"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "PhotoSegue":
            let vc = segue.destination as! PhotoViewController
            vc.repository = photoRepository
        case "TodoSegue":
            let vc = segue.destination as! TodoItemViewController
            vc.repository = todoItemRepository
        default: break
        }
    }
    
    
    
    // MARK: - Dependencies
    
    var todoItemRepository = TodoItemRepository()
    var photoRepository = PhotoRepository()
    
    
    
    // MARK: - Properties
    
    let photoFile = "photoAlbum.vandelay"
    let photoUrl = URL(string: "http://danielsaidi.com/vandelay/photoAlbum.vandelay")!
    let todoFile = "todoList.vandelay"
    let todoUrl = URL(string: "http://danielsaidi.com/vandelay/todoList.vandelay")!
    
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var exportPhotoAlbumCell: UITableViewCell!
    @IBOutlet weak var exportTodoItemsCell: UITableViewCell!
    @IBOutlet weak var importPhotoAlbumCell: UITableViewCell!
    @IBOutlet weak var importTodoItemsCell: UITableViewCell!
    @IBOutlet weak var photoAlbumCell: UITableViewCell!
    @IBOutlet weak var todoItemCell: UITableViewCell!
    
    
    
    // MARK: - Private functions
    
    private func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func reloadData() {
        let items = todoItemRepository.getTodoItems()
        let photos = photoRepository.getPhotos()
        todoItemCell.detailTextLabel?.text = "\(items.count) items"
        photoAlbumCell.detailTextLabel?.text = "\(photos.count) photos"
    }
    
    
    
    // MARK: - Export functions
    
    private func exportStateChanged(with result: ExportResult) {
        guard result.state != .inProgress else { return }
        
        if let error = result.error {
            alert(title: "Ooops...", message: error.localizedDescription)
        } else {
            alert(title: "Done", message: exportMessage(for: result))
        }
    }
    
    private func exportMessage(for result: ExportResult) -> String {
        if let filePath = result.filePath {
            return "The data was exported to \(filePath)"
        }
        
        switch result.state {
        case .cancelled:
            return "The export was cancelled."
        case .completed:
            return "The export completed, using the \"\(result.exportMethod)\" method"
        case .failed:
            return "The export failed with error \(result.error?.description ?? "N/A")."
        case .inProgress:
            return "The export is in progress. Please wait."
        }
    }
    
    fileprivate func exportPhotoAlbum() {
        let title = "Export photo album"
        let message = "How do you want to export the photo album?"
        let alert = ExportAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.delegate = self
        alert.add(dataExporter: FileExporter(fileName: photoFile), withTitle: "To a local file")
        alert.add(dataExporter: DropboxExporter(fileName: photoFile), withTitle: "To a Dropbox file")
        alert.add(dataExporter: EmailExporter(fileName: photoFile), withTitle: "As an e-mail attachment")
        alert.add(dataExporter: MessageExporter(fileName: photoFile), withTitle: "As a message attachment")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func exportPhotoAlbum(with exporter: DataExporter) {
        let photos = photoRepository.getPhotos()
        let data = NSKeyedArchiver.archivedData(withRootObject: photos)
        exporter.export(data: data) { result in
            self.exportStateChanged(with: result)
        }
    }
    
    fileprivate func exportTodoList() {
        let title = "Export todo list"
        let message = "How do you want to export the todo list?"
        let alert = ExportAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.delegate = self
        alert.add(stringExporter: PasteboardExporter(), withTitle: "To the pasteboard")
        alert.add(stringExporter: FileExporter(fileName: todoFile), withTitle: "To a local file")
        alert.add(stringExporter: DropboxExporter(fileName: todoFile), withTitle: "To a Dropbox file")
        alert.add(stringExporter: EmailExporter(fileName: todoFile), withTitle: "As an e-mail attachment")
        alert.add(stringExporter: MessageExporter(fileName: photoFile), withTitle: "As a message attachment")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func exportTodoList(with exporter: StringExporter) {
        let items = todoItemRepository.getTodoItems()
        let dicts = items.map { $0.toDictionary() }
        guard let json = JsonObjectSerializer().serialize(dicts).result else {
            print("Hey, serializing your todo items did not go too well! Aborting...")
            return
        }
        exporter.export(string: json) { result in
            self.exportStateChanged(with: result)
        }
    }
    
    
    
    // MARK: - Import functions
    
    private func importMessage(for result: ImportResult) -> String {
        switch result.state {
        case .cancelled:
            return "Your import was cancelled."
        case .completed:
            return "Your data was imported, using the \"\(result.importMethod)\" method"
        case .failed:
            return "Your import failed with error \(result.error?.description ?? "N/A")."
        case .inProgress:
            return "Your import is in progress. Please wait."
        }
    }
    
    fileprivate func importPhotoAlbum() {
        let title = "Import photos"
        let message = "From where do you want to import photos?"
        let alert = ImportAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.delegate = self
        alert.add(dataImporter: FileImporter(fileName: photoFile), withTitle: "From a local file")
        alert.add(dataImporter: UrlImporter(url: photoUrl), withTitle: "From a custom url")
        alert.add(dataImporter: DropboxImporter(fileName: photoFile), withTitle: "From Dropbox")
        alert.add(dataImporter: QrCodeImporter(vc: self), withTitle: "By scanning a qr code")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func importPhotoAlbum(with importer: DataImporter) {
        importer.importData { result in
            guard self.verify(result) else { return }
            
            if let data = result.data {
                let obj = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let photos = obj as? [Photo] {
                    photos.forEach { self.photoRepository.addPhoto($0) }
                    self.reloadData()
                } else {
                    self.alert(title: "Ooops...", message: "Invalid data")
                    return
                }
            }
            
            self.alert(title: "Done", message: self.importMessage(for: result))
        }
    }
    
    fileprivate func importTodoList() {
        let title = "Import todo items"
        let message = "From where do you want to import todo items?"
        let alert = ImportAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.delegate = self
        alert.add(stringImporter: PasteboardImporter(), withTitle: "From the pasteboard")
        alert.add(stringImporter: FileImporter(fileName: todoFile), withTitle: "From a local file")
        alert.add(stringImporter: UrlImporter(url: todoUrl), withTitle: "From a custom url")
        alert.add(stringImporter: DropboxImporter(fileName: todoFile), withTitle: "From Dropbox")
        alert.add(stringImporter: QrCodeImporter(vc: self), withTitle: "By scanning a qr code")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func importTodoList(with importer: StringImporter) {
        importer.importString { result in
            guard self.verify(result) else { return }
            
            if let string = result.string {
                let jsonResult = JsonObjectSerializer().deserialize(string)
                if let error = jsonResult.error {
                    self.alert(title: "Ooops...", message: error.localizedDescription)
                    return
                }
                
                if let arr = jsonResult.result as? [[String : AnyObject]] {
                    let items = arr.map { TodoItem(dict: $0) }
                    items.forEach { self.todoItemRepository.addTodoItem($0) }
                    self.reloadData()
                } else {
                    self.alert(title: "Ooops...", message: "Invalid data in JSON")
                    return
                }
            }
            
            self.alert(title: "Done", message: self.importMessage(for: result))
        }
    }
    
    private func verify(_ result: ImportResult) -> Bool {
        guard result.state != .inProgress else { return false }
        guard let error = result.error else { return true }
        
        alert(title: "Import error", message: error.localizedDescription)
        return false
    }
}



// MARK: - - ExportAlertControllerDelegate

extension MainViewController: ExportAlertControllerDelegate {
    
    func alert(_ alert: ExportAlertController, didPick exporter: DataExporter) {
        exportPhotoAlbum(with: exporter)
    }
    
    func alert(_ alert: ExportAlertController, didPick exporter: StringExporter) {
        exportTodoList(with: exporter)
    }
}



// MARK: - - ImportAlertControllerDelegate

extension MainViewController: ImportAlertControllerDelegate {
    
    func alert(_ alert: ImportAlertController, didPickDataImporter importer: DataImporter) {
        importPhotoAlbum(with: importer)
    }
    
    func alert(_ alert: ImportAlertController, didPickStringImporter importer: StringImporter) {
        importTodoList(with: importer)
    }
}



// MARK: - - UITableViewDelegate

extension MainViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        switch cell {
        case exportPhotoAlbumCell: exportPhotoAlbum()
        case exportTodoItemsCell: exportTodoList()
        case importTodoItemsCell: importTodoList()
        case importPhotoAlbumCell: importPhotoAlbum()
        default: break
        }
    }
}
