final class UpdateInStockProcessor: SearchFilterEventProcessor<SearchFilterEvents.InStockDidUpdate> {
    override func update(_ query: inout SearchQuery, for event: SearchFilterEvents.InStockDidUpdate) {
        query.inStockOnly = event.inStockOnly
    }
}
