//
//  UITextFieldNavigationToolbar.swift
//  Pods
//
//  Created by Thanh Pham on 6/27/16.
//
//

import UIKit

protocol UITextFieldNavigationToolbarDelegate: class {
    func textFieldNavigationToolbarDidTapPreviousButton(textFieldNavigationToolbar: UITextFieldNavigationToolbar)
    func textFieldNavigationToolbarDidTapNextButton(textFieldNavigationToolbar: UITextFieldNavigationToolbar)
    func textFieldNavigationToolbarDidTapDoneButton(textFieldNavigationToolbar: UITextFieldNavigationToolbar)
}

/// Class for the `inputAccessoryView`.
public class UITextFieldNavigationToolbar: UIToolbar {
    weak var navigationDelegate: UITextFieldNavigationToolbarDelegate?

    /// Holds the previous button.
    public let previousButton: UITextFieldNavigationToolbarButtonItem

    /// Holds the next button.
    public let nextButton: UITextFieldNavigationToolbarButtonItem

    /// Holds the done button.
    public let doneButton: UITextFieldNavigationToolbarButtonItem

    /// Has not been implemented. Use `init()` instead.
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }

    init() {
        previousButton = UITextFieldNavigationToolbarButtonItem(title: " ❮ ", style: .plain, target: nil, action: nil)
        nextButton = UITextFieldNavigationToolbarButtonItem(title: " ❯ ", style: .plain, target: nil, action: nil)
        doneButton = UITextFieldNavigationToolbarButtonItem(title: " ▼ ", style: .plain, target: nil, action: nil)

        super.init(frame: CGRect.zero)

        previousButton.isEnabled = false
        previousButton.target = self
        previousButton.action = #selector(previousButtonDidTap)
        nextButton.isEnabled = false
        nextButton.target = self
        nextButton.action = #selector(nextButtonDidTap)
        doneButton.target = self
        doneButton.action = #selector(doneButtonDidTap)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items = [previousButton, nextButton, flexibleSpace, doneButton]
        sizeToFit()
    }

    func previousButtonDidTap() {
        if let navigationDelegate = navigationDelegate {
            navigationDelegate.textFieldNavigationToolbarDidTapPreviousButton(textFieldNavigationToolbar: self)
        }
    }

    func nextButtonDidTap() {
        if let navigationDelegate = navigationDelegate {
            navigationDelegate.textFieldNavigationToolbarDidTapNextButton(textFieldNavigationToolbar: self)
        }
    }

    func doneButtonDidTap() {
        if let navigationDelegate = navigationDelegate {
            navigationDelegate.textFieldNavigationToolbarDidTapDoneButton(textFieldNavigationToolbar: self)
        }
    }
}
