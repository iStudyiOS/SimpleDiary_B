//
//  DailyTableVC.swift
//  Schedule_B
//
//  Created by Shin on 2/26/21.
//

import SwiftUI
import Combine

class DailyScrollVC: UIHostingController<DailyScrollView> {
    // MARK: Controller
    var modelController: ScheduleModelController!
    
    // MARK:- Properties
    var observeTopViewCancellable: AnyCancellable?
    var dateIntShowing: Int? {
        didSet {
            rootView.date = dateIntShowing!.toDate!
            schedules = modelController.getSchedules(for: dateIntShowing!)
        }
    }
    
    private var _schedules = [Schedule]()
    private var schedules:[Schedule] {
        set {
            _schedules = newValue.sorted()
            rootView.schedules = _schedules
        }
        get {
            _schedules
        }
    }
    
    // MARK:- Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    required init?(coder aDecoder: NSCoder) {
        let showDetail: (Schedule) -> Void = { toShow in
            print(toShow)
        }
        super.init(coder: aDecoder, rootView: DailyScrollView(tapScheduleHandeler: showDetail))
    }
}
