// MARK: - FirstResolvedElementPipelineTests

import TinyCombine
import XCTest

@testable import TinyPipeline

final class FirstResolvedElementPipelineTests: XCTestCase {
    
    func testSinkPipeline() {
        
        let e = expectation(description: "")
        
        let pipeline = FirstResolvedElementPipeline(
            [
//                Duplex(
//                    id: "1",
//                    inbound: { context in
//
//                        fatalError()
//
//                        let input: Void = ()
//
//                        return Future<Void, Error> { promise in promise(.success(input)) }
//
//                    },
//                    outbound: { context in
//
//                        fatalError()
//
//                        let output = ()
//
//                        return Future<Void, Error> { promise in promise(.success(output)) }
//
//                    }
//                ),
            ]
        )
        
        pipeline.execute { context in
            
            e.fulfill()
            
        }

//        let stream = pipeline.sink(
//            receiveCompletion: { completion in
//
//                switch completion {
//
//                case .finished: break
//
//                case let .failure(error): XCTFail("\(error)")
//
//                }
//
//            },
//            receiveValue: { value in XCTAssertEqual(value, 1) }
//        )

        waitForExpectations(timeout: 10.0)
        
    }
    
}

