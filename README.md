# GitHub Action: Run bundler-audit with reviewdog :dog:

[![Test](https://github.com/tomferreira/action-bundler-audit/workflows/Test/badge.svg)](https://github.com/tomferreira/action-bundler-audit/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/tomferreira/action-bundler-audit/workflows/reviewdog/badge.svg)](https://github.com/tomferreira/action-bundler-audit/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/tomferreira/action-bundler-audit/workflows/depup/badge.svg)](https://github.com/tomferreira/action-bundler-audit/actions?query=workflow%3Adepup)
[![release](https://github.com/tomferreira/action-bundler-audit/workflows/release/badge.svg)](https://github.com/tomferreira/action-bundler-audit/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tomferreira/action-bundler-audit?logo=github&sort=semver)](https://github.com/tomferreira/action-bundler-audit/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

![Example comment made by the action, with github-pr-review](/.github/images/example-github-pr-review.png)

This action runs [bundler-audit](https://github.com/rubysec/bundler-audit) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

## Input

### `github_token`

`GITHUB_TOKEN`. Default is `${{ github.token }}`.

### `bundler_audit_version`

Optional. Set bundler-audit version. Possible values:
* empty or omit: install latest version
* `gemfile`: install version from Gemfile (`Gemfile.lock` should be presented, otherwise it will fallback to latest bundler version)
* version (e.g. `1.9.0`): install said version

### `bundler_audit_flags`

Optional. bundler-audit flags. (bundler-audit check --format json `<bundler_audit_flags>`).

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-check`, `github-pr-review`].
The default is `github-pr-check`.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [`added`, `diff_context`, `file`, `nofilter`].
Default is `added`.

### `fail_on_error`

Optional.  Exit code for reviewdog when errors are found [`true`, `false`].
Default is `false`.

### `reviewdog_flags`

Optional. Additional reviewdog flags.

### `workdir`

Optional. The directory from which to look for and run bundler-audit. Default `.`.

## Example usage

```yaml
name: reviewdog
on: [pull_request]
jobs:
  bundler_audit:
    name: runner / bundler_audit
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.0.0
      - name: bundler_audit
        uses: tomferreira/action-bundler-audit@v1
        with:
          bundler_audit_version: gemfile
          # Change reviewdog reporter if you need [github-check,github-pr-review,github-pr-check].
          reporter: github-pr-review
```
