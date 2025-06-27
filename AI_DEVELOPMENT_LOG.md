# AI Development Log

Brief notes on AI collaboration for each development session.

---

## Session 1: Project Setup (2025-06-27)

**Completed:** ReScript project, dependencies, CI/CD, docs, Petstore test spec

**Worked Well:**

- Parallel tool execution for efficiency
- Debugged rescript-vitest → rescript-ava migration successfully
- Comprehensive setup (4/4 tests passing, CI working)

**Could Improve:**

- Research tool stability before choosing (vitest was broken)
- Avoid over-engineering (created unnecessary templates)
- Ask about assumptions (repo naming, complexity level)

**ReScript Tooling Gaps:**

- No ecosystem discovery/package health indicators (hard to assess rescript-vitest vs rescript-ava)
- Cryptic errors when bindings generate wrong JS (Vitest.describe vs describe)
- Missing compatibility matrix for ReScript versions vs packages
- Multiple competing test frameworks without clear official recommendations

**Result:** Solid foundation ready for implementation.
