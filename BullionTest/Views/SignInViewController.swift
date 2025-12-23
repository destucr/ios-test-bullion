//
//  SignInViewController.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 21/12/25.
//

import UIKit

class SignInViewController: UIViewController {

    private let viewModel = SignInViewModel()
    private let topAreaGuide = UILayoutGuide()
    private var bottomSheetBottomConstraint: NSLayoutConstraint?

    // MARK: - UI Components
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "logo-bullion")
        iv.contentMode = .scaleAspectFit
        return iv
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
        lbl.text = "Sign In"
        lbl.font = UIFont.boldSystemFont(ofSize: 24)
        lbl.textColor = AddUserViewController.orangeColor
        lbl.textAlignment = .center
        return lbl
    }()
    
    private lazy var emailLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Email Address")
    private let emailField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Email")
    
    private lazy var passwordLabel: UILabel = AddUserViewController.makeTitleLabel(text: "Password")
    private let passwordField: UITextField = AddUserViewController.makeRoundedTextField(placeholder: "Enter Password", isSecure: true)
    
    private let signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = AddUserViewController.themeColor
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 25
        return btn
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

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.applyBullionGradient()
        setupUI()
        setupActions()
        setupBindings()
        setupKeyboardHandling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateGradientFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        viewModel.onSignInSuccess = { [weak self] in
            let vc = UserListViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewModel.onSignInFailure = { [weak self] errorMessage in
            let alert = UIAlertController(title: "Sign In Failed", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onLoading = { [weak self] isLoading in
            self?.showLoading(isLoading)
        }
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(bottomSheetView)
        view.addLayoutGuide(topAreaGuide)
        
        // Dynamic bottom constraint
        bottomSheetBottomConstraint = bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
               // Bottom sheet
               bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               bottomSheetBottomConstraint!, // Activate dynamic constraint
               bottomSheetView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.47),

               // Top orange area
               topAreaGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               topAreaGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               topAreaGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               topAreaGuide.bottomAnchor.constraint(equalTo: bottomSheetView.topAnchor),

               // Logo centered in orange area
               logoImageView.centerXAnchor.constraint(equalTo: topAreaGuide.centerXAnchor),
               logoImageView.centerYAnchor.constraint(equalTo: topAreaGuide.centerYAnchor),
               logoImageView.widthAnchor.constraint(equalToConstant: 120),
               logoImageView.heightAnchor.constraint(equalToConstant: 80)
           ])

        let views = [
            emailLabel,
            emailField,
            passwordLabel,
            passwordField,
            signInButton,
            addUserButton
        ]

        views.forEach { bottomSheetView.addSubview($0) }
        
        let padding: CGFloat = 24
        
        NSLayoutConstraint.activate([
            emailLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: padding),
            emailLabel.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -padding),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40),
            signInButton.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            addUserButton.topAnchor
                .constraint(equalTo: signInButton.bottomAnchor, constant: 20),
            addUserButton.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            addUserButton.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            addUserButton.heightAnchor.constraint(equalToConstant: 50),
            addUserButton.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: -40)
        ]
)
        
        setupPasswordToggle(for: passwordField)
        
        // Configure Keyboard Types
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
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
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupActions() {
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        addUserButton.addTarget(self, action: #selector(addUserTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func emailChanged(_ sender: UITextField) { viewModel.email = sender.text }
    @objc func passwordChanged(_ sender: UITextField) { viewModel.password = sender.text }
    
    @objc func signInTapped() {
        viewModel.signIn()
        // Here you would navigate to the main app flow
    }
    
    @objc func addUserTapped() {
        let vc = AddUserViewController()
        // If pushing to stack:
        navigationController?.pushViewController(vc, animated: true)
        // Ensure nav bar is visible or handle back button in custom UI if hidden.
        // Usually we want the back button.
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {

        sender.isSelected.toggle()

        if let container = sender.superview, let tf = container.superview as? UITextField {

            tf.isSecureTextEntry = !sender.isSelected

        }

    }
    
    // MARK: - Keyboard Handling
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Move the bottom sheet up by the keyboard height
            bottomSheetBottomConstraint?.constant = -keyboardSize.height + 30 // +30 buffer if needed, or 0
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // Reset the bottom sheet position
        bottomSheetBottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

}

    
    
    #Preview {
    
        SignInViewController()
    
    }
    
    
