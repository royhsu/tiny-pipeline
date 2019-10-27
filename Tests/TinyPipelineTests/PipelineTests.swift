// MARK: - PipelineTests

import XCTest

@testable import TinyPipeline

final class PipelineTests: XCTestCase {
    
    func testInitialize() {
        
        let pipeline = Pipeline<Void>(
            elements: [ .init { _ in }, .init { _ in }, .init { _ in }, ]
        )
        
        XCTAssertEqual(pipeline.elementContainers.map { $0.id }, [ 0, 1, 2 ])
        
    }
    
    func testResolveWithSuccessByCurrentHandler() {
        
        let didEmitResolveEvent = expectation(description: "Did emit a resolve event.")
        
        let didCompleteResolveAndEvents = expectation(description: "Did complete resolve and events.")
        
        var isResolved = false
        
        let resolvingHandler = Pipeline.resolveCurrentElementHandler(
            { $0(.success("current")) },
            ifFailureThenTryNextElementHandler: { $0(.success("next")) }
        )
        
        let finalHandler = Pipeline.resolvingHandler(
            resolvingHandler,
            didResolve: { kind in
                
                didEmitResolveEvent.fulfill()
                
                return { promise in
                    
                    XCTAssertFalse(isResolved)
                    
                    XCTAssertEqual(kind, .current)
                    
                    promise(.success(()))
                    
                }
                
            }
        )
        
        finalHandler { result in
            
            defer { didCompleteResolveAndEvents.fulfill() }
            
            do {
                
                let output = try result.get()
                
                XCTAssertEqual(output, "current")
                
            }
            catch { XCTFail("\(error)") }
            
        }
        
        waitForExpectations(timeout: 10.0)
        
    }
    
    func testResolveWithSuccessByNextHandler() {
        
        let didEmitResolveEvent = expectation(description: "Did emit a resolve event.")
        
        let didCompleteResolveAndEvents = expectation(description: "Did complete resolve and events.")
        
        var isResolved = false
        
        let resolvingHandler = Pipeline.resolveCurrentElementHandler(
            { $0(.failure(.unhandledPipeline)) },
            ifFailureThenTryNextElementHandler: { $0(.success("next")) }
        )
        
        let finalHandler = Pipeline.resolvingHandler(
            resolvingHandler,
            didResolve: { kind in
                
                didEmitResolveEvent.fulfill()
                
                return { promise in
                    
                    XCTAssertFalse(isResolved)
                    
                    XCTAssertEqual(kind, .next)
                    
                    promise(.success(()))
                    
                }
                
            }
        )
        
        finalHandler { result in
            
            defer { didCompleteResolveAndEvents.fulfill() }
            
            do {
                
                let output = try result.get()
                
                XCTAssertEqual(output, "next")
                
            }
            catch { XCTFail("\(error)") }
            
        }
        
        waitForExpectations(timeout: 10.0)
        
    }

    func testResolveWithFailureFromNextHandlerEventually() {

        struct NextHandlerError: Error, Equatable {
            
            var id: Int
            
        }
        
        let didResolveWithFailureFromNextHandler = expectation(description: "Did resolve with a failure from the next handler eventually.")
        
        let resolvingHandler = Pipeline<String>.resolveCurrentElementHandler(
            { $0(.failure(.unhandledPipeline)) },
            ifFailureThenTryNextElementHandler: { promise in
                
                promise(.failure(.elementFailure(NextHandlerError(id: 1))))
                
            }
        )
        
        let finalHandler = Pipeline.resolvingHandler(
            resolvingHandler,
            didResolve: { kind in
                
                { promise in
                    
                    XCTFail("SHOULD NOT emit the did resolve event.")
                    
                    promise(.success(()))
                    
                }
                
            }
        )
        
        finalHandler { result in
            
            do {
                
                _ = try result.get()
                
                XCTFail("It's supposed to be failed.")
                
            }
            catch let error as PipelineError {
                
                guard case let .elementFailure(elementError) = error else {
                    
                    XCTFail("Unexpected error: \(error).")
                    
                    return
                    
                }
                
                XCTAssertEqual(
                    elementError as? NextHandlerError,
                    NextHandlerError(id: 1)
                )
                
                didResolveWithFailureFromNextHandler.fulfill()
                
            }
            catch { XCTFail("Unexpected error: \(error).") }
            
        }
        
        waitForExpectations(timeout: 10.0)
        
    }
    
    func testResolveWithSuccessButFailureInEvents() {
        
        struct DidResolveEventError: Error, Equatable {
            
            var id: Int
            
        }
        
        let didEmitResolveEvent = expectation(description: "Did emit a resolve event.")
        
        let didCompleteResolveAndEvents = expectation(description: "Did complete resolve and events.")
        
        var isResolved = false
        
        let resolvingHandler = Pipeline.resolveCurrentElementHandler(
            { $0(.success("current")) },
            ifFailureThenTryNextElementHandler: { $0(.success("next")) }
        )
        
        let finalHandler = Pipeline.resolvingHandler(
            resolvingHandler,
            didResolve: { kind in
                
                didEmitResolveEvent.fulfill()
                
                return { promise in
                    
                    XCTAssertFalse(isResolved)
                    
                    XCTAssertEqual(kind, .current)
                    
                    promise(
                        .failure(
                            .elementFailure(
                                DidResolveEventError(id: 1)
                            )
                        )
                    )
                    
                }
                
            }
        )
        
        finalHandler { result in
            
            defer { didCompleteResolveAndEvents.fulfill() }
            
            do {
                
                _ = try result.get()
                
                XCTFail("It's supposed to be failed.")
                
            }
            catch let error as PipelineError {
                
                guard case let .elementFailure(elementFailure) = error else {
                    
                    XCTFail("Unexpected error: \(error).")
                    
                    return
                    
                }
                
                XCTAssertEqual(
                    elementFailure as? DidResolveEventError,
                    DidResolveEventError(id: 1)
                )
                
            }
            catch { XCTFail("Unexpected error: \(error).") }
            
        }
        
        waitForExpectations(timeout: 10.0)
        
    }
    
    func testExecutePipeline() {
        
        struct Passthrough: Error { }
        
        let didEmitResolveEvent = expectation(description: "Did emit a resolve event.")
        
        didEmitResolveEvent.expectedFulfillmentCount = 2
        
        let didCompleteResolveAndEvents = expectation(description: "Did complete resolve and events.")
        
        var isResolved = false
        
        let pipeline = Pipeline<String>(
            elements: [
                Pipeline.Element { promise in
                    
                    DispatchQueue.global().async {
                        
                        promise(.failure(.elementFailure(Passthrough())))
                        
                    }

                }
                    .onResolve { kind in
                        
                        #warning("TODO: [Priority: high] won't be called.")
                        didEmitResolveEvent.fulfill()
                        
                        return { promise in
                            
                            XCTAssertFalse(isResolved)
                            
                            XCTAssertEqual(kind, .next)
                            
                            promise(.success(()))
                            
                        }
                        
                    },
                Pipeline.Element { promise in
                    
                    DispatchQueue.global().async {
                        
                        promise(.failure(.elementFailure(Passthrough())))
                        
                    }

                }
                    .onResolve { kind in
                        
                        didEmitResolveEvent.fulfill()
                        
                        return { promise in
                            
                            XCTAssertFalse(isResolved)
                            
                            XCTAssertEqual(kind, .next)
                            
                            promise(.success(()))
                            
                        }
                        
                    },
                Pipeline.Element { promise in
                    
                    DispatchQueue.global().async { promise(.success("second")) }

                }
                    .onResolve { kind in
                        
                        didEmitResolveEvent.fulfill()
                        
                        return { promise in
                            
                            XCTAssertFalse(isResolved)
                            
                            XCTAssertEqual(kind, .current)
                            
                            promise(.success(()))
                            
                        }
                        
                    },
                Pipeline.Element { promise in
                    
                    DispatchQueue.global().async {
                        
                        promise(.failure(.elementFailure(Passthrough())))
                        
                    }

                }
                    .onResolve { kind in
                        
                        XCTFail("SHOULD NOT emit the resolve event, it's been resolved by the previous element.")
                        
                        return { promise in promise(.success(())) }
                        
                    }
            ]
        )
        
        pipeline.execute { result in
            
            defer { didCompleteResolveAndEvents.fulfill() }
            
            do {
                
                let output = try result.get()
                
                XCTAssertEqual(output, "second")
                
            }
            catch { XCTFail("\(error)") }
            
        }
        
        waitForExpectations(timeout: 10.0)
        
    }
    
}

extension PipelineTests {
    
    static var allTests = [
        ("testInitialize", testInitialize),
        ("testResolveWithSuccessByCurrentHandler", testResolveWithSuccessByCurrentHandler),
        ("testResolveWithSuccessByNextHandler", testResolveWithSuccessByNextHandler),
        ("testResolveWithFailureFromNextHandlerEventually", testResolveWithFailureFromNextHandlerEventually),
        ("testResolveWithSuccessButFailureInEvents", testResolveWithSuccessButFailureInEvents),
        ("testExecutePipeline", testExecutePipeline),
    ]
    
}
