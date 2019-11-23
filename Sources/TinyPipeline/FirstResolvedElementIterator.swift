// MARK: - FirstResolvedElementIterator

/// The iterator will try to provide the next element if value is still unresolved.
struct FirstResolvedElementIterator<Element, Output> {
    
    var elements: [Element]
    
//    var context: () -> PipelineContext<Output>
    
    mutating func next() -> Element? {
        
        return nil
        
//        let isValueResolved = (context().resolvedValue != nil)
//
//        if isValueResolved { return nil }
//        else { return elements.isEmpty ? nil : elements.removeFirst() }
        
    }
    
}

// MARK: - IteratorProtocol

extension FirstResolvedElementIterator: IteratorProtocol { }
