//
//  UserListViewController.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import UIKit

class UserListViewController: UIViewController {

    private let viewModel = UserListViewModel()
    
    // MARK: - UI Components
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "logo-bullion")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Log out", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return btn
    }()
    
    private let bannerScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 15
        return sv
    }()
    
    private let bannerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = AddUserViewController.orangeColor
        pc.pageIndicatorTintColor = AddUserViewController.orangeColor.withAlphaComponent(0.5)
        pc.numberOfPages = 3
        return pc
    }()
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "List Users"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = AddUserViewController.orangeColor
        return lbl
    }()
    
    private let addUserButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add New User", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = AddUserViewController.themeColor
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        return tv
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AddUserViewController.orangeColor
        setupUI()
        setupActions()
        setupTableView()
        setupBindings()
        fetchData()
        setupBanners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(logoImageView)
        headerView.addSubview(logoutButton)
        
        view.addSubview(bannerScrollView)
        bannerScrollView.addSubview(bannerStackView)
        view.addSubview(pageControl)
        
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(titleLabel)
        bottomSheetView.addSubview(tableView)
        bottomSheetView.addSubview(addUserButton)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            logoImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 30),
            
            logoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Banner Scroll View
            bannerScrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            bannerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bannerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bannerScrollView.heightAnchor.constraint(equalToConstant: 150),
            
            bannerStackView.topAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.topAnchor),
            bannerStackView.leadingAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.leadingAnchor),
            bannerStackView.trailingAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.trailingAnchor),
            bannerStackView.bottomAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.bottomAnchor),
            bannerStackView.heightAnchor.constraint(equalTo: bannerScrollView.frameLayoutGuide.heightAnchor),
            
            // Page Control
            pageControl.topAnchor.constraint(equalTo: bannerScrollView.bottomAnchor, constant: 5),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Bottom Sheet
            bottomSheetView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 10),
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 24),
            
            // Table view occupies most space
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addUserButton.topAnchor, constant: -16),
            
            addUserButton.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 24),
            addUserButton.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -24),
            addUserButton.heightAnchor.constraint(equalToConstant: 50),
            addUserButton.bottomAnchor.constraint(equalTo: bottomSheetView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Fix for PageControl colors
        if let activeColor = UIColor(named: "indicatorActive") {
            pageControl.currentPageIndicatorTintColor = activeColor
        } else {
            pageControl.currentPageIndicatorTintColor = AddUserViewController.orangeColor
        }
        
        pageControl.pageIndicatorTintColor = pageControl.currentPageIndicatorTintColor?.withAlphaComponent(0.5)
    }

    private func setupBanners() {
        let bannerNames = ["banner-first", "banner-second", "banner-first"]
        pageControl.numberOfPages = bannerNames.count
        
        bannerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for name in bannerNames {
            let iv = UIImageView()
            iv.image = UIImage(named: name)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 15
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            bannerStackView.addArrangedSubview(iv)
            iv.widthAnchor.constraint(equalTo: bannerScrollView.frameLayoutGuide.widthAnchor).isActive = true
        }
        bannerScrollView.delegate = self
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCardCell.self, forCellReuseIdentifier: "UserCardCell")
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        addUserButton.addTarget(self, action: #selector(addUserTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onDataLoaded = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onUserDetailLoaded = { [weak self] user in
            self?.showUserDetail(user)
        }
        
        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onLogout = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        viewModel.onLoading = { [weak self] isLoading in
            self?.showLoading(isLoading)
        }
    }
    
    private func fetchData() {
        viewModel.fetchUsers()
    }
    
    @objc private func logoutTapped() {
        viewModel.logout()
    }
    
    @objc private func addUserTapped() {
        let vc = AddUserViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showUserDetail(_ user: UserRemote) {
        let popup = UserDetailPopupView(user: user)
        popup.onEdit = {
            print("Edit tapped for user: \(user.name)")
        }
        
        popup.frame = view.bounds
        view.addSubview(popup)
        popup.alpha = 0
        UIView.animate(withDuration: 0.3) {
            popup.alpha = 1
        }
    }
}

// MARK: - TableView Extensions
extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCardCell", for: indexPath) as! UserCardCell
        let user = viewModel.users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        viewModel.fetchUserDetail(id: user._id)
    }
}

// MARK: - ScrollView Delegate
extension UserListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == bannerScrollView {
            let width = scrollView.frame.width
            if width > 0 {
                let pageIndex = round(scrollView.contentOffset.x / width)
                pageControl.currentPage = Int(pageIndex)
            }
        }
    }
}

// MARK: - UserCardCell
class UserCardCell: UITableViewCell {
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        return lbl
    }()
    
    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .gray
        return lbl
    }()
    
    private let dobLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .lightGray
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(photoImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(emailLabel)
        cardView.addSubview(dobLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            photoImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            photoImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 60),
            photoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: dobLabel.leadingAnchor, constant: -8),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            dobLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            dobLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with user: UserRemote) {
        nameLabel.text = user.displayName
        emailLabel.text = user.email
        
        if let dobString = user.date_of_birth {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dobString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "dd MMMM yyyy"
                dobLabel.text = displayFormatter.string(from: date)
            } else { dobLabel.text = dobString }
        } else { dobLabel.text = "N/A" }
        
        if let photoBase64 = user.photo, !photoBase64.isEmpty {
            let cleanBase64 = photoBase64.components(separatedBy: ",").last ?? photoBase64
            if let imageData = Data(base64Encoded: cleanBase64) {
                photoImageView.image = UIImage(data: imageData)
            } else { photoImageView.image = UIImage(systemName: "person.fill") }
        } else { photoImageView.image = UIImage(systemName: "person.fill") }
    }
}

// MARK: - UserDetailPopupView
class UserDetailPopupView: UIView {
    var onEdit: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 22)
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = UIColor(red: 0x5D/255, green: 0x5D/255, blue: 0x5D/255, alpha: 1.0)
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()
    
    private let editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Edit User", for: .normal)
        btn.backgroundColor = AddUserViewController.themeColor
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    init(user: UserRemote) {
        super.init(frame: .zero)
        setupUI()
        configure(with: user)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(containerView)
        containerView.addSubview(closeButton)
        containerView.addSubview(photoImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(emailLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.9),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            photoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            photoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            photoImageView.widthAnchor.constraint(equalToConstant: 120),
            photoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            editButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            editButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32)
        ])
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
    }
    
    private func configure(with user: UserRemote) {
        nameLabel.text = user.displayName
        emailLabel.text = user.email
        
        if let photoBase64 = user.photo, !photoBase64.isEmpty {
            let cleanBase64 = photoBase64.components(separatedBy: ",").last ?? photoBase64
            if let imageData = Data(base64Encoded: cleanBase64) {
                photoImageView.image = UIImage(data: imageData)
            } else { photoImageView.image = UIImage(systemName: "person.fill") }
        } else { photoImageView.image = UIImage(systemName: "person.fill") }
        
        let dobText: String
        if let dobString = user.date_of_birth {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dobString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "dd MMMM yyyy"
                dobText = displayFormatter.string(from: date)
            } else { dobText = dobString }
        } else { dobText = "N/A" }
        
        stackView.addArrangedSubview(makeInfoRow(title: "Gender", value: user.gender ?? "N/A"))
        stackView.addArrangedSubview(makeInfoRow(title: "Phone Number", value: user.phone ?? "N/A"))
        stackView.addArrangedSubview(makeInfoRow(title: "Date of Birth", value: dobText))
        stackView.addArrangedSubview(makeInfoRow(title: "Address", value: user.address ?? "N/A"))
    }
    
    private func makeInfoRow(title: String, value: String) -> UIView {
        let view = UIView()
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLbl.textColor = UIColor(red: 0x5D/255, green: 0x5D/255, blue: 0x5D/255, alpha: 1.0)
        titleLbl.textAlignment = .left
        
        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.text = value
        valueLbl.font = UIFont.systemFont(ofSize: 15)
        valueLbl.textColor = .black
        valueLbl.textAlignment = .left
        
        view.addSubview(titleLbl)
        view.addSubview(valueLbl)
        
        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: view.topAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            valueLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            valueLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            valueLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            valueLbl.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }
    
    @objc private func closeTapped() {
        UIView.animate(withDuration: 0.3, animations: { self.alpha = 0 }) { _ in self.removeFromSuperview() }
    }
    
    @objc private func editTapped() {
        onEdit?()
        closeTapped()
    }
}
