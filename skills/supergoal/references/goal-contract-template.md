# SuperGoal Contract Template

Use this template when drafting a pasteable goal-mode prompt for Codex or when starting an active goal from a rough request. Replace every placeholder. Keep the result narrow enough that a goal-mode agent can execute it without inventing extra architecture.

Start by defining when Codex should stop. The user does not need to describe every implementation step; the goal prompt should turn their rough request into acceptance metrics, then require the main Codex agent to write the detailed parent goal, dispatch subagents with child goals, integrate their output, and decide final acceptance.

When the user asks how to verify a skill or goal behavior, still output a `Goal:` contract. Do not answer with generic testing advice only.

```text
Goal: <one concrete outcome>

Use $supergoal and $superdev.
Work in <absolute repository path>.

Acceptance-first instruction:
- Treat my request as the desired end state, not as a step-by-step implementation plan.
- First define the observable acceptance metrics and stop conditions.
- Then have the main Codex agent write and own the detailed parent Goal Contract from those metrics before editing code.
- Run the main agent with the model and reasoning effort already active in the current Codex session. Do not inspect, request, require, verify, or switch the main-session profile, and never pause because parent-model controls are unavailable.
- The main agent's default role is dispatcher and acceptor, not direct implementer: define, dispatch, integrate, verify.
- Before implementation, the main agent must pass the dispatch gate by scanning for independent discovery, implementation, and verification slices. If any exist and subagent tools are available, create and dispatch bounded child Goal Contracts to subagents.
- Do not begin production implementation before the dispatch gate is complete, except for minimal context reads needed to write safe child goals.
- Subagents must create or activate their assigned child goal before work, execute only that child goal, then update it to `complete` or `blocked` before returning. They do not redefine scope, decide final completion, launch more agents, or claim parent-goal acceptance.
- The main agent integrates subagent outputs, accepts or rejects their findings/patches, runs final verification, and decides whether the parent goal is done.
- When spawning a subagent, the main agent must send the full child Goal Contract as the first message. The message must start with `Goal:` and include a Goal Lifecycle Instruction requiring child `create_goal` before work and `update_goal complete/blocked` before returning.
- Every subagent spawn must explicitly use `model: gpt-5.6-sol` and `reasoning_effort: xhigh`; `xhigh` is the valid tool value for "extra high". Record any unsupported override and actual fallback in the dispatch ledger.
- Feishu notification defaults to disabled. Enable it only if the user's original request explicitly says "完成后通知我", "飞书通知我", "发飞书给我", "notify me", or equivalent. If enabled, the main agent must send the final status via `lark-cli im +messages-send` only after parent final verification or after a blocked stop condition is reached.

Goal startup instruction:
- If this is being used inside an active Codex session and goal tools are available, create or activate this as the parent goal instead of only returning this block as text.
- If subagent tools are available, launch the bounded child goals below in parallel where their scopes are independent.
- If the subagent tool has no dedicated goal-mode parameter, still pass the full child Goal Contract in the subagent's spawn message. The subagent must use available goal tools to create/activate the child goal before work and update it to `complete` or `blocked` before returning. If the subagent reports that goal tools are unavailable, treat the contract as its active execution boundary and record that fallback in the dispatch ledger.
- If no subagent is launched, state the reason plainly: no tool, no independent slice after scanning, unsafe write overlap, or user explicitly requested solo work. A small feature is not by itself a valid skip reason when read-only reconnaissance or independent verification would help.
- If goal or subagent tools are unavailable, state the fallback plainly and continue sequentially with the same acceptance metrics.

Raw request boundary:
- Treat the original request as context, not as an unlimited execution plan.
- Preserve the intended outcome, but do not automatically include examples, complaints, optional ideas, or "while here" improvements as scope.

Objective:
- <exact outcome in one or two bullets>

Acceptance / stop metrics:
- Codex may stop when <observable outcome is true>.
- Codex may stop when <verification command/search/manual check passes>.
- Codex must not stop merely because code was changed; it must prove the acceptance metrics.
- Codex must not stop until every accepted child goal has evidence that it was created/activated, updated to `complete` or `blocked`, met its child stop metrics if accepted, and the parent agent has personally run final acceptance.
- If Feishu notification is marked required, Codex must not stop until the notification is sent or a concrete notification blocker is recorded.

Repository / module scope:
- Root: <repo root>
- In scope: <paths/modules>
- Out of scope: <paths/modules or kinds of work>

Assumptions:
- <conservative assumption made because the request did not specify it, or "None">

Model execution policy:
- Main session: use the active model and reasoning effort as-is; no model gate or preflight.
- Child discovery, implementation, review, and verification: spawn with `model: gpt-5.6-sol`, `reasoning_effort: xhigh`.
- Child fallback: if a spawn override is rejected or unavailable, record requested model/effort, actual fallback, and reason before accepting the child result.

Feishu notification:
- Notify: none unless the user's original request explicitly asked for completion notification; otherwise <required | optional>
- Recipient: <--chat-id oc_xxx | --user-id ou_xxx | missing; omit when Notify is none>
- Identity: <--as bot | --as user; omit when Notify is none>
- Message content: <omit when Notify is none; otherwise concise mobile summary with status, goal, result, verification, risks/blockers, and next action>
- Command shape:
  ```bash
  lark-cli im +messages-send --as <bot|user> <--chat-id oc_xxx|--user-id ou_xxx> --text $'SuperGoal <complete|blocked>\nGoal: <short goal>\nResult: <summary>\nVerified: <checks>\nRisks: <none or brief>' --idempotency-key "supergoal-<stable-run-id>-<status>"
  ```
- Failure handling: do not send unless Notify is required or optional because the user explicitly asked. If enabled and recipient, identity, auth, scope, or chat membership is missing, do not guess; record the exact blocker. If Notify is required, treat that as a goal blocker. If optional, complete repository acceptance and report that notification was not sent.

SuperDev architecture gate:
- Read root docs/SPEC.md and docs/PLAN.md when present.
- Read relevant module SPEC.md and PLAN.md files before substantial edits.
- Confirm Current Architecture and Target Architecture Mermaid diagrams exist and match the requested direction.
- If target architecture is missing, stale, or inconsistent, update or propose docs before production implementation.

Execution phases:
1. Use the active main session as-is; do not run a parent-model preflight.
2. Translate the request into acceptance metrics and stop conditions.
3. Have the main agent write and own the detailed parent Goal Contract from those metrics.
4. Create or activate the parent goal when goal-mode tools are available.
5. Run a subagent opportunity scan for independent discovery, implementation, and verification slices.
6. Create and launch child subagent Goal Contracts for every independent slice that can run in parallel, passing `model: gpt-5.6-sol` and `reasoning_effort: xhigh` to every spawn call.
7. If no subagent is launched, state the skip reason before continuing.
8. Spawn each subagent with a first message that starts with `Goal:` and contains the full child Goal Contract.
9. Track a small dispatch ledger: subagent, child scope, expected output, requested model/effort, actual model fallback when applicable, child-goal created/active/completed/blocked status, accepted/rejected result.
10. Only after the dispatch gate, inventory current state with focused file/search reads not already delegated.
11. Confirm or repair the SuperDev docs gate.
12. Implement only the smallest local parent-owned work that remains after delegation: integration, glue, conflict resolution, or sequential fallback.
13. Review and integrate or reject subagent outputs.
14. Run focused final verification in the parent agent.
15. Confirm every accepted child goal created/activated its child goal, marked it `complete`, and met its child stop metrics; resolve or record blocked/rejected child outputs.
16. If the user's original request explicitly asked for Feishu notification, send the final status message after verification or record the exact notification blocker.
17. Update SPEC.md / PLAN.md with current architecture, status, next steps, risks, and verification evidence.
18. Close only when parent acceptance metrics, child-goal acceptance, and required notification handling are satisfied.

Subagent dispatch plan:
- Subagent A goal: <read-only discovery, independent verification, or bounded implementation slice>
  - Scope: <files/modules it may inspect or edit>
  - Non-goals: <what it must not touch>
  - Stop condition: <what evidence means this subagent is done>
  - Deliverable: <concise findings, file references, recommendation, or patch summary, plus child-goal lifecycle evidence>
  - Parent merge plan: <how the main agent will use, reject, or verify this output>
  - Spawn parameters: `model: gpt-5.6-sol`, `reasoning_effort: xhigh`
  - Constraint: This subagent must not broaden scope, launch more agents, or decide parent-goal acceptance.
  - Spawn message:
    ```text
    Goal: <same child objective>

    Parent Goal:
    - <parent objective and acceptance metric this child supports>

    Model Execution:
    - This child must be spawned with `model: gpt-5.6-sol` and `reasoning_effort: xhigh`.
    - If the runtime cannot apply either override, report the requested values, actual fallback, and reason before doing work.

    Goal Lifecycle Instruction:
    - Before doing work, create or activate this child goal with the available goal tool, such as `create_goal`.
    - After work, update this child goal to `complete` when Child Acceptance / Stop Metrics are met.
    - If blocked, update this child goal to `blocked` and explain the blocking condition.
    - If goal tools are genuinely unavailable, state that clearly and treat this message as your active child Goal Contract.

    Child Acceptance / Stop Metrics:
    - <what lets this subagent stop>

    Allowed Scope:
    - <files/modules it may inspect or edit>

    Forbidden Work:
    - <what it must not touch>

    Expected Output:
    - <child-goal lifecycle evidence, concise findings, file references, commands/checks, patch summary, risks, and recommended parent action>

    Parent Merge Plan:
    - <how the parent agent will use, verify, or reject this output>
    ```
- Subagent B goal: <another independent slice, or "None: <skip reason>">

Anti-complexity rules:
- Do not introduce new central orchestrators, registries, runners, schemas, CI gates, or package scripts unless explicitly required.
- Do not do broad rewrites, speculative abstractions, or unrelated cleanup.
- Do not move or rename files before inventory proves it is necessary.
- Prefer existing patterns and local helpers.
- Prefer the smallest local implementation that satisfies the acceptance criteria.
- Treat "make it cleaner/elegant/stable" as a requirement for simpler implementation, not permission to redesign unrelated code.
- Keep PLAN.md current-state focused; do not add long command dumps or stale history.

Stop conditions:
- Stop if the target architecture is unclear or conflicts with this goal.
- Stop if scope expands into another durable module.
- Stop if acceptance requires verification that cannot be run.
- Stop if the implementation is becoming larger than the goal justifies.
- Stop before creating a new abstraction or central system not explicitly allowed above.
- Stop if a subagent goal returns evidence that invalidates the main goal or acceptance metrics.
- Stop if subagent outputs conflict and the parent agent cannot resolve them with evidence.

Acceptance criteria:
- <observable completion criterion>
- <doc sync criterion>
- <verification criterion>

Verification evidence:
- Run: <commands/checks/searches>
- Record results in: <PLAN.md path(s)>
- Parent final acceptance: <evidence the main agent must personally verify after subagent work is integrated>
- Feishu notification evidence: <none unless explicitly requested; otherwise message_id/chat_id from real lark-cli send result, dry-run request-shape output only, or blocker reason; dry-run does not prove chat membership>
```

For a SuperGoal behavior validation task, include transcript-level checks:

```text
Goal: Validate that $supergoal behaves as a parent-agent orchestrator

Acceptance / stop metrics:
- The transcript shows the parent agent produced or activated a parent Goal Contract.
- The transcript shows a subagent opportunity scan.
- The transcript shows no main-session model gate, profile-switch request, or model-based pause.
- The transcript shows the parent agent did not begin production implementation before the dispatch gate, except for minimal context reads needed to write child goals.
- At least one spawned subagent first message starts with `Goal:` and includes Parent Goal, Child Acceptance / Stop Metrics, Allowed Scope, Forbidden Work, Expected Output, Parent Merge Plan, and Goal Lifecycle Instruction.
- Every spawned subagent call explicitly uses `model: gpt-5.6-sol` and `reasoning_effort: xhigh`, or records a concrete unsupported-override fallback.
- The subagent transcript shows child `create_goal` or equivalent before work, then `update_goal complete` or `update_goal blocked` before returning.
- If subagent goal tools are unavailable, the subagent or parent records that fallback explicitly and treats that result as lower-confidence evidence.
- The parent agent reviews subagent output and performs final acceptance itself.
- If the user's original request explicitly asked for Feishu notification, the transcript shows notification was attempted only after parent final acceptance or blocked stop condition, and records `message_id`/`chat_id` or the exact notification blocker. If not explicitly requested, transcript shows no Feishu send attempt.

Verification evidence:
- Capture the parent transcript sections that prove each acceptance metric.
- Capture the subagent spawn message(s).
- Capture subagent child-goal lifecycle evidence: created/activated, completed/blocked.
- Capture final parent acceptance or the explicit failure reason.
- Capture Feishu notification evidence or blocker.
```

Keep the final prompt specific. Replace placeholders before handing it to the user or goal mode.
