# GitHub Actions Workflows

Reusable GitHub Action workflows for CNCSC and member projects.

Runs on `ubuntu` and `macos`.

## Usage

### Validation Workflow

Runs `pre-commit` validation and executes the projects `lint` script from `package.json`.
This below example also runs `npm run test` and `npm run e2e`.

`npmTestScripts` is a space delimited string.

```yaml
jobs:
  ci:
    name: Validation
    uses: cncsc/actions/.github/workflows/validation.yaml@main
    with:
      runPreCommit: true # optional
      runDefaultLinters: true # optional
      additionalHomebrewPackages: tflint tfsec # optional
      npmTestScripts: test e2e # optional
```

### Semantic Release Workflow

```yaml
jobs:
  cd:
    name: Release
    uses: cncsc/actions/.github/workflows/semantic-release.yaml@main
    secrets:
      GIT_TOKEN_BASIC: ${{ secrets.GIT_TOKEN_BASIC }} # required
      NPM_ACCESS_TOKEN: ${{ secrets.NPM_ACCESS_TOKEN }} # optional
```

Note that `NPM_ACCESS_TOKEN` is required when accessing private packages and/or publishing packages.
