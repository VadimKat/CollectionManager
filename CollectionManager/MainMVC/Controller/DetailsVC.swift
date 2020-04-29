//
//  DetailsVC.swift
//  CollectionManager
//
//  Created by Vadim Katenin on 16.04.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import UIKit

class DetailsVC: UITableViewController {
    
    var collection: Collection?
    
    @IBOutlet weak var photoLabel: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    override func viewDidLoad() {
       super.viewDidLoad()

       configureView()
     }

    func configureView() {
         guard let collection = collection else { return }
        nameLabel.text = collection.name
        categoryLabel.text = "Category number : \(collection.category)"
        guard let itemsPhoto = collection.pictureLink?.photo else {return}
        photoLabel.image = UIImage(data: itemsPhoto)
    }
    
}
