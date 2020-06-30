import RxCocoa
import RxSwift
import Foundation

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
