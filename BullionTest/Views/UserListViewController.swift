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
        sv.clipsToBounds = false // Allow peeking
        return sv
    }()
    
    private let bannerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    
    private let indicatorStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
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
        btn.setTitle("Add Users", for: .normal)
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

    private let banners: [String] = ["banner-first", "banner-second"]
    private var bufferedBanners: [String] = []

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyBullionGradient()
        setupUI()
        setupActions()
        setupTableView()
        setupBindings()
        setupBanners()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateGradientFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(logoImageView)
        headerView.addSubview(logoutButton)
        
        let bannerContainer = UIView()
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        bannerContainer.clipsToBounds = true
        view.addSubview(bannerContainer)
        
        bannerContainer.addSubview(bannerScrollView)
        bannerScrollView.addSubview(bannerStackView)
        view.addSubview(indicatorStackView)
        
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(titleLabel)
        bottomSheetView.addSubview(tableView)
        bottomSheetView.addSubview(addUserButton)
        
        let bannerWidth = UIScreen.main.bounds.width - 64
        
        NSLayoutConstraint.activate([
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
            
            bannerContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            bannerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerContainer.heightAnchor.constraint(equalToConstant: 150),
            
            bannerScrollView.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            bannerScrollView.widthAnchor.constraint(equalToConstant: bannerWidth),
            bannerScrollView.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
            bannerScrollView.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor),
            
            bannerStackView.topAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.topAnchor),
            bannerStackView.leadingAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.leadingAnchor),
            bannerStackView.trailingAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.trailingAnchor),
            bannerStackView.bottomAnchor.constraint(equalTo: bannerScrollView.contentLayoutGuide.bottomAnchor),
            bannerStackView.heightAnchor.constraint(equalTo: bannerScrollView.frameLayoutGuide.heightAnchor),
            
            indicatorStackView.topAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: 8),
            indicatorStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorStackView.heightAnchor.constraint(equalToConstant: 12),
            
            bottomSheetView.topAnchor.constraint(equalTo: indicatorStackView.bottomAnchor, constant: 10),
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 24),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addUserButton.topAnchor, constant: -16),
            
            addUserButton.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 24),
            addUserButton.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -24),
            addUserButton.heightAnchor.constraint(equalToConstant: 50),
            addUserButton.bottomAnchor.constraint(equalTo: bottomSheetView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupBanners() {
        bufferedBanners = [banners.last!] + banners + [banners.first!]
        bannerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let bannerWidth = UIScreen.main.bounds.width - 64
        for name in bufferedBanners {
            let iv = UIImageView()
            iv.image = UIImage(named: name); iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true; iv.layer.cornerRadius = 15
            iv.translatesAutoresizingMaskIntoConstraints = false
            bannerStackView.addArrangedSubview(iv)
            iv.widthAnchor.constraint(equalToConstant: bannerWidth).isActive = true
        }
        setupIndicators()
        bannerScrollView.delegate = self
        DispatchQueue.main.async {
            self.bannerScrollView.contentOffset = CGPoint(x: (bannerWidth + 10), y: 0)
            self.updateIndicators(index: 0)
        }
    }
    
    private func setupIndicators() {
        indicatorStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let activeColor = UIColor(named: "indicatorActive") ?? AddUserViewController.orangeColor
        for _ in 0..<banners.count {
            let dot = UIView()
            dot.backgroundColor = activeColor.withAlphaComponent(0.5)
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            indicatorStackView.addArrangedSubview(dot)
        }
    }
    
    private func updateIndicators(index: Int) {
        let activeColor = UIColor(named: "indicatorActive") ?? AddUserViewController.orangeColor
        for (i, dot) in indicatorStackView.arrangedSubviews.enumerated() {
            let isActive = i == index
            UIView.animate(withDuration: 0.3) {
                dot.backgroundColor = activeColor.withAlphaComponent(isActive ? 1.0 : 0.5)
                dot.layer.cornerRadius = isActive ? 6 : 4
                dot.constraints.forEach { c in
                    if c.firstAttribute == .width || c.firstAttribute == .height {
                        c.constant = isActive ? 12 : 8
                    }
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self; tableView.dataSource = self
        tableView.register(UserCardCell.self, forCellReuseIdentifier: "UserCardCell")
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        addUserButton.addTarget(self, action: #selector(addUserTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onDataLoaded = { [weak self] in self?.tableView.reloadData() }
        viewModel.onUserDetailLoaded = { [weak self] user in self?.showUserDetail(user) }
        viewModel.onError = { [weak self] msg in
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default)); self?.present(alert, animated: true)
        }
                viewModel.onLogout = { [weak self] in
                    let loginVC = SignInViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    
                    if let window = self?.view.window {
                        window.rootViewController = nav
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                    }
                }
        viewModel.onLoading = { [weak self] loading in self?.showLoading(isLoading: loading) }
    }
    
    private func showLoading(isLoading: Bool) { self.showLoading(isLoading) }
    private func fetchData() { viewModel.fetchUsers() }
    @objc private func logoutTapped() { viewModel.logout() }
    @objc private func addUserTapped() { navigationController?.pushViewController(AddUserViewController(), animated: true) }
    
    private func showUserDetail(_ user: UserRemote) {
        let popup = UserDetailPopupView(user: user)
        popup.onEdit = { [weak self] in
            let vc = AddUserViewController(); vc.userToEdit = user
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        popup.frame = view.bounds; view.addSubview(popup); popup.alpha = 0
        UIView.animate(withDuration: 0.3) { popup.alpha = 1 }
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return viewModel.users.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCardCell", for: indexPath) as! UserCardCell
        cell.configure(with: viewModel.users[indexPath.row]); return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.fetchUserDetail(id: viewModel.users[indexPath.row]._id)
    }
}

extension UserListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == bannerScrollView else { return }
        let itemWidth = scrollView.frame.width + 10
        let offset = scrollView.contentOffset.x
        
        // Infinite scroll looping logic
        if offset <= 0 {
            scrollView.contentOffset = CGPoint(x: itemWidth * CGFloat(banners.count), y: 0)
        } else if offset >= itemWidth * CGFloat(banners.count + 1) {
            scrollView.contentOffset = CGPoint(x: itemWidth, y: 0)
        }
        
        // Correct Indicator Index Calculation
        // Subtract itemWidth to account for the buffer at index 0
        let relativeOffset = scrollView.contentOffset.x - itemWidth
        var page = Int(round(relativeOffset / itemWidth))
        
        // Loop page index if it goes out of bounds
        if page < 0 {
            page = banners.count - 1
        } else if page >= banners.count {
            page = 0
        }
        
        updateIndicators(index: page)
    }
}

class UserCardCell: UITableViewCell {
    private let cardView: UIView = {
        let v = UIView(); v.translatesAutoresizingMaskIntoConstraints = false; v.backgroundColor = .white
        v.layer.cornerRadius = 15; v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2); v.layer.shadowOpacity = 0.1; v.layer.shadowRadius = 4
        return v
    }()
    private let photoImageView: UIImageView = {
        let iv = UIImageView(); iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray6; iv.layer.cornerRadius = 20; iv.clipsToBounds = true; iv.contentMode = .scaleAspectFill
        return iv
    }()
    private let nameLabel: UILabel = {
        let l = UILabel(); l.translatesAutoresizingMaskIntoConstraints = false; l.font = UIFont.boldSystemFont(ofSize: 12)
        return l
    }()
    private let emailLabel: UILabel = {
        let l = UILabel(); l.translatesAutoresizingMaskIntoConstraints = false; l.font = UIFont.systemFont(ofSize: 10); l.textColor = .gray
        return l
    }()
    private let dobLabel: UILabel = {
        let l = UILabel(); l.translatesAutoresizingMaskIntoConstraints = false; l.font = UIFont.systemFont(ofSize: 10); l.textColor = UIColor(hex: "#030303")
        return l
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier); setupUI() }
    required init?(coder: NSCoder) { fatalError() }
    private func setupUI() {
        backgroundColor = .clear; selectionStyle = .none
        contentView.addSubview(cardView)
        [photoImageView, nameLabel, emailLabel, dobLabel].forEach { cardView.addSubview($0) }
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            photoImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            photoImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 40),
            photoImageView.heightAnchor.constraint(equalToConstant: 40),
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
        nameLabel.text = user.displayName; emailLabel.text = user.email
        if let dobString = user.date_of_birth {
            let iso = ISO8601DateFormatter(); iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso.date(from: dobString) {
                let df = DateFormatter(); df.dateFormat = "dd MMMM yyyy"; dobLabel.text = df.string(from: date)
            } else { dobLabel.text = dobString }
        } else { dobLabel.text = "N/A" }
        if let b64 = user.photo, !b64.isEmpty {
            let clean = b64.components(separatedBy: ",").last ?? b64
            if let data = Data(base64Encoded: clean) { photoImageView.image = UIImage(data: data) }
            else { photoImageView.image = UIImage(systemName: "person.fill") }
        } else { photoImageView.image = UIImage(systemName: "person.fill") }
    }
}
