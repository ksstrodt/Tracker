//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by bot on 12.06.2026.
//
import UIKit

// MARK: - ScheduleViewControllerDelegate
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

// MARK: - ScheduleViewController
class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    var selectedDays: Set<WeekDay> = []
    
    private let weekDays: [WeekDay] = WeekDay.allDays
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScheduleSwitchCell.self, forCellReuseIdentifier: "ScheduleSwitchCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(red: 200/255, green: 205/255, blue: 210/255, alpha: 1)
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Расписание"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectDays(Array(selectedDays))
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleSwitchCell", for: indexPath) as? ScheduleSwitchCell else {
            return UITableViewCell()
        }
        
        let day = weekDays[indexPath.row]
        let isSelected = selectedDays.contains(day)
        cell.configure(with: getDayName(day), isOn: isSelected)
        cell.switchControl.rowIndex = indexPath.row
        cell.switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let day = weekDays[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? ScheduleSwitchCell
        
        if selectedDays.contains(day) {
            selectedDays.remove(day)
            cell?.switchControl.setOn(false, animated: true)
        } else {
            selectedDays.insert(day)
            cell?.switchControl.setOn(true, animated: true)
        }
    }
    
    @objc private func switchChanged(_ sender: RoundSwitch) {
        let day = weekDays[sender.rowIndex]
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    private func getDayName(_ day: WeekDay) -> String {
        switch day {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

// MARK: - RoundSwitch
class RoundSwitch: UIControl {
    
    private let thumbView = UIView()
    private let trackView = UIView()
    
    var isOn: Bool = false {
        didSet {
            updateAppearance(animated: true)
        }
    }
    
    var onTintColor: UIColor = .systemBlue {
        didSet {
            updateAppearance(animated: false)
        }
    }
    
    var offTintColor: UIColor = UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 1) {
        didSet {
            updateAppearance(animated: false)
        }
    }
    
    var thumbTintColor: UIColor = .white {
        didSet {
            updateAppearance(animated: false)
        }
    }
    
    var rowIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        trackView.isUserInteractionEnabled = false
        thumbView.isUserInteractionEnabled = false
        
        trackView.layer.cornerRadius = 16
        thumbView.layer.cornerRadius = 13
        
        addSubview(trackView)
        addSubview(thumbView)
        
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        updateAppearance(animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let trackWidth: CGFloat = 51
        let trackHeight: CGFloat = 31
        let thumbSize: CGFloat = 27
        
        trackView.frame = CGRect(x: bounds.width - trackWidth, y: (bounds.height - trackHeight) / 2, width: trackWidth, height: trackHeight)
        
        if isOn {
            thumbView.frame = CGRect(x: trackView.frame.maxX - thumbSize - 2, y: (bounds.height - thumbSize) / 2, width: thumbSize, height: thumbSize)
        } else {
            thumbView.frame = CGRect(x: trackView.frame.minX + 2, y: (bounds.height - thumbSize) / 2, width: thumbSize, height: thumbSize)
        }
    }
    
    @objc private func toggle() {
        isOn.toggle()
        sendActions(for: .valueChanged)
    }
    
    private func updateAppearance(animated: Bool) {
        let duration = animated ? 0.3 : 0
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            self.trackView.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
            self.thumbView.backgroundColor = self.thumbTintColor
            
            let trackWidth: CGFloat = 51
            let thumbSize: CGFloat = 27
            
            if self.isOn {
                self.thumbView.frame = CGRect(x: self.trackView.frame.maxX - thumbSize - 2, y: (self.bounds.height - thumbSize) / 2, width: thumbSize, height: thumbSize)
            } else {
                self.thumbView.frame = CGRect(x: self.trackView.frame.minX + 2, y: (self.bounds.height - thumbSize) / 2, width: thumbSize, height: thumbSize)
            }
        })
        
        setNeedsLayout()
    }
    
    func setOn(_ on: Bool, animated: Bool) {
        isOn = on
        updateAppearance(animated: animated)
    }
}

// MARK: - ScheduleSwitchCell
class ScheduleSwitchCell: UITableViewCell {
    
    let switchControl: RoundSwitch = {
        let switchControl = RoundSwitch()
        switchControl.onTintColor = .systemBlue
        switchControl.offTintColor = UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 1)
        switchControl.thumbTintColor = .white
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 0.3)
        selectionStyle = .none
        
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.widthAnchor.constraint(equalToConstant: 51),
            switchControl.heightAnchor.constraint(equalToConstant: 31)
        ])
    }
    
    func configure(with title: String, isOn: Bool) {
        textLabel?.text = title
        textLabel?.font = .systemFont(ofSize: 17)
        textLabel?.textColor = .black
        switchControl.isOn = isOn
    }
}
