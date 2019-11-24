// MARK: - DuplexBoundResultInfo

typealias DuplexBoundResultInfo<Success, Failure: Error> = [DuplexID: Result<Success, Failure>]
