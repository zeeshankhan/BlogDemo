import Foundation
import RxCocoa
import RxSwift
import Action

final class FeedbackReduxViewModel: FeedbackReduxViewModelType {

    private let coordinator: FeedbackCoordinatorType
    private let _selectFeedback = PublishSubject<FeedbackCellModel>()
    private let _submit = PublishSubject<Void>()
    private let _comment = PublishSubject<String>()
    private let submitAction: CompletableAction<(Feedback, String)>
    private let disposeBag = DisposeBag()

    init(coordinator: FeedbackCoordinatorType = FeedbackCoordinator()) {
        self.coordinator = coordinator

        submitAction = CompletableAction { (reason, comment) in
            coordinator.submit(reason: reason, comment: reason.acceptsComment ? comment : "")
        }

        _submit
            .withLatestFrom(_selectFeedback)
            .withLatestFrom(_comment.startWith("")) { ($0.reason, $1) }
            .bind(to: submitAction.inputs)
            .disposed(by: disposeBag)
    }

    var reasons: Driver<[FeedbackSection]> {
        Observable
            .combineLatest(_selectFeedback.map { $0.reason.title }.startWith(""),
                           coordinator.reasons) { selected, all in
            let items = all.map { FeedbackCellModel(reason: $0, isSelected: $0.title == selected) }
            return [ FeedbackSection(header: "", items: items) ]
        }
        .asDriver()
    }

    var selectFeedback: AnyObserver<FeedbackCellModel> {
        _selectFeedback.asObserver()
    }

    var submit: AnyObserver<Void> {
        _submit.asObserver()
    }

    var isSubmitting: Driver<Bool> {
        submitAction.executing.asDriver(onErrorJustReturn: false)
    }

    var isErrorHidden: Driver<Bool> {
        Observable
            .combineLatest(_selectFeedback.mapTo(true).startWith(false),
                           _submit.mapTo(false)) { isSelected, _ in isSelected }
            .startWith(true)
            .asDriver()
    }

    var isCommentViewHidden: Driver<Bool> {
        _selectFeedback
            .map { $0.reason.acceptsComment }
            .not()
            .startWith(true)
            .asDriver()
    }

    var comment: AnyObserver<String> {
        _comment.asObserver()
    }
}

