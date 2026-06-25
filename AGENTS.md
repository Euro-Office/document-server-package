# document-server-package — Euro-Office Distribution & Packaging

@../AGENTS.md

Guidance for Claude Code (and other AI agents) working in **document-server-package** — multi-platform release installer generation.

## What this repo is
A release-only repository housing build scripts, definitions, and compilation workflows for producing DEB, RPM, Windows EXE (Inno Setup), and static TAR archives.

## M4 Macro Architecture & Bundled Dependencies
- **M4 Macro Templating:** Branding strings, corporate identities, and file system installation paths are dynamically injected via M4 macro placeholders expanded at compile time. 
    - **CRITICAL:** Do NOT hardcode `euro-office` or any explicit paths. Use M4 macros mapped directly to the DocumentServer `build/docker-bake.hcl` configuration.
- **Windows Dependency Bundling:** The Inno Setup configuration (`exe/*.iss`) pins and auto-downloads prerequisite binaries (PostgreSQL, Redis, RabbitMQ, Erlang, OpenSSL). 
    - **CRITICAL FAIL MODE:** Upgrading a dependency version requires updating its binary download URL AND calculating its new SHA checksum. Failing to update hashes breaks the offline installation verification pass.
- **Systemd Definitions:** Linux services (`ds-docservice`, `ds-converter`, `ds-metrics`) live as templated components in `common/` and must pass M4 validation.

## Rules
- **Never** commit distribution artifacts (`*.deb`, `*.rpm`, `*.exe`, `*.tar.gz`) to this repository; they are strictly CI/CD output assets.
- **Never** modify bundled Windows binaries without validating network reachability of the download endpoint and cross-checking the installer compilation logs.
- **Never** perform daily logic development here. This repository is strictly for distribution and packaging engineering during release cycles.

## Findings & Long-tail
No centralized findings store exists in this repository yet. Document edge cases in code comments or GitHub issues until one is established.