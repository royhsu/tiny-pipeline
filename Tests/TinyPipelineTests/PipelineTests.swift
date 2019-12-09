// MARK: - PipelineTests

import Combine
import XCTest

@testable import TinyPipeline

final class PipelineTests: XCTestCase {
    
    func testSink() {
        
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
                        
                        return Future { promise in
                            
                            DispatchQueue.global(qos: .background).async {
                                
                                // Set the initial number.
                                promise(.success(3))
                            
                            }
                            
                        }
                            .eraseToAnyPublisher()
                        
                    },
                    outbound: { id, context in
                        
                        XCTAssertEqual(id, id1)
                        
                        XCTAssertEqual(context.finalResultID, id2)
                          
                        XCTAssertEqual(
                            context.resultInfo,
                            [ id2: .success(16), ]
                        )
                        
                        return Future { promise in
                            
                            DispatchQueue.global(qos: .background).async {
                                
                                // Decrease the number.
                                promise(.success(16 - 1))
                            
                            }
                            
                        }
                            .eraseToAnyPublisher()

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
                        
                        return Future { promise in
                            
                            DispatchQueue.global(qos: .background).async {
                                
                                // Increase the number.
                                promise(.success(3 + 1))
                            
                            }
                            
                        }
                            .eraseToAnyPublisher()
                        
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
                        
                        return Future { promise in
                            
                            DispatchQueue.global(qos: .background).async {
                                
                                // Square the number.
                                promise(.success(4 * 4))
                            
                            }
                            
                        }
                            .eraseToAnyPublisher()

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

extension PipelineTests {
    
    static var allTests = [
        ("testSink", testSink),
    ]
    
}
