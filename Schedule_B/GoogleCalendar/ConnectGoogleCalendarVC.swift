//
//  ConnectGoogleCalendarVC.swift
//  Schedule_B
//
//  Created by Shin on 2/22/21.
//

import UIKit

class ConnectGoogleCalendarVC: UITableViewController {
    
    // MARK: Controller
    private var googleOAuthGather: OAuthGather!
    private var requestAPIScope: GoogleOAuthConfig.CalendarAPIScope = .calendarReadAndWrite
    
    // MARK:- Properties
    private var tokenData: OAuthGather.TokenData?
    @IBOutlet weak var calendarIDInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var scopeController: UISegmentedControl!
    
    // MARK:- User Intents
    
    @IBAction func scopeController(_ sender: UISegmentedControl) {
        requestAPIScope = GoogleOAuthConfig.CalendarAPIScope(rawValue: sender.selectedSegmentIndex)!
    }
    
    @IBAction func tapAddCalendarButton(_ sender: UIButton) {

        guard tokenData != nil else {
            let alertController = UIAlertController(
                title: "로그인이 필요합니다",
                message: "구글 계정으로 로그인 해주세요",
                preferredStyle: .alert)
            let dismissAction = UIAlertAction(
                title: "확인", style: .cancel)
            alertController.addAction(dismissAction)
            present(alertController, animated: true)
            return
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard let userInputID = calendarIDInput.text , emailPred.evaluate(with: userInputID) else {
            let alertController = UIAlertController(
                title: "캘린더 ID를 확인해주세요",
                message: "이메일 주소를 입력해주세요 기본 캘린더는 사용자의 구글 이메일 주소입니다",
                preferredStyle: .alert)
            let dismissAction = UIAlertAction(
                title: "확인", style: .cancel)
            alertController.addAction(dismissAction)
            present(alertController, animated: true)
            return
        }
        requestCalendarData(with: userInputID)
    }
    
    private func requestCalendarData(with calendarID: String) {
        let urlString = "https://apidata.googleusercontent.com/caldav/v2/\(calendarID)/events"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue("\(tokenData!.token_type)  \(tokenData!.access_token)", forHTTPHeaderField: "Authorization")
        let promise = request.sendWithPromise()
        promise.observe { [weak weakSelf = self] result in
            switch result {
            case .success(let data):
                weakSelf?.parseCalendarData(data)
            case .failure(let error):
                print("error: ", error.localizedDescription)
            }
        }
    }
    /// Not implemented yet
    private func parseCalendarData(_ data: Data) {
//        let parsed = ICalendar.load(string: String(data: data, encoding: .utf8)!)
//        var schedules = [Schedule]()
//        for calendar in parsed {
//            calendar.subComponents.forEach {
//                if let event = $0 as? ICalendarEvent {
//                    print("event: \(event)")
//                    let scheduleDate: Schedule.DateType
//                    if let startDate = event.dtstart,
//                       let endDate = event.dtend {
//                        scheduleDate = .period(start: startDate, end: endDate)
//                    }else {
//                        scheduleDate = .spot(event.dtstamp)
//                    }
//                    let alarm: Schedule.Alarm?
//                    let alarmAtrributes: [String: String]
//                    if let iCalendarAlarm = event.subComponents.first(where: { $0 is ICalendarAlarm }) as? ICalendarAlarm {
//                        alarmAtrributes = iCalendarAlarm.otherAttrs
//
//                        guard let trigger = alarmAtrributes["TRIGGER"] else {
//                            fatalError("iCalendar event: \(event) has alarm with out trigger\n \(alarmAtrributes)")
//                        }
//                        let isAhead = trigger.first! == "-"
//                        let dayTo: Int? = trigger.contains("D") ? 0: 0
//                    }else {
//                        alarm = nil
//                    }
//                }
//            }
//            print("other attributes ----------")
//            print(calendar.otherAttrs)
//        }
    }
    
    @IBAction func tapLoginButton(_ sender: Any) {
        let webViewController = WebViewController()
        let showAlert: (Error)-> Void = { [weak weakSelf = self] error in
            let error = error as NSError
            let alertContoller = UIAlertController(
                title: "연동 실패",
                message: error.code == 1 ? "사용자가 연결을 취소하였습니다":
                    "알 수 없는 오류가 발생했습니다",
                preferredStyle: .alert)
            print(error.localizedDescription)
            let dissmissAction = UIAlertAction(
                title: "확인", style: .cancel)
            alertContoller.addAction(dissmissAction)
            webViewController.dismiss(animated: true) {
                weakSelf?.present(alertContoller, animated: true)
            }
        }
        googleOAuthGather = OAuthGather(
            with: GoogleOAuthConfig(for: requestAPIScope),
            drawTo: self, errorHandling: showAlert)
        
        present(webViewController, animated: true)
        googleOAuthGather.tokenPromise.observe { [weak weakSelf = self]  result in
            switch result {
            case .success(let data):
                DispatchQueue.main.sync {
                    webViewController.webView.stopLoading()
                    webViewController.dismiss(animated: true)
                    weakSelf?.loginButton.isEnabled = false
                    weakSelf?.scopeController.isEnabled = false
                    weakSelf?.loggedInLabel.isHidden = false
                }
                weakSelf?.tokenData = data
            case .failure(let error):
                print("Connect cancled")
                print(error)
                showAlert(error)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.adjustsImageWhenDisabled = true
    }
    
}
