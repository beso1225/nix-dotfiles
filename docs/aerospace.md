# AeroSpace external-monitor automation

This repository contains a chezmoi source subtree for an AeroSpace setup that
starts only when macOS reports an active non-built-in display.

## Installation

Review the rendered diff before applying it:

```sh
chezmoi --source /path/to/nix-dotfiles/chezmoi diff
chezmoi --source /path/to/nix-dotfiles/chezmoi apply
```

The shell scripts use chezmoi's `executable_` source prefix so that the
materialized files retain mode 755. Run them as the logged-in user; do not use
`sudo`, because AeroSpace and Chrome require the user's GUI session, HOME, and
Automation permissions.

The current machine uses a separate default chezmoi source repository. The
explicit `--source` form above is intentional and avoids changing that source
repository. After applying, disable or remove any old AeroSpace login item,
then load the generated LaunchAgent:

```sh
launchctl bootout "gui/$(id -u)/com.yutarotakagi.aerospace-external-monitor" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.yutarotakagi.aerospace-external-monitor.plist"
launchctl kickstart -k "gui/$(id -u)/com.yutarotakagi.aerospace-external-monitor"
```

`start-at-login = false` is required in `aerospace.toml`; launchd is the only
login-start mechanism in this setup.

## Runtime behavior

`has-external-monitor.swift` uses CoreGraphics and `CGDisplayIsBuiltin`, so a
clamshell MacBook with an active external display is accepted even when only
one display is visible. The LaunchAgent retries for about one minute to allow
WindowServer display discovery to finish.

The bootstrap opens each application with `open -a`, never `open -na`. A
normal Chrome launch is used so Chrome restores its own previous session; no
new profile or blank window is created by the automation.

The initial arrangement is guarded by a marker under
`~/.local/state/aerospace` whose name includes the current macOS boot token.
Once arrangement succeeds, normal user moves and resizes are not reapplied;
the marker naturally changes after a reboot. To intentionally run it again:

```sh
~/.config/aerospace/scripts/bootstrap.sh --force
```

During arrangement, the five windows in workspaces 1 and 2 are briefly moved
through workspace 10 (`AEROSPACE_STAGING_WORKSPACE`). Other windows are moved
to workspace 5 and that workspace is set to `h_accordion`. Override the staging
workspace in `config.local` if needed, but do not set it to workspace 5.
This cleanup runs only during the initial arrangement or an explicit
`--force`; later user-created windows are not continuously moved.

Workspace 1 keeps its existing left-pane adjustment from
`AEROSPACE_LEFT_RESIZE_PX`. Workspace 2 uses the separate
`AEROSPACE_WORKSPACE_2_LEFT_RESIZE_PX` value; the default `688` is calibrated
for the current 3440px external display and produces approximately 7:3
(Ghostty:Chrome). Override that value in `config.local` when using a display
with a different logical width.

## Chrome window matching

The configured profile directories are `Default` and `Profile 4`, verified
from Chrome's `Local State` on the target machine. JXA reads each live Chrome
window's title, active URL, tab count, and tab URLs without changing tabs.

The live Chrome window ID is not used as persistent state. It is only used to
inspect the current session, and the corresponding AeroSpace window ID is
resolved from an unambiguous window title. The state file stores a local TSV
mapping of profile, workspace, URL fingerprint, and active URL with mode 600.
Exact fingerprints and active URLs take precedence on later runs. On a first
run, the script can learn from an existing placement in workspaces 1 and 2,
or use the configurable URL hints in `config.env`. If profile or window
identity is ambiguous, the script logs the reason and refuses the initial
arrangement rather than moving a guessed window.

Machine-specific values can be overridden in the untracked file
`~/.config/aerospace/config.local`.

## Permissions and limitations

Grant AeroSpace Accessibility permission in System Settings → Privacy &
Security → Accessibility. Grant the shell/automation caller permission to
control Google Chrome under Privacy & Security → Automation when macOS asks.

The repository tests cover the configuration contract, template rendering,
monitor helper compilation, and the no-external-display path. The final tree
was also exercised on the target AeroSpace 0.21.3 server; exact pixel ratios
still depend on the connected monitor's dimensions and gap settings.
