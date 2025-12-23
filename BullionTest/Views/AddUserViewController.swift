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
    
    static let themeColor = UIColor(red: 37/255, green: 94/255, blue: 146/255, alpha: 1.0)
    static let orangeColor = UIColor(named: "bgOrange") ?? UIColor(red: 252/255, green: 104/255, blue: 58/255, alpha: 1.0)

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
    
    // --- Name ---
    private lazy var nameLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Name")
    private let nameField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Name")
    
    // --- Gender ---
    private lazy var genderLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Gender")
    private let maleCheckbox: UIButton = AddUserViewController.makeCheckboxButton(title: "Male")
    private let femaleCheckbox: UIButton = AddUserViewController.makeCheckboxButton(title: "Female")
    
    // --- DOB ---
    private lazy var dobLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Date of Birth")
    private let dobField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "DD/MM/YY")
    
    // --- Email ---
    private lazy var emailLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Email Address")
    private let emailField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Email")
    
    // --- Phone ---
    private lazy var phoneLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Phone Number")
    private let phoneField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Phone Number")
    
    // --- Address ---
    private lazy var addressLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Address")
    private let addressField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Address")
    
    // --- Photo ---
    private lazy var photoLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Photo Profile")
    private let photoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25 // Half of height 50
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.backgroundColor = .white
        return view
    }()
    
    private let photoTextFieldText: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Select Photo"
        lbl.textColor = .systemGray3 // Placeholder color
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
    
    // --- Password ---
    private lazy var passwordLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Password")
    private let passwordField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Password", isSecure: true)
    
    private let passwordWarningLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Min 8 chars, 1 capital, 1 number, alphanumeric."
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .systemGray
        lbl.numberOfLines = 0
        return lbl
    }()
    
    // --- Confirm Password ---
    private lazy var confirmPasswordLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Confirm Password")
    private let confirmPasswordField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Re-enter Password", isSecure: true)
    
    // --- Submit ---
    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add User", for: .normal)
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
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.backgroundColor = AddUserViewController.orangeColor
        viewModel.delegate = self
        setupUI()
        setupActions()
        setupKeyboardHandling()
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
            // Header View
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
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Bottom Sheet
            bottomSheetView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            bottomSheetView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomSheetView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            bottomSheetView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: -20)
        ])
        
        // Setup Photo Container Content
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
        
        // Add all subviews to bottomSheet
        let views = [
            nameLabel, nameField,
            genderLabel, maleCheckbox, femaleCheckbox,
            dobLabel, dobField,
            emailLabel, emailField,
            phoneLabel, phoneField,
            addressLabel, addressField,
            photoLabel, photoContainerView,
            passwordLabel, passwordField, passwordWarningLabel,
            confirmPasswordLabel, confirmPasswordField,
            submitButton
        ]
        views.forEach { bottomSheetView.addSubview($0) }
        
        setupConstraints()
        setupDatePicker()
        setupPasswordToggle(for: passwordField)
        setupPasswordToggle(for: confirmPasswordField)
        
        // Configure specific field types
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        phoneField.keyboardType = .phonePad
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 24
        let fieldSpacing: CGFloat = 8
        let sectionSpacing: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Name
            nameLabel.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -padding),
            
            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: fieldSpacing),
            nameField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            
            // Gender
            genderLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: sectionSpacing),
            genderLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            maleCheckbox.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: fieldSpacing),
            maleCheckbox.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            maleCheckbox.heightAnchor.constraint(equalToConstant: 30),
            
            femaleCheckbox.centerYAnchor.constraint(equalTo: maleCheckbox.centerYAnchor),
            femaleCheckbox.leadingAnchor.constraint(equalTo: maleCheckbox.trailingAnchor, constant: 20),
            femaleCheckbox.heightAnchor.constraint(equalToConstant: 30),
            
            // DOB
            dobLabel.topAnchor.constraint(equalTo: maleCheckbox.bottomAnchor, constant: sectionSpacing),
            dobLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dobLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            dobField.topAnchor.constraint(equalTo: dobLabel.bottomAnchor, constant: fieldSpacing),
            dobField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dobField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dobField.heightAnchor.constraint(equalToConstant: 50),
            
            // Email
            emailLabel.topAnchor.constraint(equalTo: dobField.bottomAnchor, constant: sectionSpacing),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: fieldSpacing),
            emailField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            // Phone
            phoneLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: sectionSpacing),
            phoneLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            phoneField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: fieldSpacing),
            phoneField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            phoneField.heightAnchor.constraint(equalToConstant: 50),
            
            // Address
            addressLabel.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: sectionSpacing),
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            addressField.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: fieldSpacing),
            addressField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            addressField.heightAnchor.constraint(equalToConstant: 50),
            
            // Photo
            photoLabel.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: sectionSpacing),
            photoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            photoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            photoContainerView.topAnchor.constraint(equalTo: photoLabel.bottomAnchor, constant: fieldSpacing),
            photoContainerView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            photoContainerView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            photoContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Password
            passwordLabel.topAnchor.constraint(equalTo: photoContainerView.bottomAnchor, constant: sectionSpacing),
            passwordLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: fieldSpacing),
            passwordField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordWarningLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 5),
            passwordWarningLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            passwordWarningLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Confirm Password
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordWarningLabel.bottomAnchor, constant: sectionSpacing),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            confirmPasswordField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: fieldSpacing),
            confirmPasswordField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),
            
            // Submit
            submitButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 50),
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
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDate))
        toolbar.setItems([doneButton], animated: true)
        
        dobField.inputView = datePicker
        dobField.inputAccessoryView = toolbar
        
        // Add Calendar Icon to DOB Field
        let iconView = UIImageView(image: UIImage(systemName: "calendar"))
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        iconView.frame = CGRect(x: 0, y: 15, width: 20, height: 20)
        container.addSubview(iconView)
        
        dobField.rightView = container
        dobField.rightViewMode = .always
    }
    
    private func setupPasswordToggle(for textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.center = container.center
        container.addSubview(button)
        
        textField.rightView = container
        textField.rightViewMode = .always
    }

    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        // Bind TextFields
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        phoneField.addTarget(self, action: #selector(phoneChanged), for: .editingChanged)
        addressField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(confirmPasswordChanged), for: .editingChanged)
        
        // Gender Buttons
        maleCheckbox.addTarget(self, action: #selector(maleTapped), for: .touchUpInside)
        femaleCheckbox.addTarget(self, action: #selector(femaleTapped), for: .touchUpInside)
        
        // Back Button
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        // Photo Tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectPhotoTapped))
        photoContainerView.addGestureRecognizer(tap)
        photoContainerView.isUserInteractionEnabled = true
        
        // Delegates
        nameField.delegate = self
        dobField.delegate = self
        emailField.delegate = self
        phoneField.delegate = self
        addressField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Actions
    
    @objc func nameChanged(_ sender: UITextField) { viewModel.name = sender.text }
    @objc func emailChanged(_ sender: UITextField) { viewModel.email = sender.text }
    @objc func phoneChanged(_ sender: UITextField) { viewModel.phone = sender.text }
    @objc func addressChanged(_ sender: UITextField) { viewModel.address = sender.text }
    @objc func passwordChanged(_ sender: UITextField) { viewModel.updatePassword(sender.text ?? "") }
    @objc func confirmPasswordChanged(_ sender: UITextField) { viewModel.confirmPassword = sender.text }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func maleTapped() {
        updateGenderSelection(isMale: true)
    }
    
    @objc func femaleTapped() {
        updateGenderSelection(isMale: false)
    }
    
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
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc func doneDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let dateString = formatter.string(from: datePicker.date)
        dobField.text = dateString
        viewModel.dob = dateString
        view.endEditing(true)
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        // Find the text field
        if let container = sender.superview, let tf = container.superview as? UITextField {
            tf.isSecureTextEntry = !sender.isSelected
        }
    }
    
    @objc func submitTapped() {
        viewModel.submit()
    }
    
    // MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: - Factory Methods
    
    static func makeTitleLabel(text: String) -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = AddUserViewController.orangeColor
        return lbl
    }
    
    static func makeRoundedTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.layer.cornerRadius = 25 // Half of height 50
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.backgroundColor = .white
        tf.isSecureTextEntry = isSecure
        
        // Padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        if !isSecure {
             // If not secure, add right padding too, for symmetry (unless overwritten by rightView later)
             let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
             tf.rightView = rightPadding
             tf.rightViewMode = .always
        }
        
        return tf
    }
    
    static func makeCheckboxButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("  \(title)", for: .normal)
        btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.tintColor = .systemGray
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }
    
    // MARK: - ViewModel Delegate
    
    func onValidationSuccess() {
        // No-op or loading indicator
    }
    
    func onLoading(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    func onRegistrationSuccess() {
        let alert = UIAlertController(title: "Success", message: "User registered successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
    
    func onRegistrationFailure(message: String) {
        let alert = UIAlertController(title: "Registration Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func onValidationFailure(errors: [String]) {
        let alert = UIAlertController(title: "Validation Error", message: errors.joined(separator: "\n"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func onPasswordValidationUpdate(isValid: Bool, message: String) {
        passwordWarningLabel.text = message
        passwordWarningLabel.textColor = isValid ? .systemGreen : .systemRed
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dobField {
            return false // Prevent manual typing for date of birth
        }
        return true
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        // Pass to ViewModel to validate/set
        if let errorMessage = viewModel.setPhoto(image) {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
            photoTextFieldText.text = "Select Photo"
            photoTextFieldText.textColor = .systemGray3
        } else {
            // Update UI if valid
            photoTextFieldText.text = "Photo Selected"
            photoTextFieldText.textColor = .black
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

#Preview {
    UINavigationController(rootViewController: AddUserViewController())
}
