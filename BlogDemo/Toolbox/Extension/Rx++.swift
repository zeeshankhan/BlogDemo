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

public protocol OptionalType {
    associatedtype Wrapped
    var hasValue: Bool { get }
    var content: Wrapped { get }
}

extension Optional: OptionalType {
    public var hasValue: Bool {
        switch self {
            case .none:
                return false
            case .some:
                return true
        }
    }
    public var content: Wrapped {
        return self!
    }
}

extension ObservableType where Element: OptionalType {
    /// Filters `nil` events, and emits unwrapped values.
    public func unwrap() -> Observable<Element.Wrapped> {
        return filter { $0.hasValue }.map { $0.content }
    }
}
