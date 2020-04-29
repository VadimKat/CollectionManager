//
//  AddTableVC.swift
//  CollectionManager
//
//  Created by Vadim Katenin on 14.04.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import UIKit
import CoreData

class AddTableVC: UITableViewController {
    
    @IBOutlet weak var photoLabel: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButtonLabel: UIBarButtonItem!
    
    @IBOutlet weak var picker: UIPickerView!
    
    var coreDataStack: CoreDataStack!
    
    var pickerArray = ["None", "1", "2", "3"]
    var selectedPickerValue: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.picker.delegate = self
        self.picker.dataSource = self
    }
}

extension AddTableVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerValue = pickerArray[pickerView.selectedRow(inComponent: 0)]
    }
    
    
}


// MARK: - IBActions
extension AddTableVC {
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        let collection = Collection(context: coreDataStack.managedContext)
        collection.name = nameTextField.text
        collection.date = Date()
        
        if selectedPickerValue != "None" && selectedPickerValue != "" {
            let number = Int(selectedPickerValue)
            collection.category = Int16(number!)
        }
        
//        if let number = Int(categoryLabel.text!) {
//            collection.category = Int16(number)
//        }
        if let image = photoLabel.image, let imageToScale = image.pngData() {
            collection.pictureThumbnail = imageDataScaledToHeight(imageToScale, height: 120)
            
            let pictures = ItemsPictures(context: coreDataStack.managedContext)
            pictures.photo = image.pngData()
            collection.pictureLink = pictures
        }
        
        coreDataStack.saveContext()
        performSegue(withIdentifier: "unwindToNotesList", sender: self)
    }    
    
}

// MARK: ImagePicker
extension AddTableVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photoLabel.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        photoLabel.contentMode = .scaleAspectFill
        photoLabel.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - didSelectRowAt
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alertController = UIAlertController(title: "Chose your photo", message: nil, preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                self.choseImagePickerAction(source: .camera)
            }
            let galeryAction = UIAlertAction(title: "Photo", style: .default) { action in
                self.choseImagePickerAction(source: .photoLibrary)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cameraAction)
            alertController.addAction(galeryAction)
            alertController.addAction(cancelAction)
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = tableView
                popoverController.sourceRect = CGRect(x: view.frame.width/2, y: view.frame.height/3, width: 50, height: 50)
            }
            present(alertController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func choseImagePickerAction(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
}


// MARK: - imageDataScaledToHeight
extension AddTableVC {
    
    func imageDataScaledToHeight(_ imageData: Data, height: CGFloat) -> Data {
        
        let image = UIImage(data: imageData)!
        let oldHeight = image.size.height
        let scaleFactor = height / oldHeight
        let newWidth = image.size.width * scaleFactor
        let newSize = CGSize(width: newWidth, height: height)
        let newRect = CGRect(x: 0, y: 0, width: newWidth, height: height)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!.jpegData(compressionQuality: 0.8)!
    }
}
