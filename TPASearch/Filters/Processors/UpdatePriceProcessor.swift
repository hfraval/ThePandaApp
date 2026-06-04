final class UpdatePriceProcessor: SearchFilterEventProcessor<SearchFilterEvents.PriceDidUpdate> {
    override func update(_ query: inout SearchQuery, for event: SearchFilterEvents.PriceDidUpdate) {
        query.maxPrice = event.maxPrice
    }
}
