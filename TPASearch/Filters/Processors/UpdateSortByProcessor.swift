final class UpdateSortByProcessor: SearchFilterEventProcessor<SearchFilterEvents.SortByDidUpdate> {
    override func update(_ query: inout SearchQuery, for event: SearchFilterEvents.SortByDidUpdate) {
        query.sortBy = event.sortBy
    }
}
