//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by bot on 17.05.2026.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
}

class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    private var selectedSchedule: [WeekDay] = []
    private var selectedCategory: String = "Привычки"
    
    // Контейнер для поля ввода названия
    private lazy var nameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Контейнер для кнопок категории и расписания
    private lazy var buttonsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .clear
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        updateCategoryButton()
        updateScheduleButton()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Добавляем контейнер для поля ввода
        view.addSubview(nameContainerView)
        nameContainerView.addSubview(nameTextField)
        
        // Добавляем контейнер для кнопок
        view.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(categoryButton)
        buttonsContainerView.addSubview(separatorLine)
        buttonsContainerView.addSubview(scheduleButton)
        
        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // Добавляем стрелки к кнопкам
        addDisclosureIndicator(to: categoryButton)
        addDisclosureIndicator(to: scheduleButton)
        
        NSLayoutConstraint.activate([
            // Контейнер для поля ввода
            nameContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameContainerView.heightAnchor.constraint(equalToConstant: 75),
            
            nameTextField.topAnchor.constraint(equalTo: nameContainerView.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: nameContainerView.bottomAnchor),
            
            // Контейнер для кнопок (расстояние 24px от предыдущего контейнера)
            buttonsContainerView.topAnchor.constraint(equalTo: nameContainerView.bottomAnchor, constant: 24),
            buttonsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            separatorLine.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleButton.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            scheduleButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor),
            
            // Кнопки внизу
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        updateCreateButtonState()
    }
    
    private func addDisclosureIndicator(to button: UIButton) {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            imageView.widthAnchor.constraint(equalToConstant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    private func getScheduleText() -> String {
        if selectedSchedule.count == 7 {
            return "Каждый день"
        } else if selectedSchedule.isEmpty {
            return "Не выбрано"
        } else {
            let shortNames: [WeekDay: String] = [
                .monday: "Пн", .tuesday: "Вт", .wednesday: "Ср",
                .thursday: "Чт", .friday: "Пт", .saturday: "Сб", .sunday: "Вс"
            ]
            let selected = selectedSchedule.sorted { $0.rawValue < $1.rawValue }
            return selected.map { shortNames[$0] ?? "" }.joined(separator: ", ")
        }
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isScheduleSelected = !selectedSchedule.isEmpty
        
        let isValid = isNameValid && isScheduleSelected
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .systemBlue : .systemGray
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func categoryButtonTapped() {
        let alert = UIAlertController(title: "Категория", message: "Выберите категорию", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Привычки", style: .default) { [weak self] _ in
            self?.selectedCategory = "Привычки"
            self?.updateCategoryButton()
        })
        alert.addAction(UIAlertAction(title: "Спорт", style: .default) { [weak self] _ in
            self?.selectedCategory = "Спорт"
            self?.updateCategoryButton()
        })
        alert.addAction(UIAlertAction(title: "Образование", style: .default) { [weak self] _ in
            self?.selectedCategory = "Образование"
            self?.updateCategoryButton()
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = Set(selectedSchedule)
        scheduleVC.delegate = self
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    private func updateCategoryButton() {
        // Удаляем старые лейблы
        categoryButton.subviews.forEach {
            if $0 is UILabel {
                $0.removeFromSuperview()
            }
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Категория"
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = selectedCategory
        subtitleLabel.font = .systemFont(ofSize: 17)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryButton.addSubview(titleLabel)
        categoryButton.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: categoryButton.topAnchor, constant: 15),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
    }
    
    private func updateScheduleButton() {
        // Удаляем старые лейблы
        scheduleButton.subviews.forEach {
            if $0 is UILabel {
                $0.removeFromSuperview()
            }
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Расписание"
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = getScheduleText()
        subtitleLabel.font = .systemFont(ofSize: 17)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleButton.addSubview(titleLabel)
        scheduleButton.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: 15),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
        
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              !selectedSchedule.isEmpty else { return }
        
        // Временные значения для emoji и цвета (пока нет выбора)
        let defaultEmoji = "📌"
        let defaultColor = UIColor.systemBlue
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            emoji: defaultEmoji,
            color: defaultColor,
            schedule: selectedSchedule
        )
        
        delegate?.didCreateTracker(tracker, category: selectedCategory)
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedSchedule = days
        updateScheduleButton()
    }
}



// MARK: - ScheduleViewControllerDelegate
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

// MARK: - ScheduleViewController
class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
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
        // Разделитель с отступами слева 16 и справа 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 1)
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Скрываем кнопку "Назад"
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Расписание"
        
        // Убираем нижнюю границу (тень) под navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowColor = .clear  // Убираем нижнюю границу
        appearance.shadowImage = UIImage()  // Убираем тень
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        // Убираем кнопку "Назад" на всякий случай
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
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
    
    // MARK: - Actions
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

// MARK: - RoundSwitch (круглый переключатель)
class RoundSwitch: UIControl {
    
    // MARK: - Properties
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
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
    
    // MARK: - Actions
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
