//
//  ZipFileType.swift
//  Files
//
//  Created by 翟泉 on 2019/9/7.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import Zip
import Toast_Swift

struct ZipFileType: FileType {
    let name = "Zip"
    let pathExtensions = ["zip"]

    func thumbnail(file: File, completion: @escaping (UIImage) -> Void) {
        completion(UIImage(named: "icon_zip")!)
    }

    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController) {
        let destination = document.generateFilePath(file.name.deletingPathExtension)

        UIApplication.shared.beginIgnoringInteractionEvents()
        controller.view.makeToastActivity(.center)
        DispatchQueue.global().async {
            do {
                try Zip.unzipFile(file.url, destination: destination, overwrite: true, password: nil, progress: nil)
            } catch {
                DispatchQueue.main.async {
                    controller.view.makeToast(error.localizedDescription)
                }
            }
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                controller.view.hideToastActivity()
            }
        }
    }
}

