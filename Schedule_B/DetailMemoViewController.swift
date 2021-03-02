//
//  DetailMemoViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/15.
//

import UIKit

class DetailMemoViewController: UIViewController {

  var memoType: Memo?
  
  // TODO: 메모 수정 후 저장 버튼 누를 때, dismiss 안 되는 것.
  // TODO: 수정 후 저장을 누르면, 메모가 수정되는 것이 아니라 새로운 메모가 추가된다. update 함수 구현하기.
  
  @IBOutlet weak var titleLabel: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
  // MARK: 변경된 메모 타입을 dirayVC에 전달.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination.children.first as? DiaryViewController {
      vc.editMemoType = memoType
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    titleLabel.delegate = self
    
    if let memo = memoType {
      navigationItem.title = "메모 수정"
      
      titleLabel.text = memo.mainText
      contentsTextView.text = memo.contentText
    }
}
  
  func update(memo: Memo) {
    titleLabel.text = memo.mainText
    contentsTextView.text = memo.contentText
  }

  // MARK: 저장 버튼 action
  @IBAction func onSave(sender: UIBarButtonItem) {
    let title = titleLabel.text
    let contents = contentsTextView.text ?? ""

    if title == "" {
      showAlert("제목을 입력해주세요")
      return
    } else {
      // 새로운 메모를 추가할 때
      let newMemo = Memo(mainText: title!, contentText: contents)
      Memo.dummyMemoList.append(newMemo)
      dismiss(animated: true, completion: nil)
    }
    
    // 메모 수정 상태일 때
    if let memo = memoType {
      update(memo: memo)
      dismiss(animated: true, completion: nil)
    }
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
  
  // MARK: Configuring Alert
  func showAlert(_ message: String) {
    let alert = UIAlertController(
      title: .none,
      message: message,
      preferredStyle: .alert)
    let offAction = UIAlertAction(title: "확인", style: .default)
    
    alert.addAction(offAction)
    self.present(alert, animated: true)
  }
}

// MARK: textFieldDelegate
extension DetailMemoViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    saveButton.isEnabled = true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      // Hide the keyboard.
      contentsTextView.resignFirstResponder()
      return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
      navigationItem.title = textField.text
  }
}
