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

// MARK: - PipelineDuplexCollection

struct PipelineDuplexCollection<Output, Failure> where Failure: Error {
    
    typealias Element = Duplex<Output, Failure>
    
    typealias Context = DuplexBoundContext<Output, Failure>
    
    var elements: AnyBidirectionalCollection<Element>
    
    var context: () -> Context
    
    init<C>(
        _ elements: C,
        context: @escaping () -> Context
    )
    where
        C: BidirectionalCollection,
        C.Index == Int,
        C.Element == Element {
        
        self.elements = AnyBidirectionalCollection(elements)
            
        self.context = context
        
    }
    
}

extension PipelineDuplexCollection: Sequence, IteratorProtocol {
    
    mutating func next() -> Duplex<Output, Failure>? {
        
        return nil
        
    }
    
}

// MARK: - Collection

extension PipelineDuplexCollection: Collection {
    
    var startIndex: AnyIndex { elements.startIndex }

    var endIndex: AnyIndex { elements.endIndex }
    
    func index(after i: AnyIndex) -> AnyIndex { elements.index(after: i) }
    
    subscript(position: AnyIndex) -> Duplex<Output, Failure> {
        
        elements[position]
        
    }
    
}

// MARK: - BidirectionalCollection

extension PipelineDuplexCollection: BidirectionalCollection {
    
    func index(before i: AnyIndex) -> AnyIndex { elements.index(before: i) }
    
}
