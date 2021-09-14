//
//  PAMNotiReaderViewController.swift
//  NaRaYa
//
//  Created by narongrit kanhanoi on 17/12/2562 BE.
//  Copyright Â© 2562 NaRaYa. All rights reserved.
//

import UIKit

public class PAMNotiReaderViewController: UIViewController {

    var clickURLListener: ((String?) -> Void)?
    var closeListener: (() -> Void)?

    public func onClickURL(listener: @escaping (String?) -> Void) {
        clickURLListener = listener
    }

    public func onClose(listener: @escaping () -> Void) {
        closeListener = listener
    }

    public override func viewDidDisappear(_ animated: Bool) {
        if let closeListener = closeListener {
            closeListener()
        }
    }

}
