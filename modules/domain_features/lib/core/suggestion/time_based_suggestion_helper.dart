/// Phase 3.2 "Smart Suggestions — time-based" (see `docs/BUSINESS_REQUIREMENT.md`
/// "AI Integration (Phase 3)"): if the user enters an expense at 7-8 AM,
/// prioritize suggesting Breakfast/Coffee-style categories, etc.
///
/// Pure hour-of-day → [CategorySeed] expense category id lookup. Returns
/// null outside the covered windows, leaving the caller's existing
/// "pick the first category" default in place.
String? suggestExpenseCategoryIdForHour(int hour) {
  if (hour >= 6 && hour < 10) return 'c2'; // Cà phê — breakfast/coffee
  if (hour >= 11 && hour < 14) return 'c4'; // Ăn ngoài — lunch
  if (hour >= 18 && hour < 21) return 'c1'; // Ăn uống — dinner
  return null;
}
