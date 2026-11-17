/**
 * Confirm before common destructive Git operations issued through Pi's bash tool.
 *
 * This is only protection against accidental damage, not a security boundary.
 * It inspects command text and cannot reliably understand every shell construct
 * or invocation of Git through scripts, aliases, or other tools.
 */

import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const GIT_PREFIX = String.raw`\bgit(?:\s+-C\s+(?:"[^"]*"|'[^']*'|\S+))*\s+`;

function findRiskyGitOperations(command: string): string[] {
	const risks = new Set<string>();

	// Look at common shell command segments so a risky command in a chain is still checked.
	// This is intentionally a small text check, not a shell parser.
	for (const segment of command.split(/&&|\|\||[;|\n]/)) {
		const matchGit = (subcommand: string): RegExpExecArray | null =>
			new RegExp(`${GIT_PREFIX}${subcommand}\\b(.*)`).exec(segment);

		const reset = matchGit("reset");
		if (reset && /(?:^|\s)--hard(?:\s|$)/.test(reset[1])) {
			risks.add("git reset --hard discards working-tree and index changes");
		}

		const clean = matchGit("clean");
		if (clean) {
			const options = clean[1].split(/\s+--\s+/)[0];
			const forced = /(?:^|\s)--force(?:\s|=|$)|(?:^|\s)-[a-z]*f[a-z]*(?:\s|$)/.test(options);
			const dryRun = /(?:^|\s)--dry-run(?:\s|$)|(?:^|\s)-[a-z]*n[a-z]*(?:\s|$)/.test(options);
			if (forced && !dryRun) {
				risks.add("forced git clean deletes untracked files");
			}
		}

		const checkout = matchGit("checkout");
		if (checkout && /(?:^|\s)--(?:\s|$)/.test(checkout[1])) {
			risks.add("git checkout -- <paths> discards changes to those paths");
		}

		const restore = matchGit("restore");
		if (restore) {
			const options = restore[1].split(/\s+--\s+/)[0];
			const stagedOnly = /(?:^|\s)--staged(?:\s|$)/.test(options) && !/(?:^|\s)--worktree(?:\s|$)/.test(options);
			if (!stagedOnly) {
				risks.add("git restore can discard working-tree changes");
			}
		}

		const push = matchGit("push");
		if (push && /(?:^|\s)--force(?:\b|-with-lease(?:=|\b))|(?:^|\s)-f(?:\s|$)/.test(push[1])) {
			risks.add("force-pushing can overwrite remote branch history");
		}
	}

	return [...risks];
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (!isToolCallEventType("bash", event)) return;

		const risks = findRiskyGitOperations(event.input.command);
		if (risks.length === 0) return;

		if (!ctx.hasUI) {
			return {
				block: true,
				reason: `Risky Git operation requires confirmation, but no UI is available: ${risks.join("; ")}`,
			};
		}

		const confirmed = await ctx.ui.confirm(
			"Confirm risky Git operation",
			`${risks.map((risk) => `• ${risk}`).join("\n")}\n\nWorking directory: ${ctx.cwd}\n\nCommand:\n${event.input.command}`,
		);

		if (!confirmed) {
			return { block: true, reason: "Risky Git operation cancelled by user" };
		}
	});
}
