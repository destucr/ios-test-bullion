import UIKit

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
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "closeIcon")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor(hex: "#7D7D7D")
        btn.imageView?.contentMode = .scaleAspectFit
        let padding: CGFloat = (44 - 8.25) / 2
        btn.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
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
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = UIColor(hex: "#5D5D5D")
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
        
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped)))
    }
    
    @objc private func photoTapped() {
        guard let image = photoImageView.image else { return }
        
        let fullScreenView = UIView(frame: UIScreen.main.bounds)
        fullScreenView.backgroundColor = .black
        fullScreenView.alpha = 0
        
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFit
        iv.frame = fullScreenView.bounds
        fullScreenView.addSubview(iv)
        
        let closeBtn = UIButton(type: .system)
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = .white
        closeBtn.frame = CGRect(x: UIScreen.main.bounds.width - 60, y: 60, width: 44, height: 44)
        closeBtn.addTarget(self, action: #selector(dismissFullScreenPhoto(_:)), for: .touchUpInside)
        fullScreenView.addSubview(closeBtn)
        
        if let window = window {
            window.addSubview(fullScreenView)
            UIView.animate(withDuration: 0.3) {
                fullScreenView.alpha = 1
            }
        }
    }
    
    @objc private func dismissFullScreenPhoto(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.superview?.alpha = 0
        }) { _ in
            sender.superview?.removeFromSuperview()
        }
    }
    
    private func configure(with user: UserRemote) {
        nameLabel.text = user.displayName
        emailLabel.text = user.email
        
        if let photoBase64 = user.photo, !photoBase64.isEmpty {
            let cleanBase64 = photoBase64.components(separatedBy: ",").last ?? photoBase64
            if let imageData = Data(base64Encoded: cleanBase64) {
                photoImageView.image = UIImage(data: imageData)
            }
        } else {
            photoImageView.image = UIImage(systemName: "person.fill")
        }
        
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
        
        stackView.addArrangedSubview(makeInfoRow(title: "Gender", value: user.gender?.uppercased() ?? "N/A"))
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
        titleLbl.textColor = UIColor(hex: "#5D5D5D")
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
