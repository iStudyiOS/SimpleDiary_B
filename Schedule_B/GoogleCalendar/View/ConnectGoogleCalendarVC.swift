//
//  ConnectGoogleCalendarVC.swift
//  Schedule_B
//
//  Created by Shin on 2/22/21.
//

import UIKit

class ConnectGoogleCalendarVC: UITableViewController{
    
    // MARK: Controller
    private var googleOAuthGather: OAuthGather!
    private var requestAPIScope: GoogleOAuthConfig.CalendarAPIScope = .calendarReadAndWrite
    let eventListTableVC = EventListTableVC()
    var scheduleModelController: ScheduleModelController!
    
    // MARK:- Properties
    
    @IBOutlet weak var calendarIDInput: UITextField!
    @IBOutlet weak var addCalendarIDButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var scopeController: UISegmentedControl!
    @IBOutlet weak var loadingProgessBar: UIProgressView!
    @IBOutlet weak var groupControlCell: UITableViewCell!
    @IBOutlet weak var eventListCell: UITableViewCell!
    @IBOutlet weak var totalEventNumberLabel: UILabel!
    @IBOutlet weak var eventListTableView: UITableView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    
    private var schedulesReceived: [Schedule]? {
        didSet {
            eventListTableVC.events = schedulesReceived
            DispatchQueue.runOnlyMainThread { [weak weakSelf = self] in
                weakSelf?.loadingProgessBar.setProgress(1.0, animated: true)
                weakSelf?.groupControlCell.isHidden = false
                weakSelf?.eventListCell.isHidden = false
                weakSelf?.loadingProgessBar.isHidden = true
                weakSelf?.totalEventNumberLabel.text = weakSelf?.schedulesReceived == nil ? "" : String(weakSelf!.schedulesReceived!.count) + "개의 이벤트"
            }
        }
    }
    // MARK:- User Intents
    
    @IBAction func scopeController(_ sender: UISegmentedControl) {
        requestAPIScope = GoogleOAuthConfig.CalendarAPIScope(rawValue: sender.selectedSegmentIndex)!
    }
    
    @IBAction func tapLoginButton(_ sender: Any) {
        loginButton.isEnabled = false
        let webViewController = WebViewController()
        let showAlert: (Error)-> Void = { [weak weakSelf = self] error in
            let error = error as NSError
            DispatchQueue.runOnlyMainThread {
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
                    weakSelf?.loginButton.isEnabled = true
                }
            }
        }
        googleOAuthGather = OAuthGather(
            with: GoogleOAuthConfig(for: requestAPIScope),
            drawTo: self, errorHandling: showAlert)
        
        present(webViewController, animated: true)
        googleOAuthGather.tokenPromise.observe { [weak weakSelf = self]  result in
            switch result {
            case .success(let token):
                DispatchQueue.runOnlyMainThread {
                    webViewController.webView.stopLoading()
                    webViewController.dismiss(animated: true)
                    weakSelf?.loginButton.isEnabled = false
                    weakSelf?.loginButton.isHidden = true
                    weakSelf?.scopeController.isEnabled = false
                    weakSelf?.loggedInLabel.isHidden = false
                    weakSelf?.calendarIDInput.isEnabled = true
                    weakSelf?.addCalendarIDButton.isEnabled = true
                }
                _ = token.saveInKeyChain(for: OAuthGather.OAuthToken.keyChainAccountForGoogleOAuth)
            case .failure(let error):
                showAlert(error)
            }
        }
    }
    
    @IBAction func tapAddCalendarButton(_ sender: UIButton) {
        guard let token = OAuthGather.OAuthToken.readInKeyChain(
                for: OAuthGather.OAuthToken.keyChainAccountForGoogleOAuth),
              token.expires_at > Date() else {
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
        calendarIDInput.isEnabled = false
        addCalendarIDButton.isEnabled = false

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
        loadingProgessBar.isHidden = false
        loadingProgessBar.setProgress(0.2, animated: true)
        requestCalendarData(with: userInputID, token: token)
    }
    @IBAction func changeGroupInclusion(_ sender: UISwitch) {
        eventListTableVC.changeGroupInclusion(to: sender.isOn)
    }
    @IBAction func tapSaveButton(_ sender: UIButton) {
        totalEventNumberLabel.isHidden = false
        loadingSpinner.isHidden = false
        guard scheduleModelController.importSchedules(
                eventListTableVC.schedulesToImport) else {
            let alertController = UIAlertController(
                title: "등록되지 않은 일정이 있습니다",
                message: "일부 일정은 알람이 등록되지 않았습니다 알림 설정을 켜주세요", preferredStyle: .alert)
            let dismissAction = UIAlertAction(
                title: "확인", style: .cancel) {_ in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(dismissAction)
            present(alertController, animated: true)
            return
        }
        // sleep for show spinner
        Thread.sleep(forTimeInterval: TimeInterval(1))
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    // MARK:- Calendar data logic
    
    private func requestCalendarData(with calendarID: String, token: OAuthGather.OAuthToken) {
        loadingProgessBar.setProgress(0.4, animated: true)
        let urlString = "https://apidata.googleusercontent.com/caldav/v2/\(calendarID)/events"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue("\(token.token_type)  \(token.access_token)", forHTTPHeaderField: "Authorization")
        let promise = request.sendWithPromise()
        promise.observe { [weak weakSelf = self] result in
            switch result {
            case .success(let data):
                DispatchQueue.runOnlyMainThread {
                    weakSelf?.loadingProgessBar.setProgress(0.7, animated: true)
                }
                weakSelf?.schedulesReceived = weakSelf?.parseCalendar(data, with: calendarID)
            case .failure(let error):
                print("error: ", error.localizedDescription)
            }
        }
    }
    
    private func parseCalendar(_ data: Data, with calendarID: String) -> [Schedule] {
        let parsed = ICalendar.load(string: String(data: data, encoding: .utf8)!)
        var schedules = [Schedule]()
        for calendar in parsed {
            calendar.subComponents.forEach {
                if let event = $0 as? ICalendarEvent {
                    let scheduleDate: Schedule.DateType
                    if let startDate = event.dtstart,
                       let endDate = event.dtend {
                        scheduleDate = .period(start: startDate, end: endDate)
                    }else {
                        scheduleDate = .spot(event.dtstamp)
                    }
                    let alarm: Schedule.Alarm?
                    let alarmAtrributes: [String: String]?
                    if let iCalendarAlarm = event.subComponents.first(where: { $0 is ICalendarAlarm }) as? ICalendarAlarm {
                        alarmAtrributes = iCalendarAlarm.otherAttrs
                        guard let trigger = alarmAtrributes!["TRIGGER"] else {
                            fatalError("iCalendar event: \(event) has alarm with out trigger\n \(alarmAtrributes!)")
                        }
                        alarm = .once(
                            event.dtstamp.addingTimeInterval(
                                parseTrigger(trigger)
                            ))
                    }else {
                        alarm = nil
                        alarmAtrributes = nil
                    }
                    schedules.append(
                        Schedule(
                            title: (event.summary == nil || event.summary!.isEmpty ? "No summary" : event.summary)!,
                            description: event.description,
                            priority: 1,
                            time: scheduleDate,
                            alarm: alarm,
                            storeAt: .googleCalendar(
                                calendarID: calendarID,
                                uid: event.uid))
                    )
                }
            }
        }
        return schedules
    }
    
    private func parseTrigger(_ trigger: String) -> TimeInterval {
        
        let sign = trigger.first! == "-" ? -1 : 1
        var dateInterval = 0
        var hourInterval = 0
        var minuteInterval = 0
        var substring: String.SubSequence
        let calcInterval: () -> TimeInterval = {
            return TimeInterval(sign * ((dateInterval * 24 * 60 * 60) + (hourInterval * 60 * 60) + (minuteInterval * 60)))
        }
        guard let indexP = trigger.firstIndex(of: "P") else { return  calcInterval()}
        
        guard let indexD = trigger.firstIndex(of: "D") else { return calcInterval()}
        substring = trigger[indexP...indexD]
        dateInterval = Int(substring.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)) ?? 0
        guard let indexH = trigger.firstIndex(of: "H") else { return calcInterval()}
        substring = trigger[indexD...indexH]
        hourInterval = Int(substring.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)) ?? 0
        guard let indexM = trigger.firstIndex(of: "M") else { return calcInterval()}
        substring = trigger[indexH...indexM]
        minuteInterval = Int(substring.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)) ?? 0
        
        return calcInterval()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.adjustsImageWhenDisabled = true
        eventListTableVC.eventListTableView = eventListTableView
        eventListTableView.delegate = eventListTableVC
        eventListTableView.dataSource = eventListTableVC
        if let token = OAuthGather.OAuthToken.readInKeyChain(
            for: OAuthGather.OAuthToken.keyChainAccountForGoogleOAuth),
           token.expires_at > Date()
        {
            loginButton.isHidden = true
            loggedInLabel.isHidden = false
            calendarIDInput.isEnabled = true
            addCalendarIDButton.isEnabled = true
        }
    }
}
