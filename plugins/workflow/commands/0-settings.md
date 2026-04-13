---
description: View and configure workflow paths. Shows current settings and offers customization.
allowed-tools: Read, Write, Glob, AskUserQuestion
---

## Task

Display current workflow configuration and offer to customize paths.

## Process

### 1. Load Configuration

Invoke the `settings` skill to resolve current paths and check for overrides.

### 2. Display Current Settings

Present the configuration table. See `settings` skill for display template.

### 3. Offer Customization

Ask user if they want to customize, keep current, or reset to defaults.

### 4. Handle User Choice

- **Keep current**: Confirm and exit
- **Customize**: Walk through path options using `settings` skill templates
- **Reset**: Delete override file and confirm

See `settings` skill for all templates, path options, and file formats.
