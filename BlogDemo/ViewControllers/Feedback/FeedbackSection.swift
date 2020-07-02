import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct FeedbackSection {
    typealias Item = FeedbackCellModel
    var header: String
    var items: [Item]
}

extension FeedbackSection: SectionModelType {
    init(original: FeedbackSection, items: [Item]) {
        self = original
        self.items = items
    }
}

/// === Glue ===

struct FeedbackCellModel {
    let reason: Feedback
    let isSelected: Bool
}

public class Feedback {
    public let title: String
    public let acceptsComment: Bool
    
    public init(title: String, acceptsComment: Bool) {
        self.title = title
        self.acceptsComment = acceptsComment
    }
}

protocol FeedbackCoordinatorType {
    var reasons: Observable<[Feedback]> { get }
    func submit(reason: Feedback, comment: String) -> Completable
}

class FeedbackCoordinator: FeedbackCoordinatorType {
    var reasons: Observable<[Feedback]> {
        Observable.just([
            Feedback(title: "App is amazing", acceptsComment: false),
            Feedback(title: "App needs improvement", acceptsComment: true),
            Feedback(title: "App is good but can be improved", acceptsComment: true),
            Feedback(title: "App does not need any improvement so no need to take comments either.", acceptsComment: false),
        ])
    }
    
    func submit(reason: Feedback, comment: String) -> Completable {
        Observable<Void>.empty().ignoreElements()
    }
}
