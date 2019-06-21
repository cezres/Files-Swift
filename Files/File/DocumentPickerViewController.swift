//
//  DocumentPickerViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/5/13.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class DocumentPickerViewController: DocumentBrowserViewController {
    enum Mode {
        case move
        case copy
    }

    static func picker(with mode: Mode, directory: URL = DocumentDirectory, showIn controller: UIViewController) -> DocumentPickerViewController {
        let picker = DocumentPickerViewController(directory: directory)
        controller.present(UINavigationController(rootViewController: picker), animated: true, completion: nil)
        return picker
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        DocumentDirectoryPickerViewController
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
    }
}
