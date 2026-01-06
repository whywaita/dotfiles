---
path: "**/*.go"
---

# Go Code Style

- Refer to: https://go.dev/wiki/CodeReviewComments#interfaces
- When using make() for slices, maps, or channels, consider whether you can (and should) specify size and/or capacity.
- Avoid hardcoding values; define them as const and use the constants.
- Avoid magic numbers; if you must use them, define them as const and use the constants.
- In tests, don't explicitly set zero values (e.g., nil, false, empty strings); Go will zero-initialize them for you.
- Avoid unnecessary allocations, especially for values used only once.
- When checking if a slice is empty, use len(hoge) == 0; do not distinguish between a nil slice and a zero-length slice.
- Don't include type names in variable names (e.g., avoid xMap, xList).
- Prefer early returns to keep nesting shallow.
- If you have deeply nested for or if statements, consider using continue (or early returns) to reduce nesting.
- For nested loops (e.g., double for), try to reduce complexity from O(N^2) toward O(N) by using maps or other structures where possible.
- Point out missing test cases; at minimum, include one success (happy path) and one failure (error path) test.
- When operating on maps, use the maps package where applicable.
- When operating on slices, use the slices package where applicable.
- Run `go fmt` before finishing work.
