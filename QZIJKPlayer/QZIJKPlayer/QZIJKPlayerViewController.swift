//
//  QZIJKPlayerViewController.swift
//  QZIJKPlayer
//
//  Created by 曲终叶落 on 2018/11/21.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import UIKit
import IJKMediaFramework

@objc protocol QZIJKPlayerDelegate {
    @objc optional func playeFinish()
    @objc optional func backClick()
}

class QZIJKPlayerViewController: UIViewController {
    /// 顶部工具栏
    @IBOutlet weak var topToolBar: UIView!
    /// 底部工具栏
    @IBOutlet weak var bottomToolBar: UIView!
    /// 加载
    @IBOutlet weak var activity: UIActivityIndicatorView!
    /// 播放/暂停按钮
    @IBOutlet weak var playBtn: UIButton!
    /// 底部进度条
    @IBOutlet weak var bottomProgressView: UIProgressView!
    /// 当前播放时间
    @IBOutlet weak var currentTimeLb: UILabel!
    /// 总时间
    @IBOutlet weak var totalTimeLb: UILabel!
    /// 全屏/退出全屏按钮
    @IBOutlet weak var fullBtn: UIButton!
    /// 切换清晰度按钮
    @IBOutlet weak var switchBtn: UIButton!
    /// 进度条
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var slider: UISlider!
    /// 返回按钮
    @IBOutlet weak var backBtn: UIButton!
    /// 标题
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeading: NSLayoutConstraint!
    
    private var IJKPlayer: IJKFFMoviePlayerController?
    private var isCorrectionScreen = false
    private var fatherView: UIView!
    private var originalFrame: CGRect!
    private var shouldHideHomeIndicator = false
    lazy private var presenter: QZIJKPlayerPresenter =  {
        return QZIJKPlayerPresenter(bind: self)
    }()
    weak var delegate: QZIJKPlayerDelegate? {
        didSet {
            presenter.delegate = delegate
        }
    }
    var isHiddenBottomProgressView = false {
        didSet {
            bottomProgressView.isHidden = isHiddenBottomProgressView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        slider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchCancel, .touchUpInside, .touchUpOutside])
    }

    func setPlayData(playModels: [QZIJKPlayerPlayModel]) {
        presenter.play(playModels: playModels)
    }
    
    private func setUI() {
        topToolBar.isHidden = true
        backBtn.setImage(QZPlayerResource.backImage(), for: .normal)
        playBtn.setImage(QZPlayerResource.playImage(), for: .normal)
        playBtn.setImage(QZPlayerResource.pauseImage(), for: .selected)
        fullBtn.setImage(QZPlayerResource.fullScreenImage(), for: .normal)
        fullBtn.setImage(QZPlayerResource.exitFullScreenImage(), for: .selected)
        tableView.register(UINib(nibName: "QZIJKPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "QZIJKPlayerTableViewCell")
        tableViewLeading.constant = -tableView.frame.width
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IJKPlayer?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continuePlay()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !isCorrectionScreen {
            isCorrectionScreen = true
            fatherView = self.view.superview!
            originalFrame = self.view.frame
        }
    }
    
    private func removeIJKPlayer() {
        IJKPlayer?.shutdown()
        IJKPlayer?.view.removeFromSuperview()
        IJKPlayer = nil
    }
    
    deinit {
        presenter.stop()
        removeIJKPlayer()
        print("播放器已释放")
    }
    
    @IBAction func bgBtnClick(_ sender: UIButton) {
        presenter.changedHiddenToolBar()
        if self.tableView.alpha != 0.0 {
            hideTableView()
        }
    }

    @IBAction func fullBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        presenter.changeScreen()
    }
    
    @IBAction func playBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if IJKPlayer?.playbackState == .paused {
            IJKPlayer?.play()
        }else{
            IJKPlayer?.pause()
        }
    }
    
    /// 开始拖动
    @IBAction func sliderTouchBegan(_ sender: UISlider) {
        IJKPlayer?.pause()
        presenter.stopHiddenToolBar()
    }
    /// 拖动中事件
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        IJKPlayer!.currentPlaybackTime = Double(sender.value) * IJKPlayer!.duration
    }
    /// 拖动结束
    @objc private func sliderTouchEnded(_ sender: UISlider) {
        IJKPlayer!.play()
        presenter.startHiddenToolBar()
    }
    
    @IBAction func backClick(_ sender: UIButton) {
        if presenter.state == .fullScreen {
            presenter.changeScreen()
        }else{
            delegate?.backClick?()
        }
    }
    
    @IBAction func switchClick(_ sender: UIButton) {
        if sender.isSelected {
            hideTableView()
        }else{
            showTableView()
        }
    }
    
    private func showTableView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 1.0
            self.tableViewLeading.constant = 0.0
            self.view.layoutIfNeeded()
        }) { (_) in
            self.presenter.stopHiddenToolBar()
            self.switchBtn.isSelected = true
        }
    }
    
    private func hideTableView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 0.0
            self.tableViewLeading.constant = -self.tableView.frame.width
            self.view.layoutIfNeeded()
        }) { (_) in
            self.presenter.startHiddenToolBar()
            self.switchBtn.isSelected = false
        }
    }
}

// MARK: - 播放控制
extension QZIJKPlayerViewController {
    private func continuePlay() {
        if IJKPlayer?.playbackState == .paused {
            IJKPlayer?.play()
        }
    }
    
    private func playing() {
        playBtn.isSelected = true
    }

    private func pausedPlay() {
        playBtn.isSelected = false
    }
}

// MARK: - 底部home条控制
extension QZIJKPlayerViewController {
    private func shouldHideHomeIndicator(_ bool: Bool) {
        if #available(iOS 11.0, *) {
            self.shouldHideHomeIndicator = bool
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        } else {
            // Fallback on earlier versions
        }
    }
}

// MARK: - 屏幕旋转
extension QZIJKPlayerViewController {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return shouldHideHomeIndicator
    }
}

// MARK: - QZIJKPlayerInterface
extension QZIJKPlayerViewController: QZIJKPlayerInterface {
    func play(playModel: QZIJKPlayerPlayModel) {
        removeIJKPlayer()
        IJKPlayer = IJKFFMoviePlayerController(contentURL: URL(string: playModel.url)!, with: presenter.options)
        IJKPlayer?.scalingMode = .aspectFit
        let IJKView = IJKPlayer!.view!
        self.view.insertSubview(IJKView, at: 0)
        IJKView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: IJKView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let letConstraint = NSLayoutConstraint(item: IJKView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: IJKView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: IJKView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraints([topConstraint, letConstraint, rightConstraint, bottomConstraint])
        IJKPlayer?.prepareToPlay()
        IJKPlayer?.play()
        activity.isHidden = false
        activity.startAnimating()
    }
    
    func updateUI() {
        switchBtn.setTitle(presenter.switchName, for: .normal)
        titleLb.text = presenter.title
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func isHiddenToolBar(isHidden: Bool) {
        if isHidden {
            UIView.animate(withDuration: 0.25) {
                self.topToolBar.alpha = 0.0
                self.bottomToolBar.alpha = 0.0
            }
        }else{
            UIView.animate(withDuration: 0.25) {
                self.topToolBar.alpha = 1.0
                self.bottomToolBar.alpha = 1.0
            }
        }
    }
    
    func preparedToPlay() {
        activity.stopAnimating()
    }
    
    func playBackStateDidChange() {
        guard let playbackState = IJKPlayer?.playbackState else {
            return
        }
        switch playbackState {
        case .paused:
            print("暂停")
            pausedPlay()
        case .playing:
            print("播放中")
            playing()
        case .stopped:
            print("停止")
        case .interrupted:
            print("中断了")
        case .seekingBackward:
            print("后退")
        case .seekingForward:
            print("快进")
        default:
            break
        }
    }
    
    func fullScreen(bool: Bool) {
        fullBtn.isSelected = bool
    }
    
    func updatePlayerUI() {
        let sliderValue = Float(IJKPlayer!.currentPlaybackTime / IJKPlayer!.duration)
        slider.setValue(sliderValue, animated: true)
        bottomProgressView.setProgress(sliderValue, animated: true)
        var progressValue = Float(IJKPlayer!.playableDuration) / Float(IJKPlayer!.duration)
        if progressValue > 0.99 {progressValue = 1.0}
        progressView.setProgress(progressValue, animated: true)
        currentTimeLb.text = IJKPlayer!.currentPlaybackTime.timeformat()
        totalTimeLb.text = IJKPlayer!.duration.timeformat()
    }
    
    func updateUIIfOnlyData() {
        switchBtn.isHidden = true
        let widthConstraint = NSLayoutConstraint(item: switchBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.0)
        switchBtn.superview?.addConstraint(widthConstraint)
    }
    
    func fullScreen() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.keyWindow?.addSubview(self.view)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .allowUserInteraction, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }) { (_) in
            self.shouldHideHomeIndicator(true)
            self.topToolBar.isHidden = false
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: self.topToolBar.frame.height + 20))
        }
    }
    
    func originalScreen() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        fatherView.addSubview(self.view)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .allowUserInteraction, animations: {
            self.view.frame = self.originalFrame
        }) { (_) in
            self.shouldHideHomeIndicator(false)
            self.topToolBar.isHidden = true
            self.tableView.tableHeaderView = nil
        }
    }
}

extension QZIJKPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QZIJKPlayerTableViewCell", for: indexPath) as! QZIJKPlayerTableViewCell
        cell.nameLb.text = presenter.playName(row: indexPath.row)
        cell.nameLb.textColor = presenter.playNameColor(row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.play(index: indexPath.row)
        tableView.reloadData()
        hideTableView()
    }
}
