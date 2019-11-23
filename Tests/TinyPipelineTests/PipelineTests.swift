// MARK: - PipelineTests

import TinyCombine
import XCTest

@testable import TinyPipeline

final class PipelineTests: XCTestCase {
    
    func testSinkPipeline() {
        
        let pipelineDidComplete = expectation(description: "The pipeline did complete.")
        
        let id1 = DuplexID()
        
        let id2 = DuplexID()
        
        let pipeline = Pipeline<Int, DuplexError>(
            [
                Duplex(
                    id: id1,
                    inbound: { id, context in
                      
                        XCTAssertEqual(id, id1)
                      
                        XCTAssertNil(context.finalResultID)
                        
                        XCTAssert(context.resultInfo.isEmpty)
                        
                        return Future { $0(.success(3)) } // Set the initial number.
                        
                    },
                    outbound: { id, context in
                        
                        XCTAssertEqual(id, id1)
                        
                        XCTAssertEqual(context.finalResultID, id2)
                          
                        XCTAssertEqual(
                            context.resultInfo,
                            [ id2: .success(16), ]
                        )
                        
                        return Future { $0(.success(16 - 1)) } // Decrease the number.

                    }
                ),
                Duplex(
                    id: id2,
                    inbound: { id, context in
                      
                        XCTAssertEqual(id, id2)
                        
                        XCTAssertEqual(context.finalResultID, id1)
                        
                        XCTAssertEqual(
                            context.resultInfo,
                            [ id1: .success(3), ]
                        )
                        
                        return Future { $0(.success(3 + 1)) } // Increase the number.
                        
                    },
                    outbound: { id, context in
                        
                        XCTAssertEqual(id, id2)
                        
                        XCTAssertEqual(context.finalResultID, id2)
                          
                        XCTAssertEqual(
                            context.resultInfo,
                            [
                                id1: .success(3),
                                id2: .success(4),
                            ]
                        )
                        
                        return Future { $0(.success(4 * 4)) } // Square the number.

                    }
                ),
            ]
        )

        let stream = pipeline.sink(
            receiveCompletion: { completion in

                defer { pipelineDidComplete.fulfill() }
                
                switch completion {

                case .finished: break

                case let .failure(error): XCTFail("\(error)")

                }

            },
            receiveValue: { value in XCTAssertEqual(value, 15) }
        )

        waitForExpectations(timeout: 10.0)
        
    }
    
}
