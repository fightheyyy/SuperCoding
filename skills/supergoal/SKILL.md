---
name: supergoal
description: >-
  Use when a user wants to optimize, rewrite, compile, start, execute,
  verify, evaluate, or forward-test a Codex goal-mode task or skill for
  repository work, especially broad changes, refactors, cleanup, migrations,
  stability work, or long-running tasks. Turn rough requirements into
  acceptance-first orchestration: define stop metrics, make the main Codex
  agent write and own the parent goal, require a subagent dispatch gate before
  implementation, and spawn bounded child Goal Contracts for independent
  discovery, implementation, or verification slices. Subagents must
  create/activate their child goals before work and mark them complete or
  blocked before returning; the parent owns scope, merge, final verification,
  acceptance, and explicitly requested Feishu completion notification via
  lark-cli. Only return a pasteable prompt when explicitly asked for
  prompt-writing without execution. Keep non-goals, anti-complexity rules,
  verification, and SuperDev SPEC.md / PLAN.md discipline explicit.
---

# SuperGoal

SuperGoal is an acceptance-first parent-agent orchestrator for SuperDev repositories. Use it before and during long-running Codex goals to convert a user's natural-language intent into stop conditions, a detailed parent Goal Contract owned by the main Codex agent, and bounded child Goal Contracts for subagents. The parent agent writes the goals, dispatches subagents, integrates their output, performs final acceptance, and can send a Feishu completion notification only when the user's original request explicitly asked for it. Subagents create or activate their assigned child goal before work, execute only that child goal, then mark it complete or blocked before returning. SuperGoal can also compile pasteable prompts, but only when the user explicitly asks for prompt-writing instead of execution.

## Core Behavior

Before substantial repository work, draft a Goal Contract internally. Output that contract as the final artifact only in compile-only mode. Do not treat the user's raw natural-language request as the execution plan when it is broad, emotional, ambiguous, example-heavy, or multi-module.

Start from acceptance, not activity:

- Translate what the user wants into observable stop conditions before deciding what Codex should do.
- Treat the user's request as "what must be true when the goal stops", not as a list of implementation steps to obey blindly.
- If the user provides tactics, examples, or complaints, preserve them as context only when they help define acceptance.
- Make Codex write the detailed main goal from those acceptance criteria instead of merely expanding the user's wording.
- In execution mode, the main Codex agent must act as the orchestrator before it acts as an implementer: write the parent goal, scan for child work, dispatch subagents with bounded child goals, collect their results, decide merges, and verify final acceptance.
- Subagents are workers, not co-owners of the goal. They must create or activate the child goal written by the parent agent before work, execute that child goal, then call the goal completion mechanism with `complete` or `blocked` before returning concise evidence, findings, or bounded patches. They do not redefine the parent scope, decide final completion, or create new subagent work.
- In compile-only mode, write the parent-agent orchestration instructions and child subagent goals into the prompt instead.

Use the SuperDev skill as the architecture gate when available. SuperGoal does not replace SuperDev; it narrows the goal so SuperDev can be applied cleanly.

During execution, keep the contract alive:

- Re-check scope before each phase.
- Update relevant `SPEC.md` and `PLAN.md` as architecture or execution state changes.
- Prefer the smallest implementation that satisfies the contract.
- Stop when the target architecture is unclear, scope expands materially, or acceptance cannot be verified.

## Explicit Invocation Rule

When the user explicitly invokes `$supergoal`, do not answer as ordinary advice. Produce or use a `Goal:` contract.

For explicit `$supergoal` invocation:

- If the user asks Codex to do, verify, test, inspect, implement, fix, refactor, or run something, start/update the parent goal when goal tools are available and execute.
- If the user asks "how to verify", "how should I test", "write/optimize/compile a goal", "make this stable for goal mode", or asks for a plan without asking Codex to run it, output a visible pasteable `Goal:` contract. Do not return only bullets or generic suggestions.
- If the user asks a pure conceptual question and clearly does not want a goal, answer briefly, but include a one-line note that no goal was started because the user asked for explanation only.
- A valid `$supergoal` response must contain one of these signals: a created/updated parent goal, a pasteable `Goal:` block, or an explicit no-goal reason.

For skill verification requests, compile a validation goal instead of giving loose advice. The validation goal should define transcript-level acceptance, including whether the parent agent wrote a parent goal, whether subagent spawn messages started with `Goal:`, whether subagents received child Goal Contracts, whether subagents created/activated and completed/blocked their child goals, whether fallback was recorded when goal tools were unavailable, and whether the parent agent performed final acceptance.

## Orchestrator-First Contract

In execution mode, the parent agent's default job is "define, dispatch, integrate, verify", not "implement the request directly". Treat direct implementation by the parent as an exception that must be justified by the dispatch gate.

Before production edits or broad local implementation, the parent agent must complete the dispatch gate:

1. Write or activate the parent Goal Contract with observable acceptance and stop metrics.
2. Scan for independent discovery, implementation, and verification slices.
3. For every independent slice that can run safely, write a child Goal Contract and launch it when subagent tools are available.
4. Require each subagent to create or activate its child goal before work and update that child goal to `complete` or `blocked` before returning.
5. Record a dispatch ledger with each child goal, scope, expected output, goal-tool lifecycle status, and acceptance status.

Only after the dispatch gate may the parent agent implement locally, and then only for:

- Integration, glue, or conflict resolution after child outputs return.
- Non-overlapping parent work that cannot be delegated, such as final merge decisions, final verification, or user-facing closeout.
- A sequential fallback when goal or subagent tools are unavailable, no independent slice exists after scanning, write scopes would conflict unsafely, or the user explicitly requested solo work.

Do not skip subagents merely because the task feels small. Read-only reconnaissance, independent verification, test strategy, risky-file inventory, and UI/manual smoke checks all count as valid subagent slices. If the parent does not launch a subagent, it must name the concrete skip reason before implementation.

## Main-Session and Child-Model Policy

Use this runtime policy for every SuperGoal execution-mode run:

- Run all parent-agent work with the model and reasoning effort already active in the main Codex session.
- Never inspect, request, require, verify, or switch the main-session model or reasoning level. Do not pause, block, downgrade, or add fallback ceremony because the host does not expose parent-model controls.
- Spawn every child agent that performs discovery, implementation, review, or verification with the explicit overrides `model: gpt-5.6-sol` and `reasoning_effort: xhigh`. Treat `xhigh` as the tool value for the user's "extra high" requirement; do not pass `extrahigh`, which is not a valid spawn value.
- Do not omit child model parameters and silently inherit the parent model. If the runtime rejects or does not support an override, record the requested model, requested effort, actual fallback, and reason in the dispatch ledger before accepting the child's evidence.
- Do not delegate parent goal design merely to obtain a different model. The main agent still owns task analysis, the parent Goal Contract, dispatch, integration, and acceptance.

## Parent-Agent Orchestration Model

The main Codex agent owns the run. It must not delegate goal design, scope control, merge decisions, or final acceptance to subagents.

Parent agent responsibilities:

- Translate the user request into acceptance metrics and a detailed parent Goal Contract.
- Decide which independent slices should become child Goal Contracts.
- Dispatch subagents with explicit purpose, allowed files/modules, forbidden work, stop condition, expected output, and merge plan.
- Avoid doing subagentable work locally before the dispatch gate; convert that work into child goals first.
- Keep a small dispatch ledger: subagent name/purpose, scope, expected output, requested model/effort, actual model fallback when applicable, whether the child goal was created/active/completed/blocked, and whether its result was accepted, rejected, or needs follow-up.
- Continue non-overlapping parent work while subagents run when safe.
- Review subagent outputs before using them; do not accept subagent conclusions without evidence.
- Integrate or reject patches/findings, then run the final verification suite itself.
- Send the Feishu completion notification only when the user's original request explicitly asked for completion notification and the notification target is configured.
- Decide whether the parent goal is complete. Subagent completion is not parent-goal completion.

Subagent responsibilities:

- Execute only the child Goal Contract assigned by the parent agent.
- Before any child work, create or activate the child goal with the available goal tool, such as `create_goal`, using the assigned child objective.
- Stay inside the allowed files/modules and forbidden-work boundaries.
- Stop when the child stop condition is satisfied or blocked.
- Before returning, update the child goal status to `complete` when child acceptance is met, or `blocked` when the child cannot proceed under its stop conditions.
- Return concise evidence: file references, commands/checks, findings, risks, patch summary, and recommended parent action.
- Do not broaden scope, rewrite the parent goal, launch additional agents, perform unrelated cleanup, or claim final acceptance for the parent goal.

## Subagent Goal Lifecycle Protocol

When the parent agent launches a subagent, the first message to that subagent must be a child goal lifecycle message, not a loose task request. Start the message with `Goal:` and include a complete child Goal Contract.

Each spawned subagent message must include:

- `Goal:` one concrete child objective.
- `Parent Goal:` the parent objective and acceptance metrics this child supports.
- `Child Acceptance / Stop Metrics:` what lets the subagent stop.
- `Allowed Scope:` files/modules the subagent may inspect or edit.
- `Forbidden Work:` files/modules/behaviors the subagent must not touch.
- `Expected Output:` exact deliverable format.
- `Parent Merge Plan:` how the parent will use or reject the result.
- `Model Execution:` require the spawn call to use `model: gpt-5.6-sol` and `reasoning_effort: xhigh`, and require any unsupported-override fallback to be reported.
- `Goal Lifecycle Instruction:` "Before doing work, use the available goal tool such as `create_goal` to create or activate this child goal. After work, use the goal completion tool such as `update_goal` to mark the child goal `complete` when child acceptance is met, or `blocked` when the child cannot proceed under its stop conditions. If goal tools are genuinely unavailable, state that clearly, treat this message as the active child Goal Contract, and return fallback evidence."

Do not spawn a subagent with only "investigate X", "help with Y", or a paragraph of context. If the subagent tool has no dedicated goal-mode parameter, the parent must still pass the child Goal Contract in the spawn message and explicitly require the subagent to run its child-goal lifecycle. If the subagent reports that goal tools are unavailable, that is an acceptable fallback only when explicit; the parent must record it in the dispatch ledger and treat that child result as lower-confidence evidence.

## Feishu Completion Notification

Use Feishu notification only when the user's original request explicitly asks for it, such as "完成后通知我", "飞书通知我", "发飞书给我", or "notify me". Do not send messages by default. Do not infer notification from the existence of a configured chat, previous conversation context, or a notification target alone.

Notification ownership:

- Only the parent agent sends completion notifications. Subagents must not send user-facing Feishu messages.
- Send after parent final acceptance, after a blocked stop condition is reached, or after the parent decides the goal cannot safely continue.
- Do not send before final verification just because a subagent reports success.
- If the user explicitly requested Feishu notification as an acceptance requirement, the parent goal is not fully complete until the notification is sent or a clear notification blocker is recorded.
- If notification is optional or "when possible", repository acceptance may complete even when notification fails, but the final response must state the notification failure reason.

Notification target requirements:

- Require one recipient: `--chat-id oc_xxx` for a group/chat or `--user-id ou_xxx` for a direct message.
- Require one identity: prefer `--as bot` for automation; use `--as user` only when the user explicitly wants their own identity and user auth is ready.
- If no recipient is provided, do not guess. Record `Feishu notification not sent: missing --chat-id/--user-id`.
- If `lark-cli` is unavailable, auth is missing, required scopes are missing, or the bot is not in the target chat, record the blocker and include the exact command or auth step needed.

Notification content:

- Keep it concise and useful on mobile: status, goal summary, changed files or produced artifacts, verification result, risks/blockers, and next action.
- Never include secrets, API keys, tokens, private credentials, or long logs.
- Prefer plain text with `--text` to preserve exact formatting.
- Use an idempotency key so retries do not duplicate completion messages.

Preferred command shape:

```bash
lark-cli im +messages-send --as bot --chat-id oc_xxx --text $'SuperGoal complete\nGoal: <short goal>\nResult: <summary>\nVerified: <checks>\nRisks: <none or brief>' --idempotency-key "supergoal-<stable-run-id>-<status>"
```

For a direct message, use `--user-id ou_xxx` instead of `--chat-id oc_xxx`. Use `--dry-run` only to validate request shape; it does not prove bot/user membership in the target chat. The real final notification must omit `--dry-run`.

## Mode Selection

Within a SuperGoal-triggered goal-mode request, default to execution when the user asks Codex to do, build, fix, implement, refactor, clean, migrate, verify, or otherwise perform repository work. Do not stop after drafting a prompt in those cases.

Use compile-only mode when the user explicitly asks to write, optimize, rewrite, or compile a prompt for later use, or when the user asks how to verify/evaluate/test a goal or skill without asking Codex to run the verification. Compile-only mode must still output a pasteable `Goal:` contract, not generic advice.

If intent is mixed, prefer execution and keep the compiled Goal Contract internal. Mention the goal contract briefly, then start the work.

## Goal Execution Mode

When the user asks Codex to actually do the work, create or activate the goal and continue execution instead of returning a text prompt as the final artifact.

Use the active main session as-is. Child spawn overrides remain `gpt-5.6-sol` with `xhigh` when the spawn surface supports them.

Execute in this order:

1. Draft observable acceptance metrics and stop conditions.
2. Write a detailed parent Goal Contract from those metrics.
3. Use the available goal-mode mechanism to start or update the parent goal, such as `create_goal` when that tool exists in the environment.
4. Run a subagent opportunity scan and create a dispatch plan. Look for independent codebase reconnaissance, risky-file inventory, implementation slices with disjoint write sets, test strategy, regression search, release/docs checks, or UI verification.
5. Complete the dispatch gate before implementation. If subagent tools are available and the scan finds at least one independent slice, the parent agent launches subagents before starting local implementation. Each spawn message must follow the Subagent Goal Lifecycle Protocol: start with `Goal:`, include the child Goal Contract, require the subagent to create/activate that child goal before work and mark it `complete` or `blocked` before returning, and use `model: gpt-5.6-sol` with `reasoning_effort: xhigh` in the spawn call.
6. If no subagent is launched, state the reason briefly: no tool, no independent slice after scanning, unsafe write overlap, or user explicitly requested solo work. A small feature is not by itself a valid skip reason when read-only reconnaissance or independent verification would help.
7. Continue the parent task while subagents run when there is non-overlapping work to do.
8. The parent agent reviews subagent findings or patches, accepts/rejects/integrates them, updates the dispatch ledger, then runs final verification itself.
9. If the user's original request explicitly asked for Feishu notification, send the final status message with `lark-cli im +messages-send` after final verification or after a blocked stop condition is reached.
10. Stop only when the parent acceptance metrics are met, every accepted child goal has evidence of child-goal lifecycle completion and has met its child stop metrics, rejected or blocked child outputs have been resolved or recorded, the parent has personally verified final acceptance, and required notification has either been sent or recorded as blocked.

If goal tools or subagent tools are unavailable, say so briefly and continue with the closest safe fallback. Do not pretend a goal or subagent was started.

## Shared Goal Drafting Rules

Use these rules in both execution and compile-only mode. In execution mode, apply them internally before starting or updating the goal. In compile-only mode, turn them into a directly pasteable goal-mode prompt.

Compile the request in this order:

1. Extract acceptance and stop conditions.
   - Convert the request into "Codex may stop when..." statements before writing task steps.
   - Define observable success: behavior, files, UI states, tests, docs, performance, or absence of regressions.
   - Convert vague quality words such as "clean", "stable", "simple", "elegant", "not messy", or "less shit-code" into measurable acceptance criteria and anti-complexity rules.
   - If acceptance is underspecified, infer conservative checks and mark them as assumptions.

2. Extract the core outcome.
   - Treat complaints, background, examples, and possible approaches as context, not automatic scope.
   - Preserve only the outcome that must be true when the goal finishes.
   - If the request contains several independent outcomes, split them into ordered phases and recommend starting with phase 1.

3. Make Codex write the detailed main goal.
   - The compiled prompt should instruct Codex to formulate a precise main goal from the acceptance criteria before editing code.
   - The main goal must include objective, repository/module boundaries, in-scope work, non-goals, assumptions, implementation constraints, stop conditions, acceptance criteria, and verification evidence.
   - The main goal should state what to prove, not just what to change.

4. Bound the work.
   - Name the repository root when known.
   - Name the few paths, modules, or behavior surfaces that are in scope.
   - Make nearby tempting work explicit non-goals.

5. Add implementation constraints.
   - Prefer local edits and existing patterns.
   - Forbid speculative abstractions, broad rewrites, new central systems, registries, runners, schemas, CI gates, package scripts, or framework creation unless the user explicitly requested them.
   - Require proof before moving, renaming, deleting, or consolidating files.
   - Require stop-and-ask behavior when scope expands or verification cannot prove acceptance.

6. Add a parent-owned subagent dispatch plan by default whenever any independent slice exists.
   - In execution mode, actively search for subagentable slices before implementation; do not wait until the work feels large.
   - Treat the dispatch gate as mandatory before local implementation. The parent may inspect enough context to write safe child goals, but should not solve subagentable work locally first.
   - Use subagents for independent slices: codebase reconnaissance, alternative implementation options, risky-file inventory, test strategy, regression search, UI/manual verification, docs/release checks, or isolated module work with a disjoint write set.
   - Each subagent must receive its own child Goal Contract written by the parent agent: purpose, allowed files/modules, forbidden work, stop condition, expected output, and how its findings will be merged into the parent goal.
   - The child Goal Contract must be placed directly in the subagent spawn message. Do not merely list child goals in the parent plan.
   - Spawn every child with explicit `model: gpt-5.6-sol` and `reasoning_effort: xhigh` overrides. Record any runtime rejection or fallback in the dispatch ledger.
   - The spawn message must explicitly tell the subagent to create or activate the child goal before work, then update the child goal to `complete` or `blocked` before returning. Fallback to treating the contract as the active execution boundary is allowed only when the subagent explicitly reports that goal tools are unavailable.
   - Prefer read-only scout subagents unless implementation work is explicitly assigned to a bounded path.
   - Prefer multiple small subagent goals over one broad "investigate this" goal when the questions are independent.
   - Do not ask subagents to "help broadly"; give them concrete child acceptance criteria and require concise evidence.
   - Tell subagents not to broaden scope, launch more agents, or decide parent-goal completion.
   - Require the parent agent to review every subagent result and run final verification itself.

7. Add verification.
   - Include focused checks that match the goal: tests, type checks, lint, build, smoke tests, targeted searches, or manual verification.
   - Require evidence to be recorded in relevant `PLAN.md` files when SuperDev docs exist.

When compile-only mode is requested, the compiled prompt should be opinionated, narrow, and easy to paste into Codex goal mode. It should not be a motivational essay or a long project plan.

## Compile-Only Mode

Use compile-only mode only when the user explicitly asks to "write a goal", "optimize this prompt", "turn this into a Codex goal", "make this stable for goal mode", or similar for later use. Do not execute repository changes in compile-only mode.

Compile-only output must begin with a `Goal:` block. A list of recommendations without a `Goal:` block is a failure when `$supergoal` was invoked.

## Goal Contract

For broad tasks, first draft a compact contract with these fields. If the user only asked for a goal prompt, output the contract as the final artifact. If the user asked you to execute, use the contract to start or update the active goal, then proceed.

- `Objective`: one sentence describing the exact outcome.
- `Acceptance / Stop Metrics`: the observable conditions that tell Codex the goal is done.
- `Repository / Modules`: the root and module boundaries affected.
- `In Scope`: the few concrete changes allowed.
- `Non-Goals`: nearby work that must not be done in this run.
- `Assumptions`: conservative assumptions made because the request did not specify something.
- `SuperDev Docs`: root and module `SPEC.md` / `PLAN.md` files that must be read or updated.
- `Architecture Gate`: what must be true before production code changes begin.
- `Runtime Policy`: use the active main session without a model gate; request `gpt-5.6-sol` with `xhigh` only for child spawns and record child-only fallback evidence when unsupported.
- `Execution Phases`: inventory, docs gate, implementation, verification, doc sync, closeout.
- `Anti-Complexity Rules`: constraints that prevent broad rewrites, new central systems, speculative abstractions, or accidental framework creation.
- `Stop Conditions`: conditions that require pausing for user input instead of improvising.
- `Acceptance Criteria`: observable completion requirements.
- `Verification Evidence`: checks to run and where results must be recorded.
- `Feishu Notification`: default `none`; set to `required` or `optional` only when the user's original request explicitly asks for completion notification. Include recipient `--chat-id` or `--user-id`, sending identity, message summary, idempotency key, and failure handling only when enabled.
- `Subagent Dispatch Plan`: bounded child goals for parallel subagents when any independent slice exists; otherwise include the specific skip reason. Do not mark this optional in execution mode. State that the parent agent owns dispatch, merge, and final acceptance.
- `Subagent Spawn Messages`: exact first messages the parent will send to subagents. Each must start with `Goal:` and include child acceptance, allowed scope, forbidden work, expected output, parent merge plan, and the child-goal lifecycle instruction requiring `create_goal` before work and `update_goal complete/blocked` before returning.

For a reusable template, read `references/goal-contract-template.md`.

## Workflow

1. Parse the user's natural language into a narrow outcome.
   - Separate desired outcome from examples, complaints, historical context, and optional ideas.
   - First write the acceptance/stop metrics: what Codex must prove before it is allowed to stop.
   - Convert vague verbs such as "clean up", "slim", "make stable", "fix the architecture", or "make it elegant" into concrete scope, non-goals, and acceptance criteria.
   - Do not promote "while here" ideas into scope.
   - If the request has multiple independent outcomes, split it into ordered phases and recommend starting with the smallest phase.

2. Draft the main goal.
   - Make the main goal detailed enough that another Codex run can execute it without reading the prior conversation.
   - Prefer acceptance-driven phrasing: "Stop when X is true and verified", not "Do these steps".
   - Include explicit proof requirements before allowing file moves, abstractions, or broad cleanup.
   - In execution mode, start or update the active parent goal after drafting this contract when goal tools are available.
   - Use the active main session as-is; do not add a parent-model preflight or model-based stop condition.

3. Scan for and launch parent-owned subagent goals before implementation when parallelism is safe.
   - Treat subagents as the default for any independent discovery, verification, or disjoint implementation slice.
   - Use subagents only when their outputs can be merged cleanly.
   - Give each subagent its own child Goal Contract with scope, forbidden areas, stop condition, and required evidence.
   - Spawn each subagent with the full child Goal Contract as the first message; do not rely on the parent plan alone.
   - Pass `model: gpt-5.6-sol` and `reasoning_effort: xhigh` in every child spawn call; do not rely on inherited defaults.
   - Tell subagents to return findings, file references, and recommended next action, not broad essays.
   - Tell subagents that the parent agent owns the main goal, merge decision, and final acceptance.
   - Tell subagents to create or activate their child goal before work, then update it to `complete` or `blocked` before returning. If no goal tools are available, they must report that fallback clearly.
   - In execution mode, launch available subagent tools for those goals instead of only listing them.
   - If no subagent is launched, state the skip reason briefly before continuing.

4. Establish the SuperDev gate.
   - Identify whether the request touches repository-wide behavior, one durable module, or multiple modules.
   - Read root `docs/SPEC.md` and `docs/PLAN.md` when present.
   - Read relevant module `SPEC.md` and `PLAN.md` files when present.
   - Confirm each relevant `SPEC.md` has truthful `Current Architecture` and clear `Target Architecture` Mermaid diagrams.
   - If the target architecture is missing, stale, or inconsistent with the request, update or propose the docs before production implementation.

5. Keep implementation narrow.
   - Follow existing repo patterns unless the contract explicitly authorizes a change.
   - Prefer local edits over new abstractions.
   - Avoid creating new orchestrators, registries, runners, schemas, CI gates, or package scripts unless they are named in scope.
   - Do not move files, rename concepts, or delete historical artifacts before inventory proves they belong to the current objective.
   - Treat "while here" improvements as out of scope unless required for acceptance.

6. Maintain SuperDev docs while the goal runs.
   - If implementation changes architecture, update the relevant `Current Architecture`.
   - If the intended direction changes, update `Target Architecture`.
   - If `SPEC.md` adds or removes concepts, boundaries, phases, files, contracts, or ownership, update `PLAN.md`.
   - If a milestone becomes complete, record only current status and recent effective verification in `PLAN.md`.
   - Do not let `PLAN.md` become a command dump or long historical log; git carries old history.

7. Verify and close.
   - Run focused tests, type checks, lint, schema validation, or searches that match the contract.
   - Record verification evidence in the relevant `PLAN.md` when the change is substantial.
   - If the user's original request explicitly asked for Feishu notification, send the final status through `lark-cli im +messages-send` after verification or record the notification blocker.
   - Final response should summarize what changed, what was verified, and any remaining risks or stop conditions encountered.

## Stop Conditions

Pause and ask or propose a doc update before continuing when:

- The requested goal conflicts with the current `Target Architecture`.
- The relevant `SPEC.md` lacks a clear target Mermaid diagram.
- The work would require a new central system not named in the contract.
- The scope expands into another durable module.
- Verification cannot be run or cannot prove the acceptance criteria.
- The implementation would become larger than the contract justifies.

## Output Style

When asked to execute repository work, do not merely return a prompt. Start or update the parent goal, act as the parent-agent orchestrator, launch bounded subagents for independent slices when available, then proceed. Keep the contract concise in user updates.

When subagent tools are available, do a subagent opportunity scan and launch at least one bounded subagent for any independent slice before implementation. Read-only reconnaissance and independent verification count as independent slices. If none is launched, name the skip reason before implementation. Subagents execute parent-written child goals through a full child-goal lifecycle: create/activate before work, then update to `complete` or `blocked` before returning. The parent agent integrates results and owns final acceptance.

When Feishu notification is explicitly requested and configured, make it the final parent-owned side effect after verification. Do not let subagents notify the user. Do not send if the recipient or identity is missing; report the exact missing configuration.

When asked to "write a goal" or "optimize a prompt" for later use, produce a concise goal-mode prompt with the Goal Contract embedded. Make it directly pasteable into Codex goal mode. Include at most a short note after it if assumptions or unresolved inputs matter.

When tools required for true goal or subagent startup are unavailable, say that plainly and continue with the closest safe sequential execution path. Do not bury the user in process text.

Use direct language. The point is stable execution, not ceremony.
