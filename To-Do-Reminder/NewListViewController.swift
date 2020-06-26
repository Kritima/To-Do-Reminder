//
//  NewListViewController.swift
//  To-Do-Reminder
//
//  Created by Kritima Kukreja on 2020-06-23.
//  Copyright © 2020 Kritima Kukreja. All rights reserved.
//

import UIKit

class NewListViewController: UIViewController {
    @IBOutlet weak var doneBarButton: UIButton!
    @IBOutlet weak var cancelBarButton: UIButton!
    @IBOutlet weak var newListTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneBarButton.isEnabled = false
        textFieldDidEndEditing(textField: newListTextField)
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if (newListTextField.text?.isEmpty != nil)
        {
            self.doneBarButton.isEnabled = true
        }
    }

}
