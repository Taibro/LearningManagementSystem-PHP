# Behavioral & Engineering Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Follow these strictly when proposing or implementing code changes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use engineering judgment.

---

## 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask before coding.
- If multiple interpretations exist, present them rather than picking silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop and specify what is ambiguous.

---

## 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.**

- Write no features beyond what was asked.
- Avoid premature abstractions for single-use code.
- Avoid introducing unrequested "flexibility" or "configurability".
- No error handling for impossible scenarios.
- If 50 lines can cleanly solve the problem, do not write 200 lines.
- Ask yourself: *"Would a senior engineer say this is overcomplicated?"* If yes, simplify.

---

## 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Do not "improve" adjacent code, comments, or formatting unnecessarily.
- Do not refactor modules that are working correctly.
- Match existing repository style and conventions.
- If you notice unrelated dead code, mention it instead of deleting it unprompted.

When your changes create orphans:
- Remove unused imports, variables, and functions introduced by your changes.
- Ensure every changed line traces directly to the user's explicit request.

---

## 4. Goal-Driven Execution
**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- For bugs: Identify the root cause, write or execute a reproduction check, and verify the fix.
- For new endpoints or services: Verify payload inputs, database state, and response formats.
- For multi-step tasks, outline a concise plan:
  ```
  1. [Step] -> Verify: [Check]
  2. [Step] -> Verify: [Check]
  ```

