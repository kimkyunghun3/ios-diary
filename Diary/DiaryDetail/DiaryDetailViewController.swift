//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/14.
//

import UIKit
import CoreLocation

protocol DiaryDetailViewDelegate: AnyObject {
    func save(_ diary: Diary?)
    func update(_ diary: Diary)
    func delete(_ diary: Diary)
}

final class DiaryDetailViewController: UIViewController {
    private let mainView = DiaryDetailView()
    private var diary: Diary?
    weak var delegate: DiaryDetailViewDelegate?

    private var completion: (() -> (lat: String, lon: String))?
    
    private let locationManager: CLLocationManager
    
    init(diary: Diary? = nil) {
        self.diary = diary
        
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
        registerNotification()
        configureNavigationItem()
        makeKeyboardHiddenButton()
        configureSceneDelegate()
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setViewFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        finishTask()
    }
    
    private func requestWeatherIcon() async throws -> String? {
        guard let completion = completion else {
            return nil
        }
        
        let (lat, lon) = completion()
        guard let urlRequest = WeatherAPI(parameters: [
            "lat": lat,
            "lon": lon,
            "appid": "35e629549016019976c1803c71e8fc16"
        ]).makeURLRequest() else { return nil }
        
        return try await NetworkManager().fetchWeatherData(urlRequest: urlRequest)
    }
    
    private func finishTask() {
        Task {
            if let diary = diary {
                delegate?.update(updateDiary(diary))
            } else {
                diary = await makeDiary()
                delegate?.save(diary)
            }
        }
    }
    
    private func setViewFirstResponder() {
        mainView.setFirstResponder()
    }
    
    private func configureView() {
        mainView.configure(diary: diary)
        view.backgroundColor = .systemBackground
        title = DateFormatter().changeDateFormat(time: diary?.createdAt)
    }
    
    private func configureLayout() {
        self.view.addSubview(mainView)
        
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mainView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func configureContent() -> (String, String) {
        let component = mainView.readText()
            .split(separator: "\n", maxSplits: 1)
            .map(String.init)
        let title = component[safe: 0] ?? ""
        let body = component[safe: 1] ?? ""
        
        return (title, body)
    }
    
    private func configureSceneDelegate() {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.coreDataDelegate = self
    }
    
    private func makeDiary() async -> Diary {
        let (title, body) = configureContent()
        
        guard let icon = try? await requestWeatherIcon() else {
            return Diary(title: title, body: body, createdAt: Date(), weatherIcon: "")
        }
        return Diary(title: title, body: body, createdAt: Date(), weatherIcon: icon)
    }
    
    private func updateDiary(_ diary: Diary) -> Diary {
        let (title, body) = configureContent()
        return Diary(title: title,
                     body: body,
                     createdAt: diary.createdAt,
                     weatherIcon: diary.weatherIcon,
                     uuid: diary.uuid)
    }
}

// MARK: - Keyboard Notification

extension DiaryDetailViewController {
    private func registerNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keybaordRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keybaordRectangle.height
        
        mainView.changeBottomConstraint(value: keyboardHeight)
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        mainView.changeBottomConstraint(value: .zero)
    }
}

// MARK: - Alert Action

extension DiaryDetailViewController {
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(viewMoreButtonDidTapped))
    }
    
    private func showDeleteAlert() {
        AlertBuilder(target: self).addAction("취소", style: .default)
            .addAction("삭제", style: .destructive) { [weak self] in
            guard let diary = self?.diary else { return }
            self?.delegate?.delete(diary)
            self?.navigationController?.popViewController(animated: true)
        }.show("진짜요?", message: "정말로 삭제하시겠어요?", style: .alert)
    }
    
    private func showShareController() {
        let shareText = mainView.readText()
        var shareObject = [String]()
        shareObject.append(shareText)
        let activityViewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }
    
    @objc func viewMoreButtonDidTapped() {
        AlertBuilder(target: self).addAction("Share...", style: .default) { [weak self] in
            self?.showShareController()
        }.addAction("Delete", style: .destructive) { [weak self] in
            self?.showDeleteAlert()
        }.addAction("Cancel", style: .cancel)
            .show(style: .actionSheet)
    }
}

// MARK: - Keyboard BarButton

private extension DiaryDetailViewController {
    func makeKeyboardHiddenButton() {
        let bar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let hiddenButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(keyboardHidden))
        bar.sizeToFit()
        bar.items = [space, hiddenButton]
        
        mainView.setTextViewAccessory(button: bar)
    }
    
    @objc private func keyboardHidden() {
        if mainView.isTextViewFirstResponder {
            mainView.relinquishFirstResponder()
            finishTask()
        }
    }
}

// MARK: - CoreDataSceneDelegate

extension DiaryDetailViewController: CoreDataSceneDelegate {
    func saveCoreData() {
        finishTask()
    }
}

// MARK: - Array Extension

private extension Array {
    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}

// MARK: - Location Delegate

extension DiaryDetailViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            completion = {
                return (location.coordinate.latitude.description, location.coordinate.longitude.description)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertBuilder(target: self)
            .addAction("확인", style: .default)
            .show("오류", message: "사용자의 위치 정보 불러오기를 실패했습니다.", style: .alert)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            locationManager.requestLocation()
        }
    }
}
