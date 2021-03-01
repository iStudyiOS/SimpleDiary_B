//
//  DailyViewController.swift
//  Schedule_B
//
//  Created by Shin on 2/24/21.
//

import UIKit
import Combine

class DailyViewController: UIViewController {
    
    //MARK: Controllers
    var modelController: ScheduleModelController!
    
    //MARK:- Properties
    
    @Published var dateIntShowing: Int? {
        didSet {
            navigationItem.title = dateShowing.koreanString
        }
    }
    var observeTopViewCancellable: AnyCancellable?
    
    var dateShowing: Date {
        dateIntShowing!.toDate!
    }
    
    // MARK:- Init
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TopViewControllerSegue"{
            let topVC = segue.destination as! WeeklyScheduleVC
            topVC.modelController = modelController
            topVC.dateIntChosen = dateIntShowing
            observeTopViewCancellable = topVC.$dateIntChosen.sink { [self] in
                self.dateIntShowing = $0
            }
        }else if segue.identifier == "BottomViewControllerSegue" {
            let bottomVC = segue.destination as! DailyScrollVC
            bottomVC.modelController = modelController
            bottomVC.dateIntShowing = dateIntShowing
            bottomVC.observeTopViewCancellable = $dateIntShowing.sink {
                bottomVC.dateIntShowing = $0
            }
        }else if segue.identifier == "NewScheduleSegue",
                 let editScheduleVC = segue.destination as? EditScheduleVC {
            editScheduleVC.modelController = modelController
            editScheduleVC.recievedDate = dateShowing
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor(rgb: 0x23689b)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let calendarVC = navigationController?.viewControllers.last as? ScheduleCalendarViewController{
            calendarVC.selectedDate = dateShowing 
        }
    }
}
