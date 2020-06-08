//
//  QZIJKPlayerPresenter.swift
//  QZIJKPlayer
//
//  Created by iOS on 2018/11/26.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import Foundation
import IJKMediaFramework

class QZIJKPlayerPresenter {
    private weak var interface: QZIJKPlayerInterface?
    weak var delegate: QZIJKPlayerDelegate?
    /// ijk 配置
    lazy var options: IJKFFOptions! = {
        let options = IJKFFOptions.byDefault()
        options?.setFormatOptionIntValue(1024 * 16, forKey: "probsize")
        options?.setFormatOptionIntValue(1000, forKey: "analyzeduration")
        options?.setPlayerOptionIntValue(0, forKey: "videotoolbox")
        options?.setCodecOptionIntValue(Int64(IJK_AVDISCARD_DEFAULT.rawValue), forKey: "skip_loop_filter")
        options?.setCodecOptionIntValue(Int64(IJK_AVDISCARD_DEFAULT.rawValue), forKey: "skip_frame")
        options?.setOptionIntValue(1, forKey: "videotoolbox", of: kIJKFFOptionCategoryPlayer) // 支持硬解 1：开启 O:关闭
        options?.setPlayerOptionIntValue(0, forKey: "max_cached_duration")
        options?.setPlayerOptionIntValue(0, forKey: "infbuf")
        options?.setPlayerOptionIntValue(1, forKey: "packet-buffering")
        return options
    }()
    
    /// 记录上次的全屏方向
    private var lastOrientation: UIDeviceOrientation!
    /// 记录进来时的屏幕方向
    private var tempOrientation: UIDeviceOrientation!
    private var playModels: [QZIJKPlayerPlayModel]!
    private var isHiddenToolBar = false
    private var currentPlayModel: QZIJKPlayerPlayModel! {
        didSet {
            DispatchQueue.main.async {
                self.interface?.play(playModel: self.currentPlayModel)
                self.interface?.updateUI()
            }
        }
    }
    
    init(bind interface: QZIJKPlayerInterface) {
        self.interface = interface
        start()
    }
    
    func play(playModels: [QZIJKPlayerPlayModel]) {
        self.playModels = playModels
        currentPlayModel = playModels.last
        if self.playModels.count == 1 { interface?.updateUIIfOnlyData() }
    }
    
    func play(index: Int) {
        currentPlayModel = playModels[index]
    }
    
    private func start() {
        tempOrientation = UIDevice.current.orientation
        lastOrientation = tempOrientation
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        installNotification()
    }
    
    var state: PlayerViewState = .small {
        didSet {
            switch state {
            case .small:
                interface?.fullScreen(bool: false)
            case .fullScreen:
                interface?.fullScreen(bool: true)
            default:
                break
            }
        }
    }
    /// 定时器，用来显示总时间，时间，进度条等的显示
    private var playMonitorTimer: Timer?
    private var hiddenToolBarTimer: Timer?
    
    func preparedToPlay() {
        if playMonitorTimer != nil {playMonitorTimer?.invalidate()}
        playMonitorTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startPlayMonitor), userInfo: nil, repeats: true)
        RunLoop.current.add(playMonitorTimer!, forMode: .common)
        startHiddenToolBar()
        interface?.preparedToPlay()
    }

    @objc private func startPlayMonitor() {
        interface?.updatePlayerUI()
    }
    
    func changedHiddenToolBar() {
        isHiddenToolBar = !isHiddenToolBar
        interface?.isHiddenToolBar(isHidden: isHiddenToolBar)
        startHiddenToolBar()
    }
    
    func startHiddenToolBar() {
        hiddenToolBarTimer?.invalidate()
        hiddenToolBarTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hiddenToolBar), userInfo: nil, repeats: true)
        RunLoop.current.add(hiddenToolBarTimer!, forMode: .common)
    }
    
    @objc private func hiddenToolBar() {
        isHiddenToolBar = true
        interface?.isHiddenToolBar(isHidden: isHiddenToolBar)
    }
    
    func stopHiddenToolBar() {
        hiddenToolBarTimer?.invalidate()
    }
    
    func stop() {
        playMonitorTimer?.invalidate()
        hiddenToolBarTimer?.invalidate()
    }
    
    deinit {
        print("Presenter已释放")
        removeNotification()
        UIDevice.current.setValue(tempOrientation.rawValue, forKey: "orientation")
    }
    
    private func installNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movidePlayeBackFinish), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedDidchange), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
    }
    
    private func removeNotification() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
    }
    
    func changeScreen() {
        switch state {
        case .small:
            enterFullScreen()
        case .fullScreen:
            exitFullScreen()
        default:
            break
        }
    }
    
    private func enterFullScreen() {
        if lastOrientation.rawValue == UIInterfaceOrientation.landscapeLeft.rawValue {
            present(to: .landscapeLeft)
        }else{
            present(to: .landscapeRight)
        }
    }
    
    private func exitFullScreen() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    private func present(to orientation: UIDeviceOrientation) {
        state = .animating
        if orientation == .landscapeLeft {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        }else{
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    var title: String? {
        return currentPlayModel.title
    }
    
    var switchName: String? {
        return currentPlayModel.name
    }
    
    var row: Int {
        return playModels.count
    }
    
    func playName(row: Int) -> String? {
        return playModels[row].name
    }
    
    func playNameColor(row: Int) -> UIColor {
        if playModels[row].name == switchName {
            return UIColor.white
        }
        return UIColor.white.withAlphaComponent(0.6)
    }
}

// MARK: - 播放状态
extension QZIJKPlayerPresenter {
    /// 加载状态改变
    @objc private func loadStateDidChange(notification: Notification) {
        
    }
    /// 播放完了调用
    @objc private func movidePlayeBackFinish(notification: Notification) {
        delegate?.playeFinish?()
    }
    /// 加载完成准备播放
    @objc private func mediaIsPreparedDidchange(notification: Notification) {
        print("加载完成准备播放")
        preparedToPlay()
    }
    /// 播放状态改变
    @objc private func moviePlayBackStateDidChange(notification: Notification) {
        interface?.playBackStateDidChange()
    }
}

extension QZIJKPlayerPresenter {
    @objc private func orientChange(notification: Notification) {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            lastOrientation = UIDevice.current.orientation
            if state == .fullScreen {return}
            interface?.fullScreen()
            state = .fullScreen
        case .portrait:
            if state == .small {return}
            interface?.originalScreen()
            state = .small
        default:
            break
        }
    }
}

extension TimeInterval {
    func timeformat() -> String {
        let minute = String(format: "%02d",Int(self.truncatingRemainder(dividingBy: 3600) / 60))
        let second = String(format: "%02d",Int(self.truncatingRemainder(dividingBy: 60)))
        var timeString = minute + ":" + second
        if Int(self / 3600) >= 1 {
            let hour = String(format: "%02d",Int(self / 3600))
            timeString = hour + ":" + timeString
        }
        return timeString
    }
}

enum PlayerViewState {
    case small
    case animating
    case fullScreen
}
