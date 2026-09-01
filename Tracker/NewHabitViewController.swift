//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by bot on 17.05.2026.
//

import UIKit

// MARK: - NewHabitViewControllerDelegate
protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
}

// MARK: - NewHabitViewController
class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: NewHabitViewControllerDelegate?
    private let dataStoreManager = DataStoreManager.shared
    
    private var selectedSchedule: [WeekDay] = []
    private var selectedCategory: String = ""
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let colors: [UIColor] = [
        UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1),
        UIColor(red: 255/255, green: 136/255, blue: 30/255, alpha: 1),
        UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1),
        UIColor(red: 110/255, green: 68/255, blue: 254/255, alpha: 1),
        UIColor(red: 51/255, green: 207/255, blue: 105/255, alpha: 1),
        UIColor(red: 230/255, green: 109/255, blue: 212/255, alpha: 1),
        UIColor(red: 249/255, green: 212/255, blue: 212/255, alpha: 1),
        UIColor(red: 52/255, green: 167/255, blue: 254/255, alpha: 1),
        UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1),
        UIColor(red: 53/255, green: 52/255, blue: 124/255, alpha: 1),
        UIColor(red: 255/255, green: 103/255, blue: 77/255, alpha: 1),
        UIColor(red: 255/255, green: 153/255, blue: 204/255, alpha: 1),
        UIColor(red: 246/255, green: 196/255, blue: 139/255, alpha: 1),
        UIColor(red: 121/255, green: 148/255, blue: 245/255, alpha: 1),
        UIColor(red: 131/255, green: 44/255, blue: 241/255, alpha: 1),
        UIColor(red: 173/255, green: 86/255, blue: 218/255, alpha: 1),
        UIColor(red: 141/255, green: 114/255, blue: 230/255, alpha: 1),
        UIColor(red: 47/255, green: 208/255, blue: 88/255, alpha: 1)
    ]
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 0.3)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 0.3)
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
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        view.backgroundColor = UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.isUserInteractionEnabled = true
        return collectionView
    }()
    
    private lazy var emojiTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.isUserInteractionEnabled = true
        return collectionView
    }()
    
    private lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1).cgColor
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emojiCollectionView.collectionViewLayout.invalidateLayout()
        colorCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1),
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameContainerView)
        nameContainerView.addSubview(nameTextField)
        
        contentView.addSubview(errorLabel)
        
        contentView.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(categoryButton)
        buttonsContainerView.addSubview(separatorLine)
        buttonsContainerView.addSubview(scheduleButton)
        
        contentView.addSubview(emojiTitleLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(colorCollectionView)
        
        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        addDisclosureIndicator(to: categoryButton)
        addDisclosureIndicator(to: scheduleButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameContainerView.heightAnchor.constraint(equalToConstant: 75),
            
            nameTextField.topAnchor.constraint(equalTo: nameContainerView.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: nameContainerView.bottomAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: nameContainerView.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            buttonsContainerView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            buttonsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
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
            
            emojiTitleLabel.topAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 200),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        updateCreateButtonState()
    }
    
    private func addDisclosureIndicator(to button: UIButton) {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
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
            return ""
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
        let isCategoryValid = !selectedCategory.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        let isValid = isNameValid && isScheduleSelected && isCategoryValid && isEmojiSelected && isColorSelected
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .black : .systemGray
        createButton.setTitleColor(.white, for: .normal)
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        let currentText = nameTextField.text ?? ""
        
        if currentText.count > 38 {
            nameTextField.text = String(currentText.prefix(38))
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        
        updateCreateButtonState()
    }
    
    @objc private func categoryButtonTapped() {
        let alert = UIAlertController(title: "Категория", message: "Выберите категорию", preferredStyle: .actionSheet)
        
        // Загружаем существующие категории из Core Data
        let categories = dataStoreManager.categoryStore.fetchCategories()
        if categories.isEmpty {
            // Если категорий нет, показываем стандартные варианты
            let defaultCategories = ["Важное", "Спорт", "Образование", "Личное", "Работа", "Другое"]
            for category in defaultCategories {
                alert.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                    self?.selectedCategory = category
                    self?.updateCategoryButton()
                    self?.updateCreateButtonState()
                })
            }
        } else {
            for category in categories {
                let title = category.title ?? "Без категории"
                alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                    self?.selectedCategory = title
                    self?.updateCategoryButton()
                    self?.updateCreateButtonState()
                })
            }
        }
        
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
        categoryButton.subviews.forEach {
            if $0 is UILabel {
                $0.removeFromSuperview()
            }
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Категория"
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryButton.addSubview(titleLabel)
        
        if !selectedCategory.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.text = selectedCategory
            subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
            subtitleLabel.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            categoryButton.addSubview(subtitleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: categoryButton.topAnchor, constant: 15),
                
                subtitleLabel.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor)
            ])
        }
    }
    
    private func updateScheduleButton() {
        scheduleButton.subviews.forEach {
            if $0 is UILabel {
                $0.removeFromSuperview()
            }
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Расписание"
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleButton.addSubview(titleLabel)
        
        if !selectedSchedule.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.text = getScheduleText()
            subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
            subtitleLabel.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            scheduleButton.addSubview(subtitleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: 15),
                
                subtitleLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor)
            ])
        }
        
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              !selectedSchedule.isEmpty,
              !selectedCategory.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            emoji: emoji,
            color: color,
            schedule: selectedSchedule
        )
        
        delegate?.didCreateTracker(tracker, category: selectedCategory)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let hasText = !(textField.text?.isEmpty ?? true)
        textField.rightViewMode = hasText ? .whileEditing : .never
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 38 {
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        
        return newText.count <= 38
    }
}

// MARK: - ScheduleViewControllerDelegate
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedSchedule = days
        updateScheduleButton()
        updateCreateButtonState()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension NewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            let isSelected = selectedEmoji == emoji
            cell.configure(with: emoji, isSelected: isSelected)
            
            cell.tag = indexPath.item
            let tap = UITapGestureRecognizer(target: self, action: #selector(emojiTapped(_:)))
            cell.addGestureRecognizer(tap)
            cell.isUserInteractionEnabled = true
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            let isSelected = selectedColor == color
            cell.configure(with: color, isSelected: isSelected)
            
            cell.tag = indexPath.item
            let tap = UITapGestureRecognizer(target: self, action: #selector(colorTapped(_:)))
            cell.addGestureRecognizer(tap)
            cell.isUserInteractionEnabled = true
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let spacing: CGFloat = 5
        let totalSpacing = spacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = availableWidth / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc private func emojiTapped(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view as? EmojiCell else { return }
        let selected = emojis[cell.tag]
        
        if selectedEmoji == selected {
            selectedEmoji = nil
        } else {
            selectedEmoji = selected
        }
        emojiCollectionView.reloadData()
        updateCreateButtonState()
    }
    
    @objc private func colorTapped(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view as? ColorCell else { return }
        let selected = colors[cell.tag]
        
        if selectedColor == selected {
            selectedColor = nil
        } else {
            selectedColor = selected
        }
        colorCollectionView.reloadData()
        updateCreateButtonState()
    }
}

// MARK: - EmojiCell
class EmojiCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? UIColor(red: 230/255, green: 235/255, blue: 235/255, alpha: 0.5) : .clear
    }
}

// MARK: - ColorCell
class ColorCell: UICollectionViewCell {
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(colorView)
        contentView.layer.cornerRadius = 8
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
        }
    }
}
