// MARK: - FirstResolvedElementIteratorTests

import XCTest

@testable import TinyPipeline

final class FirstResolvedElementIteratorTests: XCTestCase {
    
    func testGetNextElementWhenValueIsStillUnresolved() {
        
//        var iterator = FirstResolvedElementIterator(
//            elements: [ 1, 2 ],
//            context: { PipelineContext<Void>(resolvedValue: nil) }
//        )
//
//        XCTAssertEqual(iterator.next(), 1)
//
//        XCTAssertEqual(iterator.elements, [ 2 ])
//
//        XCTAssertEqual(iterator.next(), 2)
//
//        XCTAssert(iterator.elements.isEmpty)
//
//        XCTAssertEqual(iterator.next(), nil)

    }
    
    func testSkipRestOfElementsWhenValueGetsResolved() {
        
//        var iterator = FirstResolvedElementIterator(
//            elements: [ 1, 2 ],
//            context: { PipelineContext(resolvedValue: ()) }
//        )
//
//        XCTAssertEqual(iterator.next(), nil)
//
//        XCTAssertEqual(iterator.elements, [ 1, 2 ])
        
    }
    
}

extension FirstResolvedElementIteratorTests {
    
    static var allTests = [
        ("testGetNextElementWhenValueIsStillUnresolved", testGetNextElementWhenValueIsStillUnresolved),
        ("testSkipRestOfElementsWhenValueGetsResolved", testSkipRestOfElementsWhenValueGetsResolved),
    ]
    
}
