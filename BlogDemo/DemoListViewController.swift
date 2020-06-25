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
        title = "Demo List"

        view.addSubview(listTableView)
        listTableView.edgesToSuperview()
    }

    private func bindViewModels() {
        let items = [
            "Keyboard handling with bottom Text Field",
            "Show Toast",
            "Hide",
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
                navigationController?.pushViewController(BottomTextFieldDemoVC(), animated: true)
            case 1:
                Toast.shared.show(text: "This is a good toast")
            default:
                Toast.shared.hide()
                return
        }
    }
}
