import UIKit
import TinyConstraints
import RxSwift
import RxDataSources

class DemoListViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private lazy var listTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModels()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Demo"

        view.addSubview(listTableView)
        listTableView.edgesToSuperview()
    }

    private func bindViewModels() {
        let items = [
            "Show Toast",
            "Hide Toast",
            "Anchor Points",
            "Bottom UITextField Keyboard Handling",
            "Bottom UITextField with UILayoutGuide",
            "Feedback form",
            "Feedback form with REDUX",
        ]
        Observable<[String]>
            .just(items)
            .bind(to: listTableView.rx.items(cellIdentifier: "Cell")) { _, model, cell in
                cell.textLabel?.text = model
            }
            .disposed(by: disposeBag)
    }
}

extension DemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                Toast.shared.show(text: "Ea voluptatibus a illo doloremque reiciendis nemo et earum. Molestiae totam voluptatibus nobis et deleniti dolores. Animi quasi ut voluptatem autem magni. Et voluptas repudiandae unde. Non sapiente maxime voluptas et facere enim.")
            case 1:
                Toast.shared.hide()
            case 2:
                present(AnchorPointsVC(nibName: "AnchorPointsVC", bundle: nil), animated: true, completion: nil)
            case 3:
                navigationController?.pushViewController(BottomTextFieldDemoVC(), animated: true)
            case 4:
                navigationController?.pushViewController(BottomTextFieldDemo2VC(), animated: true)
            case 5:
                navigationController?.pushViewController(FeedbackViewController(), animated: true)
            case 6:
                navigationController?.pushViewController(FeedbackReduxViewController(), animated: true)
            default:
                return
        }
    }
}
