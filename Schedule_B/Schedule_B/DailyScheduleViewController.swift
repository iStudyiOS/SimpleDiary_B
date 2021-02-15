//
//  DailyScheduleViewController.swift
//  Schedule_B
//
//  Created by 오현식 on 2021/02/15.
//

import UIKit

class DailyScheduleViewController: UIViewController {
    
    var day: Int = 0
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var scheduleTime: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
    }
    
    @IBAction func timeSelected(_ sender: Any) {
    }
}

extension DailyScheduleViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {
            return UICollectionViewCell()
        }
        cell.update(todo: "schedule\(day)")
        day += 1
        return cell
    }
}

extension DailyScheduleViewController: UICollectionViewDelegate {
    
}

extension DailyScheduleViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 50
        return CGSize(width: width, height: height)
        
    }
}

class ScheduleCell: UICollectionViewCell {
    @IBOutlet weak var todo: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func checkButtonTapped(_ sender: Any) {
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
    }
    
    func update(todo: String) {
        self.todo.text = todo
    }
}
