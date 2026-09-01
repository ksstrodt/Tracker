//
//  TrackersViewController.swift
//  Tracker
//
//  Created by bot on 11.05.2026.
//
import UIKit

// MARK: - CategoryHeaderView

class CategoryHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "CategoryHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
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
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -198)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

// MARK: - TrackersViewController

class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private let dataStoreManager = DataStoreManager.shared
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var selectedDate = Date()
    private var isTrackersSelected = true
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = .clear
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(CategoryHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryHeaderView.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star") ?? UIImage(systemName: "star.fill")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var customFooter: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var topSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var trackersButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(trackersButtonTapped), for: .touchUpInside)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Трекеры"
        configuration.image = UIImage(named: "trackers") ?? UIImage(systemName: "record.circle")
        configuration.imagePadding = 4
        configuration.imagePlacement = .top
        configuration.baseForegroundColor = .systemBlue
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            return outgoing
        }
        button.configuration = configuration
        
        return button
    }()
    
    private lazy var statisticsButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(statisticsButtonTapped), for: .touchUpInside)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Статистика"
        configuration.image = UIImage(named: "statistics") ?? UIImage(systemName: "chart.bar")
        configuration.imagePadding = 4
        configuration.imagePlacement = .top
        configuration.baseForegroundColor = .gray
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            return outgoing
        }
        button.configuration = configuration
        
        return button
    }()
    
    private let statisticsPlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chart.bar.xaxis")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statisticsPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет статистики"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statisticsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Заполните трекеры,\nчтобы увидеть статистику"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statisticsPlaceholderStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statisticsPlaceholderImageView, statisticsPlaceholderLabel, statisticsDescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        
        // Подписываемся на уведомления об изменениях в DataStore
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataStoreChange),
            name: .dataStoreDidChange,
            object: nil
        )
        
        loadData()
        updatePlaceholderVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        updatePlaceholderVisibility()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        let categoryData = dataStoreManager.categoryStore.fetchCategoriesWithTrackers()
        categories = categoryData.map { categoryData in
            let trackers = categoryData.trackers.compactMap { $0.toTracker() }
            return TrackerCategory(title: categoryData.category.title ?? "Без категории", trackers: trackers)
        }
        
        let records = dataStoreManager.recordStore.fetchRecords()
        completedTrackers = records.compactMap { $0.toTrackerRecord() }
        
        print("📊 Загружено категорий: \(categories.count)")
        print("📊 Загружено трекеров: \(categories.flatMap { $0.trackers }.count)")
        print("📊 Загружено записей: \(completedTrackers.count)")
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "Трекеры"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemBlue
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        let dateBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = dateBarButton
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(placeholderStackView)
        view.addSubview(statisticsPlaceholderStackView)
        view.addSubview(customFooter)
        view.addSubview(topSeparatorLine)
        
        customFooter.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(trackersButton)
        buttonStackView.addArrangedSubview(statisticsButton)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: customFooter.topAnchor),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            statisticsPlaceholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsPlaceholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            statisticsPlaceholderImageView.widthAnchor.constraint(equalToConstant: 80),
            statisticsPlaceholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            topSeparatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSeparatorLine.bottomAnchor.constraint(equalTo: customFooter.topAnchor),
            topSeparatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            customFooter.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customFooter.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customFooter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customFooter.heightAnchor.constraint(equalToConstant: 70),
            
            buttonStackView.topAnchor.constraint(equalTo: customFooter.topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: customFooter.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: customFooter.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: customFooter.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Update Methods
    
    @objc private func handleDataStoreChange() {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
            self?.updatePlaceholderVisibility()
        }
    }
    
    private func updatePlaceholderVisibility() {
        if isTrackersSelected {
            let nonEmptyCategories = getNonEmptyCategories()
            let isEmpty = nonEmptyCategories.isEmpty
            
            placeholderStackView.isHidden = !isEmpty
            collectionView.isHidden = isEmpty
            statisticsPlaceholderStackView.isHidden = true
        } else {
            collectionView.isHidden = true
            placeholderStackView.isHidden = true
            statisticsPlaceholderStackView.isHidden = false
        }
        
        collectionView.reloadData()
    }
    
    private func getNonEmptyCategories() -> [TrackerCategory] {
        return categories.filter { category in
            let filtered = category.trackers.filter { tracker in
                guard let selectedWeekday = WeekDay.from(date: selectedDate) else { return false }
                return tracker.schedule.contains(selectedWeekday)
            }
            return !filtered.isEmpty
        }
    }
    
    private func getFilteredTrackers() -> [Tracker] {
        var allTrackers: [Tracker] = []
        for category in categories {
            allTrackers.append(contentsOf: category.trackers)
        }
        
        guard let selectedWeekday = WeekDay.from(date: selectedDate) else {
            return []
        }
        
        var filtered = allTrackers.filter { tracker in
            return tracker.schedule.contains(selectedWeekday)
        }
        
        if let searchText = searchTextField.text, !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        return filtered
    }
    
    private func isTrackerCompleted(trackerId: UUID, on date: Date) -> Bool {
        return dataStoreManager.recordStore.isTrackerCompleted(trackerId: trackerId, on: date)
    }
    
    private func canCompleteTracker(on date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)
        return selectedDay <= today
    }
    
    private func completionCount(for trackerId: UUID) -> Int {
        return dataStoreManager.recordStore.countRecords(for: trackerId)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: newHabitVC)
        present(navigationController, animated: true)
    }
    
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        updatePlaceholderVisibility()
    }
    
    @objc private func searchTextChanged() {
        updatePlaceholderVisibility()
    }
    
    @objc private func trackersButtonTapped() {
        isTrackersSelected = true
        title = "Трекеры"
        updateButtonAppearance(selected: trackersButton, unselected: statisticsButton)
        updatePlaceholderVisibility()
    }
    
    @objc private func statisticsButtonTapped() {
        isTrackersSelected = false
        title = "Статистика"
        updateButtonAppearance(selected: statisticsButton, unselected: trackersButton)
        updatePlaceholderVisibility()
    }
    
    private func updateButtonAppearance(selected: UIButton, unselected: UIButton) {
        var selectedConfig = selected.configuration
        selectedConfig?.baseForegroundColor = .systemBlue
        selected.configuration = selectedConfig
        
        var unselectedConfig = unselected.configuration
        unselectedConfig?.baseForegroundColor = .gray
        unselected.configuration = unselectedConfig
    }
    
    @objc private func completeButtonTapped(sender: UIButton) {
        guard let trackerId = sender.trackerId else { return }
        
        guard canCompleteTracker(on: selectedDate) else {
            return
        }
        
        if dataStoreManager.recordStore.isTrackerCompleted(trackerId: trackerId, on: selectedDate) {
            dataStoreManager.recordStore.deleteRecord(trackerId: trackerId, date: selectedDate)
            completedTrackers.removeAll {
                $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
            }
        } else {
            if let _ = dataStoreManager.recordStore.createRecord(trackerId: trackerId, date: selectedDate) {
                let record = TrackerRecord(trackerId: trackerId, date: selectedDate)
                completedTrackers.append(record)
            }
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isTrackersSelected {
            return getNonEmptyCategories().count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isTrackersSelected {
            let nonEmptyCategories = getNonEmptyCategories()
            let category = nonEmptyCategories[section]
            let filtered = category.trackers.filter { tracker in
                guard let selectedWeekday = WeekDay.from(date: selectedDate) else { return false }
                return tracker.schedule.contains(selectedWeekday)
            }
            return filtered.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let nonEmptyCategories = getNonEmptyCategories()
        let category = nonEmptyCategories[indexPath.section]
        let filtered = category.trackers.filter { tracker in
            guard let selectedWeekday = WeekDay.from(date: selectedDate) else { return false }
            return tracker.schedule.contains(selectedWeekday)
        }
        let tracker = filtered[indexPath.item]
        
        let isCompleted = isTrackerCompleted(trackerId: tracker.id, on: selectedDate)
        let count = completionCount(for: tracker.id)
        let canComplete = canCompleteTracker(on: selectedDate)
        
        cell.configure(with: tracker, isCompleted: isCompleted, completionCount: count, canComplete: canComplete)
        
        cell.completeButton.trackerId = tracker.id
        cell.completeButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.completeButton.addTarget(self, action: #selector(completeButtonTapped(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryHeaderView.reuseIdentifier,
                for: indexPath
              ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        let nonEmptyCategories = getNonEmptyCategories()
        let category = nonEmptyCategories[indexPath.section]
        header.configure(with: category.title)
        
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 167
        let height: CGFloat = 140
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
}

// MARK: - NewHabitViewControllerDelegate

extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        print("🔵 didCreateTracker вызван: \(tracker.name), категория: \(category)")
        
        let colorHex = tracker.color.toHexString()
        let scheduleDays = tracker.schedule.map { String(WeekDay.allDays.firstIndex(of: $0) ?? 0) }.joined(separator: ",")
        
        var categoryEntity = dataStoreManager.categoryStore.fetchCategory(by: category)
        
        if categoryEntity == nil {
            categoryEntity = dataStoreManager.categoryStore.createCategory(title: category)
        }
        
        guard let categoryEntity = categoryEntity else { return }
        
        let _ = dataStoreManager.trackerStore.createTracker(
            name: tracker.name,
            emoji: tracker.emoji,
            colorHex: colorHex,
            scheduleDays: scheduleDays,
            category: categoryEntity
        )
        
        if let existingIndex = self.categories.firstIndex(where: { $0.title == category }) {
            let existingCategory = self.categories[existingIndex]
            let updatedTrackers = existingCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(title: category, trackers: updatedTrackers)
            var updatedCategories = self.categories
            updatedCategories[existingIndex] = updatedCategory
            self.categories = updatedCategories
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            self.categories.append(newCategory)
        }
        
        updatePlaceholderVisibility()
    }
}

// MARK: - TrackerCell

class TrackerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    
    let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor(red: 51/255, green: 207/255, blue: 105/255, alpha: 1)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
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
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(lessThanOrEqualTo: completeButton.leadingAnchor, constant: -8),
            
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int, canComplete: Bool) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        
        let count = completionCount
        let daysText = count % 10 == 1 && count % 100 != 11 ? "\(count) день" :
                       (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20) ? "\(count) дня" : "\(count) дней")
        daysLabel.text = daysText
        
        if !canComplete {
            completeButton.isEnabled = false
            completeButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
            completeButton.setTitle("+", for: .normal)
        } else if isCompleted {
            completeButton.isEnabled = true
            completeButton.setTitle("✓", for: .normal)
            completeButton.backgroundColor = tracker.color.withAlphaComponent(0.5)
        } else {
            completeButton.isEnabled = true
            completeButton.setTitle("+", for: .normal)
            completeButton.backgroundColor = tracker.color
        }
    }
}

extension UIButton {
    private static var trackerIdKey: UInt8 = 0
    
    var trackerId: UUID? {
        get {
            return objc_getAssociatedObject(self, &UIButton.trackerIdKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &UIButton.trackerIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
