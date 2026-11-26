/// Where an exchange-rate table came from; decides whether it is fresh enough to show or to persist.
enum RateProvenance { freshCache, staleCache, network }
