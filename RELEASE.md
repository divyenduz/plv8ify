# Release Process

PLV8ify uses [Changesets](https://github.com/changesets/changesets) for versioning, changelog generation, and npm publishing. Releases are automated via GitHub Actions with two manual touchpoints: **creating a changeset** and **merging the release PR**.

## Step-by-step

### 1. Create a changeset

When your feature or fix is ready, run:

```bash
bun run changeset
```

This prompts you for a bump type (`patch`, `minor`, or `major`) and a summary. It creates a markdown file under `.changeset/` (e.g., `.changeset/angry-berries-sneeze.md`):

```markdown
---
'plv8ify': patch
---

Fix the release CI via OIDC approach
```

Commit this file alongside your code changes.

### 2. Push / merge to `main`

Once your PR (with the changeset file) merges into `main`, two GitHub Actions workflows run:

- **Test** (`test.yml`) — type-checks (`tsc --noEmit`) and runs `bun test`.
- **Release** (`release.yml`) — builds the project and runs `changesets/action`.

### 3. Review the "Version Packages" PR

If there are pending changeset files, the Changesets bot automatically opens (or updates) a **"Version Packages"** PR that:

- Bumps the `version` in `package.json`
- Prepends new entries to `CHANGELOG.md`
- Deletes the consumed `.changeset/*.md` files

### 4. Merge the release PR → publish to npm

When you merge the "Version Packages" PR into `main`, the Release workflow runs again. This time there are no pending changesets, so it executes:

```bash
npx changeset publish
```

This publishes `plv8ify` to npm as a **public** package using **GitHub OIDC** for authentication (no `NPM_TOKEN` secret needed) and creates a git tag for the release.

## Flow overview

```
Developer creates changeset
        ↓
PR merges to main
        ↓
Changesets bot opens "Version Packages" PR
  (bumps version, updates CHANGELOG, removes changeset files)
        ↓
Maintainer merges the release PR
        ↓
GitHub Actions runs `npx changeset publish`
        ↓
plv8ify@x.y.z is live on npm 🎉
```

## Local scripts

| Script | Command | Purpose |
| ------ | ------- | ------- |
| `bun run changeset` | `bun x changeset` | Create a new changeset |
| `bun run version` | `bun x changeset version` | Apply changesets locally (bump version + changelog) |
| `bun run release` | `bun run build && bun x changeset publish` | Build and publish manually (requires local npm auth) |

## Configuration

Changeset config lives in [`.changeset/config.json`](.changeset/config.json):

- **`access: "public"`** — published as a public npm package
- **`commit: false`** — version bumps go through a PR, not auto-committed
- **`baseBranch: "main"`** — all releases are relative to `main`
- **`changelog: "@changesets/cli/changelog"`** — default changelog format (commit SHA + description)
