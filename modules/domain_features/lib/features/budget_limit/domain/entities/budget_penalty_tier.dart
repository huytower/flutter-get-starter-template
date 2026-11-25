/// Phase 3.4 "Over-budget Penalties" (see `docs/BUSINESS_REQUIREMENT.md`'s
/// Smart Budgeting section): level point deductions at 3 escalating
/// over-limit thresholds, shown on the budget chart. Deliberately kept
/// separate from [BudgetLimitStatus] (which only drives the card's
/// safe/warning/over color) so the gamification tiers can change later
/// without touching the core warning logic.
enum BudgetPenaltyTier { none, tier120, tier150, tier200 }

