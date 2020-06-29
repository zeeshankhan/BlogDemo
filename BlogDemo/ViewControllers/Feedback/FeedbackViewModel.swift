import Foundation
import RxCocoa
import RxSwift
import Action

public class Feedback: Decodable {
    public let code: String
    public let description: String
    public let acceptsComment: Bool
    
    public init(code: String, description: String, acceptsComment: Bool) {
        self.code = code
        self.description = description
        self.acceptsComment = acceptsComment
    }
    
    private enum CodingKeys: String, CodingKey {
        case code = "reasonCode"
        case description = "reasonDesc"
        case acceptsComment = "acceptComment"
    }
}


protocol FeedbackCoordinatorType {
    var reasons: Observable<[Feedback]> { get }
    func submit(reason: Feedback, comment: String) -> Completable
}

class FeedbackCoordinator: FeedbackCoordinatorType {
    var reasons: Observable<[Feedback]> {
        Observable.just([Feedback(code: "123", description: "This is test", acceptsComment: true)])
    }

    func submit(reason: Feedback, comment: String) -> Completable {
        Observable<Void>.empty().ignoreElements()
    }
}

final class FeedbackViewModel: FeedbackViewModelType {

    private let coordinator: FeedbackCoordinatorType
    private let _selectReason = PublishSubject<FeedbackCellModel>()
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
            .withLatestFrom(_selectReason)
            .withLatestFrom(_comment.startWith("")) { ($0.reason, $1) }
            .bind(to: submitAction.inputs)
            .disposed(by: disposeBag)
    }

    var reasons: Driver<[FeedbackSection]> {
        Observable
            .combineLatest(_selectReason.map { $0.reason.code }.startWith(""),
                           coordinator.reasons) { selected, all in
            let items = all.map { FeedbackCellModel(reason: $0, isSelected: $0.code == selected) }
            return [ FeedbackSection(header: "", items: items) ]
        }
        .asDriver()
    }

    var selectReason: AnyObserver<FeedbackCellModel> {
        _selectReason.asObserver()
    }

    var submit: AnyObserver<Void> {
        _submit.asObserver()
    }

    var isSubmitting: Driver<Bool> {
        submitAction.executing.asDriver(onErrorJustReturn: false)
    }

    var isErrorHidden: Driver<Bool> {
        Observable
            .combineLatest(_selectReason.mapTo(true).startWith(false),
                           _submit.mapTo(false)) { isSelected, _ in isSelected }
            .startWith(true)
            .asDriver()
    }

    var isCommentViewHidden: Driver<Bool> {
        _selectReason
            .map { $0.reason.acceptsComment }
            .not()
            .startWith(true)
            .asDriver()
    }

    var comment: AnyObserver<String> {
        _comment.asObserver()
    }
}

extension ObservableType {
    /// Map all next events to a given value
    public func mapTo<T>(_ value: T) -> Observable<T> {
        return map {_ in value}
    }
    
    /// Map all next events to `Void` event
    public func mapTo() -> Observable<Void> {
        return mapTo(())
    }
}

extension Observable where Element == Bool {
    public func not() -> Observable<Bool> {
        return map(!)
    }
}

extension ObservableConvertibleType {
    /// Converts observable sequence to a Driver trait which completes upon error
    public func asDriver() -> Driver<Element> {
        return asDriver(onErrorDriveWith: Driver.empty())
    }
}
