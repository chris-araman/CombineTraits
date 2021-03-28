import AsynchronousOperation
import Combine
import Foundation

extension SinglePublisher {
    /// Returns an asynchronous operation that wraps the upstream publisher.
    ///
    /// The uptream publisher is subscribed when the operation starts. The
    /// operation completes when the uptream publisher completes.
    ///
    /// Use `subscribe(on:options:)` when you need to control when the upstream
    /// publisher is subscribed:
    ///
    ///     let operation = upstreamPublisher
    ///         .subscribe(on: DispatchQueue.main)
    ///         .operation()
    func operation() -> TraitPublishers.SingleOperation<Self> {
        TraitPublishers.SingleOperation(self)
    }
    
    /// Returns a publisher which, on subscription, wraps the upstream publisher
    /// in an operation, and adds the operation to the provided operation queue.
    ///
    /// The uptream publisher is subscribed when the operation starts. The
    /// operation completes when the uptream publisher completes. The returned
    /// publisher completes with the operation.
    ///
    /// Use `subscribe(on:options:)` when you need to control when the upstream
    /// publisher is subscribed:
    ///
    ///     let publisher = upstreamPublisher
    ///         .subscribe(on: DispatchQueue.main)
    ///         .inOperationQueue(queue)
    ///
    /// Use `receive(on:options:)` when you need to control when the returned
    /// publisher publishes its elements and completion:
    ///
    ///     let publisher = upstreamPublisher
    ///         .inOperationQueue(queue)
    ///         .receive(on: DispatchQueue.main)
    ///
    /// - parameter operationQueue: The `OperationQueue` to run the publisher in.
    func inOperationQueue(_ operationQueue: OperationQueue)
    -> TraitPublishers.AsOperation<Self>
    {
        TraitPublishers.AsOperation(
            upstream: self,
            operationQueue: operationQueue)
    }
}

// MARK: - AsynchronousOperationPublisher

extension TraitPublishers {
    /// A publisher that runs an asynchronous operation.
    struct AsOperation<Upstream: SinglePublisher>: SinglePublisher {
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        private struct Context {
            let upstream: Upstream
            let queue: OperationQueue
        }
        
        // swiftlint:disable:next colon
        private class Subscription<Downstream: Subscriber>:
            TraitSubscriptions.Single<Downstream, Context>
        where
            Downstream.Input == Output,
            Downstream.Failure == Failure
        {
            private weak var operation: SingleOperation<Upstream>?
            
            override func start(with context: Context) {
                let operation = context.upstream.operation()
                operation.handleCompletion(onQueue: nil) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case nil:
                        self.cancel()
                    case let .success(value):
                        self.receive(.success(value))
                    case let .failure(error):
                        self.receive(.failure(error))
                    }
                }
                self.operation = operation
                context.queue.addOperation(operation)
            }
            
            override func didCancel(with context: Context) {
                operation?.cancel()
            }
        }
        
        private let context: Context
        
        fileprivate init(
            upstream: Upstream,
            operationQueue: OperationQueue)
        {
            context = Context(upstream: upstream, queue: operationQueue)
        }
        
        func receive<S>(subscriber: S)
        where S: Subscriber, S.Failure == Self.Failure, S.Input == Self.Output
        {
            let subscription = Subscription(downstream: subscriber, context: context)
            subscriber.receive(subscription: subscription)
        }
    }
    
    /// An operation that runs a publisher.
    public class SingleOperation<Upstream: SinglePublisher>: AsynchronousOperation<Upstream.Output, Upstream.Failure> {
        private var upstream: Upstream?
        private var cancellable: AnyCancellable?
        
        fileprivate init(_ upstream: Upstream) {
            self.upstream = upstream
        }
        
        override public func main() {
            guard let upstream = upstream else {
                // It can only get nil if operation was cancelled. Who would
                // call main() on a cancelled operation? Nobody.
                preconditionFailure("SingleOperation started without upstream publisher")
            }
            
            cancellable = upstream.sinkSingle { [weak self] result in
                self?.result = result
            }
            
            // Release memory
            self.upstream = nil
        }
        
        override public func cancel() {
            super.cancel()
            upstream = nil
            cancellable = nil
        }
    }
}
