//
//  AddUserViewController.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 21/12/25.
//

import UIKit

class AddUserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, AddUserViewModelDelegate {

    // MARK: - Properties
    
    private let viewModel = AddUserViewModel()
    private var activeField: UITextField?
    var userToEdit: UserRemote?
    
    static let themeColor = UIColor(hex: "#255E92")
    static let orangeColor = UIColor(named: "bgOrange") ?? UIColor(hex: "#FC683A")

    // MARK: - UI Components
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "logo-bullion")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.keyboardDismissMode = .onDrag
        sv.backgroundColor = .clear
        return sv
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
    
    private lazy var nameLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Name")
    private let nameField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Name")
    
    private lazy var genderLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Gender")
    private let maleCheckbox: UIButton = AddUserViewController.makeCheckboxButton(title: "Male")
    private let femaleCheckbox: UIButton = AddUserViewController.makeCheckboxButton(title: "Female")
    
    private lazy var dobLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Date of Birth")
    private let dobField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "DD MM YYYY")
    
    private lazy var emailLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Email Address")
    private let emailField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Email")
    
    private lazy var phoneLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Phone Number")
    private let phoneField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Phone Number")
    
    private lazy var addressLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Address")
    private let addressField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Address")
    
    private lazy var photoLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Photo Profile")
    private let photoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.backgroundColor = .white
        return view
    }()
    
    private let photoTextFieldText: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Select Photo"
        lbl.textColor = .systemGray3
        return lbl
    }()
    
    private let photoIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "paperclip")
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var passwordLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Password")
    private let passwordField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Password", isSecure: true)
    
    private let passwordWarningLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Min 8 Char | Min 1 Capital and Number"
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .systemGray
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var confirmPasswordLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Confirm Password")
    private let confirmPasswordField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Re-enter Password", isSecure: true)
    
    private let confirmPasswordWarningLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Make sure the password matches"
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .systemGray
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add Users", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = AddUserViewController.themeColor
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    private let datePicker = UIDatePicker()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.applyBullionGradient()
        viewModel.delegate = self
        setupUI()
        setupActions()
        setupKeyboardHandling()
        
        if let user = userToEdit {
            viewModel.populate(with: user)
            populateUI()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateGradientFrame()
    }
    
    private func populateUI() {
        nameField.text = viewModel.name
        dobField.text = viewModel.dob
        emailField.text = viewModel.email
        phoneField.text = viewModel.phone
        addressField.text = viewModel.address
        
        updateGenderSelection(isMale: viewModel.genderIndex == 0)
        
        if viewModel.photo != nil {
            let text = "profile_photo.jpg"
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
            photoTextFieldText.attributedText = attributedString
            photoTextFieldText.textColor = UIColor(hex: "#255E92")
            photoIconImageView.tintColor = UIColor(hex: "#255E92")
        }
        
        submitButton.setTitle("Update User", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(logoImageView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(bottomSheetView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomSheetView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            bottomSheetView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomSheetView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            bottomSheetView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: -20)
        ])
        
        photoContainerView.addSubview(photoTextFieldText)
        photoContainerView.addSubview(photoIconImageView)
        
        NSLayoutConstraint.activate([
            photoIconImageView.trailingAnchor.constraint(equalTo: photoContainerView.trailingAnchor, constant: -16),
            photoIconImageView.centerYAnchor.constraint(equalTo: photoContainerView.centerYAnchor),
            photoIconImageView.widthAnchor.constraint(equalToConstant: 20),
            photoIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            photoTextFieldText.leadingAnchor.constraint(equalTo: photoContainerView.leadingAnchor, constant: 16),
            photoTextFieldText.trailingAnchor.constraint(equalTo: photoIconImageView.leadingAnchor, constant: -8),
            photoTextFieldText.centerYAnchor.constraint(equalTo: photoContainerView.centerYAnchor)
        ])
        
        let views = [
            nameLabel, nameField,
            genderLabel, maleCheckbox, femaleCheckbox,
            dobLabel, dobField,
            emailLabel, emailField,
            phoneLabel, phoneField,
            addressLabel, addressField,
            photoLabel, photoContainerView,
            passwordLabel, passwordField, passwordWarningLabel,
            confirmPasswordLabel, confirmPasswordField, confirmPasswordWarningLabel,
            submitButton
        ]
        views.forEach { bottomSheetView.addSubview($0) }
        
        if userToEdit != nil {
            passwordLabel.isHidden = true
            passwordField.isHidden = true
            passwordWarningLabel.isHidden = true
            confirmPasswordLabel.isHidden = true
            confirmPasswordField.isHidden = true
            confirmPasswordWarningLabel.isHidden = true
        }
        
        setupConstraints()
        setupDatePicker()
        setupPasswordToggle(for: passwordField)
        setupPasswordToggle(for: confirmPasswordField)
        
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        phoneField.keyboardType = .phonePad
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 24
        let spacing: CGFloat = 8
        let section: CGFloat = 20
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -padding),
            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: spacing),
            nameField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            
            genderLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: section),
            genderLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            maleCheckbox.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: spacing),
            maleCheckbox.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            femaleCheckbox.centerYAnchor.constraint(equalTo: maleCheckbox.centerYAnchor),
            femaleCheckbox.leadingAnchor.constraint(equalTo: maleCheckbox.trailingAnchor, constant: 20),
            
            dobLabel.topAnchor.constraint(equalTo: maleCheckbox.bottomAnchor, constant: section),
            dobLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dobField.topAnchor.constraint(equalTo: dobLabel.bottomAnchor, constant: spacing),
            dobField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dobField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dobField.heightAnchor.constraint(equalToConstant: 50),
            
            emailLabel.topAnchor.constraint(equalTo: dobField.bottomAnchor, constant: section),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: spacing),
            emailField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            phoneLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: section),
            phoneLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: spacing),
            phoneField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            phoneField.heightAnchor.constraint(equalToConstant: 50),
            
            addressLabel.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: section),
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressField.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: spacing),
            addressField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            addressField.heightAnchor.constraint(equalToConstant: 50),
            
            photoLabel.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: section),
            photoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            photoContainerView.topAnchor.constraint(equalTo: photoLabel.bottomAnchor, constant: spacing),
            photoContainerView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            photoContainerView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            photoContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        if userToEdit == nil {
            NSLayoutConstraint.activate([
                passwordLabel.topAnchor.constraint(equalTo: photoContainerView.bottomAnchor, constant: section),
                passwordLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                
                passwordWarningLabel.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 4),
                passwordWarningLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                
                passwordField.topAnchor.constraint(equalTo: passwordWarningLabel.bottomAnchor, constant: spacing),
                passwordField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                passwordField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                passwordField.heightAnchor.constraint(equalToConstant: 50),
                
                confirmPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: section),
                confirmPasswordLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                
                confirmPasswordWarningLabel.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 4),
                confirmPasswordWarningLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                
                confirmPasswordField.topAnchor.constraint(equalTo: confirmPasswordWarningLabel.bottomAnchor, constant: spacing),
                confirmPasswordField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                confirmPasswordField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),
                
                submitButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 50),
            ])
        } else {
            NSLayoutConstraint.activate([
                submitButton.topAnchor.constraint(equalTo: photoContainerView.bottomAnchor, constant: 50),
            ])
        }
        
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        let toolbar = UIToolbar(); toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDate))
        toolbar.setItems([done], animated: true)
        dobField.inputView = datePicker
        dobField.inputAccessoryView = toolbar
        
        // Add Calendar Icon to DOB Field (Using asset calendarAlt)
        let iconView = UIImageView(image: UIImage(named: "calendarAlt"))
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        iconView.frame = CGRect(x: 0, y: 15, width: 20, height: 20)
        container.addSubview(iconView)
        
        dobField.rightView = container
        dobField.rightViewMode = .always
    }
    
    private func setupPasswordToggle(for tf: UITextField) {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.setImage(UIImage(systemName: "eye"), for: .selected)
        btn.tintColor = .systemGray
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        btn.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btn.center = container.center
        container.addSubview(btn)
        tf.rightView = container
        tf.rightViewMode = .always
    }

    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        phoneField.addTarget(self, action: #selector(phoneChanged), for: .editingChanged)
        addressField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(confirmPasswordChanged), for: .editingChanged)
        maleCheckbox.addTarget(self, action: #selector(maleTapped), for: .touchUpInside)
        femaleCheckbox.addTarget(self, action: #selector(femaleTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        photoContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhotoTapped)))
        photoContainerView.isUserInteractionEnabled = true
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func nameChanged(_ sender: UITextField) { viewModel.name = sender.text }
    @objc func emailChanged(_ sender: UITextField) { viewModel.email = sender.text }
    @objc func phoneChanged(_ sender: UITextField) { viewModel.phone = sender.text }
    @objc func addressChanged(_ sender: UITextField) { viewModel.address = sender.text }
    @objc func passwordChanged(_ sender: UITextField) { viewModel.updatePassword(sender.text ?? "") }
    @objc func confirmPasswordChanged(_ sender: UITextField) { viewModel.confirmPassword = sender.text }
    @objc func backTapped() { navigationController?.popViewController(animated: true) }
    @objc func maleTapped() { updateGenderSelection(isMale: true) }
    @objc func femaleTapped() { updateGenderSelection(isMale: false) }
    
    private func updateGenderSelection(isMale: Bool) {
        let maleIcon = isMale ? "checkmark.square.fill" : "square"
        let femaleIcon = isMale ? "square" : "checkmark.square.fill"
        maleCheckbox.setImage(UIImage(systemName: maleIcon), for: .normal)
        femaleCheckbox.setImage(UIImage(systemName: femaleIcon), for: .normal)
        maleCheckbox.tintColor = isMale ? AddUserViewController.themeColor : .systemGray
        femaleCheckbox.tintColor = !isMale ? AddUserViewController.themeColor : .systemGray
        viewModel.genderIndex = isMale ? 0 : 1
    }

    @objc func selectPhotoTapped() {
        let picker = UIImagePickerController(); picker.delegate = self
        picker.sourceType = .photoLibrary; present(picker, animated: true)
    }
    
    @objc func doneDate() {
        let formatter = DateFormatter(); formatter.dateFormat = "dd MMMM yyyy"
        let dateString = formatter.string(from: datePicker.date)
        dobField.text = dateString; viewModel.dob = dateString
        view.endEditing(true)
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let container = sender.superview, let tf = container.superview as? UITextField {
            tf.isSecureTextEntry = !sender.isSelected
        }
    }
    
    @objc func submitTapped() { viewModel.submit() }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
    }
    
    static func makeTitleLabel(text: String) -> UILabel {
        let lbl = UILabel(); lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = text; lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium); lbl.textColor = orangeColor
        return lbl
    }
    
    static func makeRoundedTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let tf = UITextField(); tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder; tf.layer.cornerRadius = 25; tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor; tf.isSecureTextEntry = isSecure
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50)); tf.leftViewMode = .always
        return tf
    }
    
    static func makeCheckboxButton(title: String) -> UIButton {
        let btn = UIButton(type: .system); btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("  \(title)", for: .normal); btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.tintColor = .systemGray; btn.setTitleColor(.black, for: .normal); return btn
    }
    
    func onLoading(_ isLoading: Bool) { self.showLoading(isLoading) }
    func onRegistrationSuccess() {
        let alert = UIAlertController(title: "Success", message: viewModel.isEditMode ? "User updated successfully!" : "User registered successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true) }))
        present(alert, animated: true)
    }
    func onRegistrationFailure(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default)); present(alert, animated: true)
    }
    func onValidationFailure(errors: [String]) {
        let alert = UIAlertController(title: "Validation Error", message: errors.joined(separator: "\n"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default)); present(alert, animated: true)
    }
    func onPasswordValidationUpdate(isValid: Bool, message: String) {
        passwordWarningLabel.text = message; passwordWarningLabel.textColor = isValid ? .systemGreen : .systemRed
    }
    func onValidationSuccess() {}
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            if let error = viewModel.setPhoto(image) {
                print(error)
            } else {
                let filename: String
                if let url = info[.imageURL] as? URL {
                    filename = url.lastPathComponent
                } else {
                    filename = "image_\(Int(Date().timeIntervalSince1970)).jpg"
                }
                
                if userToEdit != nil {
                    let attributedString = NSMutableAttributedString(string: filename)
                    attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: filename.count))
                    photoTextFieldText.attributedText = attributedString
                    photoTextFieldText.textColor = UIColor(hex: "#255E92")
                    photoIconImageView.tintColor = UIColor(hex: "#255E92")
                } else {
                    photoTextFieldText.attributedText = nil
                    photoTextFieldText.text = filename
                    photoTextFieldText.textColor = .black
                    photoIconImageView.tintColor = .systemGray
                }
            }
        }
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
