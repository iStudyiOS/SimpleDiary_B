//
//  DetailMemoViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/15.
//

import UIKit

class DetailMemoViewController: UIViewController {
  
  enum ViewType {
    case add
    case update
  }
  
  var memoType: Memo?
  var viewType: ViewType = .add
  var savedMemos: [Memo] = []
  
  // TODO: 데이터 주입해주기
  
  // TODO: 메모 수정 / 메모 추가 시, navigationBar title 바뀌도록 할 것.
  
  // TODO: 메모의 내용을 입력하지 않을 시 저장이 되지 않고 alert문을 띄우도록 할 것.
  
  @IBOutlet weak var titleLabel: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    titleLabel.delegate = self
    
    if let memo = memoType {
      navigationItem.title = "메모 수정"
      
      titleLabel.text = memo.mainText
      contentsTextView.text = memo.contentText
    }
    
    navigationItem.leftBarButtonItem = cancelButton
    updateSaveButtonState()
  }
  
  // MARK: 메모 추가 시, tableView에 띄워주는 코드.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)

    guard let button = sender as? UIBarButtonItem, button == saveButton else { return }

    let title = titleLabel.text ?? ""
    let contents = contentsTextView.text ?? ""

    // TODO: Refactoring
    memoType = Memo(mainText: title, contentText: contents)
    let newMemo = Memo(mainText: title, contentText: contents)
    savedMemos.append(memoType ?? newMemo)

  }
  
  @IBAction func saveAction(_ sender: Any) {
  }
  
  // MARK: 취소 버튼 action
  @IBAction func cancelAction(_ sender: Any) {
    let addMode = presentingViewController is UINavigationController
    
    if addMode {
      dismiss(animated: true, completion: nil)
    } else if let ownedNVC = navigationController {
      ownedNVC.popViewController(animated: true)
    } else {
      fatalError("detailMemoVC가 navigation controller 안에 없습니다.")
    }
  }
}


// MARK: textFieldDelegate
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
