# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-10-10

- Aligned CI Ruby matrix to 3.1/3.2/3.3/3.4 (matches gemspec `required_ruby_version >= 3.1`).
- Bumped `actions/checkout` to v7 in CI.
- Ignored local `vendor/bundle` / `.bundle` paths in `.gitignore`.

## [1.0.1] - 2026-10-10

- Relicensed public surface under Elastic License 2.0 (ELv2).
- Raised required Ruby version from `>= 2.7` to `>= 3.1`.
- Added Dependabot for Bundler and GitHub Actions.

## [1.0.0] - 2026-04-06

- Initial public SDK surface with repository documentation kit.
