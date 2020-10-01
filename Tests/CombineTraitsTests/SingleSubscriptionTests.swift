import Combine
import CombineTraits
import XCTest

class SingleSubscriptionTests: XCTestCase {
    func test_canonical_subclass_compiles() {
        // Here we just test that the documented way to subclass compiles.
        typealias MyOutput = Int
        struct MyFailure: Error { }
        struct MyContext { }
        
        struct MySinglePublisher: SinglePublisher {
            typealias Output = MyOutput
            typealias Failure = MyFailure
            
            let context: MyContext
            
            func receive<S>(subscriber: S)
            where S: Subscriber, Failure == S.Failure, Output == S.Input
            {
                let subscription = Subscription(
                    downstream: subscriber,
                    context: context)
                subscriber.receive(subscription: subscription)
            }
            
            private class Subscription<Downstream: Subscriber>:
                SingleSubscription<Downstream, MyContext>
            where
                Downstream.Input == Output,
                Downstream.Failure == Failure
            {
                override func start(with context: MyContext) { }
                override func didCancel(with context: MyContext) { }
            }
        }
    }
}
