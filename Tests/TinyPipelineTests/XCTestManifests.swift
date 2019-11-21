import XCTest

#if !canImport(ObjectiveC)

public func allTests() -> [XCTestCaseEntry] {
    
    [
        testCase(FirstResolvedElementIteratorTests.allTests),
        testCase(PipelineTests.allTests),
    ]
    
}

#endif
