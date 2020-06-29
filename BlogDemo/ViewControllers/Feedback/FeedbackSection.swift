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

struct FeedbackCellModel {
    let reason: Feedback
    let isSelected: Bool
}
