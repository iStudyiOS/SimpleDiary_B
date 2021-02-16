//
//  DetailMemoViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/15.
//

import UIKit

class DetailMemoViewController: UIViewController {
  
  var memo: Memo?

  // TODO: 메모의 내용을 입력하지 않을 시 저장이 되지 않고 alert문을 띄우도록 할 것.
  
  @IBOutlet weak var titleLabel: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    titleLabel.delegate = self
    
    if let memo = memo {
      navigationItem.title = "메모 수정"
      titleLabel.text = memo.mainText
      contentsTextView.text = memo.contentText
    }
    
    updateSaveButtonState()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard let button = sender as? UIBarButtonItem, button == saveButton else { return }
    
    let title = titleLabel.text ?? ""
    let contents = contentsTextView.text ?? ""
    
    memo = Memo(mainText: title, contentText: contents)
  }
  
  // TODO: 저장 버튼을 누르면 DiaryVC로 전환되며 메모가 추가되도록.

  @IBAction func saveAction(_ sender: Any) {
    
  }
}

extension DetailMemoViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    saveButton.isEnabled = false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      // Hide the keyboard.
      contentsTextView.resignFirstResponder()
      return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
      updateSaveButtonState()
      navigationItem.title = textField.text
  }
  
  private func updateSaveButtonState() {
      let text = titleLabel.text ?? ""
      saveButton.isEnabled = !text.isEmpty
  }
}
