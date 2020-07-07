import Foundation
import RxCocoa
import RxSwift
import Action

final class FeedbackReduxViewModel: FeedbackReduxViewModelType {

    private let coordinator: FeedbackCoordinatorType
    private let _selectFeedback = PublishSubject<FeedbackCellModel>()
    private let _submit = PublishSubject<Void>()
    private let _comment = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    private let _state = ReplaySubject<State>.create(bufferSize: 1)
    
    init(coordinator: FeedbackCoordinatorType = FeedbackCoordinator()) {
        self.coordinator = coordinator

        let submitAction = CompletableAction { (reason, comment) in
            coordinator.submit(reason: reason, comment: reason.acceptsComment ? comment : "")
        }

        _submit
            .withLatestFrom(_selectFeedback)
            .withLatestFrom(_comment.startWith("")) { ($0.reason, $1) }
            .bind(to: submitAction.inputs)
            .disposed(by: disposeBag)

        let itemsAction: Action<Void, [Feedback]> = Action {
            coordinator.reasons
        }
        
        let setItems = itemsAction.execute().map { Actions.setFeedbackOptions($0) }
        let selectItem = _selectFeedback.map { Actions.selectFeedback($0.reason) }
        let changeComment = _comment.map { Actions.changeComment($0) }
        
        let actions = Observable.merge(
            setItems,
            selectItem,
            changeComment,
            submitAction.executing.map { Actions.submitting($0) }
        )
        
        actions
            .scan(State.initial) { currentState, action in
                var newState = currentState
                switch action {
                    case .setFeedbackOptions(let options):
                        newState = .init(options: options)
                    case .selectFeedback(let feedback):
                        newState.selectedFeedback = feedback
                    case .changeComment(let comment):
                        newState.comment = comment
                    case .submitting(let isSubmitting):
                        newState.isSubmitting = isSubmitting
                }
                return newState
        }
        .bind(to: _state)
        .disposed(by: disposeBag)
    }

    private enum Actions {
        case setFeedbackOptions([Feedback])
        case selectFeedback(Feedback)
        case changeComment(String)
        case submitting(Bool)
    }
    
    private struct State {
        var comment: String = ""
        var options: [Feedback] = []
        var selectedFeedback: Feedback?
        var isSubmitting: Bool = false
        
        static let initial = State()
    }

    //MARK: FeedbackReduxViewModelType
    
    /// Input
    var reasons: Driver<[FeedbackSection]> {
        Observable
            .combineLatest(_state.map { $0.selectedFeedback },
                           _state.map { $0.options } ) { selected, all in
                            let items = all.map { FeedbackCellModel(reason: $0, isSelected: $0.title == selected?.title) }
                            return [ FeedbackSection(header: "", items: items) ]
        }
        .asDriver()
    }
    
    var isSubmitting: Driver<Bool> {
        _state.map { $0.isSubmitting }.asDriver()
    }
    
    var isErrorHidden: Driver<Bool> {
        Observable
            .combineLatest(_state.map { $0.selectedFeedback != nil },
                           _submit.mapTo(false)) { isSelected, _ in isSelected }
            .startWith(true)
            .asDriver()
    }
    
    var isCommentViewHidden: Driver<Bool> {
        _state
            .map { $0.selectedFeedback != nil ? $0.selectedFeedback?.acceptsComment : false }
            .unwrap()
            .not()
            .asDriver()
    }
    
    /// Output
    var comment: AnyObserver<String> {
        _comment.asObserver()
    }

    var selectFeedback: AnyObserver<FeedbackCellModel> {
        _selectFeedback.asObserver()
    }
    
    var submit: AnyObserver<Void> {
        _submit.asObserver()
    }
    
}

