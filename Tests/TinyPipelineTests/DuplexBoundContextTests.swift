// MARK: - DuplexBoundContextTests

import XCTest

@testable import TinyPipeline

final class DuplexBoundContextTests: XCTestCase {
    
    func testInitialize() {
        
        let context = DuplexBoundContext<Int, Error>()
        
        XCTAssert(context.resultInfo.isEmpty)
        
        XCTAssertNil(context.finalResultID)
        
    }
    
    func testUpdateResultForDuplex() throws {
        
        var context = DuplexBoundContext<Int, Error>()
        
        let id1 = DuplexID()
        
        context.updateResult(.success(1), id: id1)
        
        XCTAssertEqual(id1, context.finalResultID)
        
        XCTAssertEqual(try context.resultInfo[id1]?.get(), 1)
        
        let id2 = DuplexID()
        
        context.updateResult(.success(2), id: id2)
        
        XCTAssertEqual(id2, context.finalResultID)
        
        XCTAssertEqual(try context.resultInfo[id1]?.get(), 1)
        
        XCTAssertEqual(try context.resultInfo[id2]?.get(), 2)
        
    }
    
}

extension DuplexBoundContextTests {
    
    static var allTests = [
        ("testInitialize", testInitialize),
        ("testUpdateResultForDuplex", testUpdateResultForDuplex),
    ]
    
}
