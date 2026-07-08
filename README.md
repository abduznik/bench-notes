# bench-notes

A personal digital garden. This is a notes log, not a polished blog. Written primarily for my own future reference — war stories, debugging notes, cross-domain pattern spotting, and small project writeups. If anyone else finds something useful here, that's a bonus.

## Folder Structure

- **rf/** — RF electronics, instrument debugging, GPIB/SCPI notes, hardware war stories
- **software/** — General software debugging, language notes, tooling, build systems
- **cross-domain/** — Notes connecting patterns across two or more unrelated areas (e.g. seeing the same bug shape in RF calibration and Python async code)
- **projects/** — Short writeups linking to standalone repos (luhn-polyglot, etc.)
- **_templates/** — Note template for creating new entries

## Publishing

This repo is published to GitHub Pages via [Quartz](https://quartz.jzhao.xyz). The Quartz source lives in `quartz/` and the content folders above are mapped into it.

## How to Add a Note

1. Copy `_templates/note-template.md` to the appropriate folder
2. Rename it to something descriptive (e.g. `rf/2026-07-scpi-timeout-debug.md`)
3. Fill in the frontmatter:
   - `title` — short descriptive title
   - `date` — creation date (YYYY-MM-DD)
   - `tags` — relevant tags
   - `domain` — rf / software / cross-domain / projects
   - `status` — seedling, growing, or evergreen
4. Write the note. Plain markdown, no special formatting required.
5. Add wikilinks `[[other-note]]` to connect related notes.
