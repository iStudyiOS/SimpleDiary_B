//
//  NewLineTextView.swift
//  Schedule_B
//
//  Created by Shin on 3/1/21.
//

import UIKit

class NewLineTextView: UITextView, UITextViewDelegate{
    
    // TODO: ( shift + enter -> new line) / ( enter -> end editing )
//    override var keyCommands: [UIKeyCommand]? {
//        return [UIKeyCommand(input: "\n", modifierFlags: .shift, action: #selector(newLine(sender:)))]
//    }
//
//    @objc func newLine(sender: UIKeyCommand) {
//        insertText("\n")
//    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        toggleDefault()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        toggleDefault()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Dismiss keyboard
        if text == "\n" {
            return textView.resignFirstResponder()
        }
        return true
    }
    static let defaultDescription = "내용을 입력해주세요"
    private func toggleDefault() {
        if self.text == NewLineTextView.defaultDescription {
            self.text = ""
            self.textColor = .black
        }else if self.text.isEmpty {
            self.text = NewLineTextView.defaultDescription
            self.textColor = .lightGray
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        print("new line feature is not implemented yet")    }
}
