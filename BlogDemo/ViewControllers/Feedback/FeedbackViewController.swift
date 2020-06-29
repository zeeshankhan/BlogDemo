import Foundation
import UIKit
import Cartography
import RxSwift
import RxCocoa
import RxDataSources

protocol FeedbackViewModelType {
    var reasons: Driver<[FeedbackSection]> { get }
    var selectReason: AnyObserver<FeedbackCellModel> { get }
    var submit: AnyObserver<Void> { get }
    var isSubmitting: Driver<Bool> { get }
    var isErrorHidden: Driver<Bool> { get }
    var isCommentViewHidden: Driver<Bool> { get }
    var comment: AnyObserver<String> { get }
}

final class FeedbackViewController: UIViewController {

    private lazy var headerView: UIView = {
        let header = UIView()
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .natural
        label.text = "Feedback Title"

        header.addSubview(label)
        constrain(header, label) { container, label in
            label.leading == container.leading + 16
            label.trailing == container.trailing - 16
            label.top == container.top + 8
            label.bottom == container.bottom - 16
        }
        return header
    }()

    private lazy var listTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.register(FeedbackCell.self, forCellReuseIdentifier: FeedbackCell.className)
        return tableView
    }()

    private lazy var reasonTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.tintColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        textField.placeholder = "Please enter some comments"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.clearButtonMode = .always
        constrain(textField) { textField in
            textField.height == 48
        }
        return textField
    }()

    private lazy var textFieldUnderlineView: UIView = {
        let underline = UIView()
        underline.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        constrain(underline) { underline in
            underline.height == 2
        }
        return underline
    }()

    private lazy var commentView: UIView = {
        let stack = UIStackView(arrangedSubviews: [reasonTextField, textFieldUnderlineView])
        stack.axis = .vertical
        return stack
    }()

    private lazy var errorLabel = UILabel()
    var keyboardHeightConstraint: NSLayoutConstraint!
    private lazy var submitButton = UIButton(type: .system)
    private let viewModel: FeedbackViewModelType
    private let disposeBag = DisposeBag()

    init(viewModel: FeedbackViewModelType = FeedbackViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("FeedbackViewController should only be initilized with init(viewModel: FeedbackViewModelType)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }

    //MARK: - Observers
    private lazy var rxDataSource: RxTableViewSectionedReloadDataSource<FeedbackSection> = {
        RxTableViewSectionedReloadDataSource<FeedbackSection>(configureCell: {
            _, tableView, indexPath, cellViewModel -> FeedbackCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedbackCell.className,
                                                           for: indexPath) as? FeedbackCell else {
                                                            fatalError("Cell should get initialised here")
            }
            cell.populateCell(cellViewModel)
            return cell
        })
    }()

    private func bindViewModel() {

        listTableView.rx
            .modelSelected(FeedbackCellModel.self)
            .bind(to: viewModel.selectReason)
            .disposed(by: disposeBag)

        viewModel.reasons
            .drive(listTableView.rx.items(dataSource: rxDataSource))
            .disposed(by: disposeBag)

        viewModel.isErrorHidden
            .drive(errorLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.isCommentViewHidden
            .drive(commentView.rx.isHidden)
            .disposed(by: disposeBag)

        reasonTextField.rx
            .text
            .orEmpty
            .bind(to: viewModel.comment)
            .disposed(by: disposeBag)

        submitButton.rx
            .tap
            .bind(to: viewModel.submit)
            .disposed(by: disposeBag)

//        viewModel.isSubmitting
//            .drive(submitButton.rx.isLoading)
//            .disposed(by: disposeBag)

        Observable.merge(submitButton.rx.tap.mapTo(),
                         listTableView.rx.itemSelected.mapTo())
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)

    }

    //MARK: - Setup UI
    private func setupUI() {
        
        submitButton.setTitle("Submit", for: .normal)
        
        errorLabel.font = .systemFont(ofSize: 14, weight: .regular)
        errorLabel.textAlignment = .center
        errorLabel.text = "Please add some comments"
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .red
        
        view.backgroundColor = .white
        let footerStack = UIStackView(arrangedSubviews: [commentView, errorLabel, submitButton])
        footerStack.spacing = 16
        footerStack.axis = .vertical

        view.addSubview(footerStack)
        view.addSubview(headerView)
        view.addSubview(listTableView)
        constrain(view, headerView, listTableView, footerStack) { container, header, tableView, footer in
            header.top == container.safeAreaLayoutGuide.top
            header.leading == container.leading
            header.trailing == container.trailing
            tableView.top == header.bottom
            tableView.leading == container.leading
            tableView.trailing == container.trailing
            footer.top == tableView.bottom + 16
        }

        /// Constrain input to the bottom of the view with dependency on keyboard
        
        let keyboardLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(keyboardLayoutGuide)
        constrain(view, keyboardLayoutGuide) { superview, layoutGuide in
            keyboardHeightConstraint = layoutGuide.bottom == superview.safeAreaLayoutGuide.bottom
            layoutGuide.leading == superview.leading
            layoutGuide.trailing == superview.trailing
        }

        constrain(view, footerStack, keyboardLayoutGuide) { superview, inputView, layoutGuide in
            inputView.leading == superview.leading + 16
            inputView.trailing == superview.trailing - 16
            inputView.bottom == layoutGuide.top - 12
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleNotification(notification: Notification) {
        guard let info = notification.keyboardAnimationInfo() else { return }
        let height = max(0, info.height - view.safeAreaInsets.bottom)
        keyboardHeightConstraint.constant = -height
        UIView.animate(withDuration: info.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

}

extension NSObject {

    public var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }

    public class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}
