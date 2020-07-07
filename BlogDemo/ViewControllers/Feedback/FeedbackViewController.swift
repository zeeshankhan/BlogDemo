import Foundation
import UIKit
import Cartography
import RxSwift
import RxCocoa
import RxDataSources

protocol FeedbackViewModelType {
    /// Input
    var reasons: Driver<[FeedbackSection]> { get }
    var isSubmitting: Driver<Bool> { get }
    var isErrorHidden: Driver<Bool> { get }
    var isCommentViewHidden: Driver<Bool> { get }
    
    /// Output
    var selectFeedback: AnyObserver<FeedbackCellModel> { get }
    var comment: AnyObserver<String> { get }
    var submit: AnyObserver<Void> { get }
}

final class FeedbackViewController: UIViewController {

    private lazy var listTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(FeedbackCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

    private lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Please enter some comments"
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Please select a feedback."
        label.textColor = .red
        return label
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        return button
    }()
    
    private var keyboardHeightConstraint: NSLayoutConstraint!
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
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
            .bind(to: viewModel.selectFeedback)
            .disposed(by: disposeBag)

        viewModel.reasons
            .drive(listTableView.rx.items(dataSource: rxDataSource))
            .disposed(by: disposeBag)

        viewModel.isErrorHidden
            .drive(errorLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.isCommentViewHidden
            .drive(commentTextField.rx.isHidden)
            .disposed(by: disposeBag)

        commentTextField.rx
            .text
            .orEmpty
            .bind(to: viewModel.comment)
            .disposed(by: disposeBag)

        submitButton.rx
            .tap
            .bind(to: viewModel.submit)
            .disposed(by: disposeBag)

        Observable.merge(submitButton.rx.tap.mapTo(),
                         listTableView.rx.itemSelected.mapTo())
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)

    }

    //MARK: - Setup UI
    private func setupUI() {
        title = "Feedback Form"
        view.backgroundColor = .white

        let footerStack = UIStackView(arrangedSubviews: [commentTextField, errorLabel, submitButton])
        footerStack.spacing = 8
        footerStack.axis = .vertical

        view.addSubview(listTableView)
        view.addSubview(footerStack)
        constrain(view, listTableView, footerStack) { container, tableView, footer in
            tableView.top == container.safeAreaLayoutGuide.top
            tableView.leading == container.leading
            tableView.trailing == container.trailing
            footer.top == tableView.bottom + 16
            footer.leading == container.leading + 16
            footer.trailing == container.trailing - 16
            keyboardHeightConstraint = footer.bottom == container.safeAreaLayoutGuide.bottom - 16
        }

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleNotification(notification: Notification) {
        guard let info = notification.keyboardInfo else { return }
        let height = max(0, info.height - view.safeAreaInsets.bottom + 16)
        keyboardHeightConstraint.constant = -height
        UIView.animate(withDuration: info.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
