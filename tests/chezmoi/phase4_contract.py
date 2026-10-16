#!/usr/bin/env python3
"""Exercise Phase 4 against isolated homes, including third-party state."""

import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import tempfile


REPO = Path(__file__).resolve().parents[2]
OPENAI_SKILLS = ("define-goal", "gh-address-comments", "gh-fix-ci", "hatch-pet", "playwright", "yeet")
TRACKING_SKILLS = OPENAI_SKILLS + ("grilling", "domain-modeling")
APM_SKILLS = TRACKING_SKILLS + ("typesafe-ai", "tenbin-astra-diff-review")
for skill in APM_SKILLS:
    assert not (REPO / "chezmoi/dot_codex/skills" / skill).exists(), skill
# Chezmoi provides YAML parsing, so these checks need no Python YAML dependency.
def yaml(path):
    result = subprocess.run(
        ["chezmoi", "execute-template", "--with-stdin",
         "{{ fromYaml .chezmoi.stdin | toJson }}"],
        input=path.read_text(), text=True, capture_output=True, check=True)
    return json.loads(result.stdout)


manifest = yaml(REPO / "chezmoi/dot_apm/apm.yml")
lock = yaml(REPO / "chezmoi/dot_apm/apm.lock.yaml")
locked = {dependency["name"]: dependency for dependency in lock["dependencies"]}
assert len(locked) == len(lock["dependencies"]) == len(manifest["dependencies"]["apm"]) == 12
assert set(locked) == set(APM_SKILLS) | {"apm-usage", "pkfire"}
assert manifest["targets"] == ["codex"]
for specification in manifest["dependencies"]["apm"]:
    location, reference = specification.rsplit("#", 1)
    name = location.rsplit("/", 1)[-1]
    if name in TRACKING_SKILLS:
        assert reference == "main", specification
    else:
        assert re.fullmatch(r"[0-9a-f]{40}", reference), specification
    dependency = locked[name]
    assert location == dependency["repo_url"] + "/" + dependency["virtual_path"]
    assert dependency["resolved_ref"] == reference
    assert re.fullmatch(r"[0-9a-f]{40}", dependency["resolved_commit"])
    if name not in TRACKING_SKILLS:
        assert dependency["resolved_commit"] == reference
    hashes = dependency["deployed_file_hashes"]
    assert f".agents/skills/{name}/SKILL.md" in hashes
    assert all(path.startswith(f".agents/skills/{name}/") for path in hashes)
    assert all(re.fullmatch(r"sha256:[0-9a-f]{64}", digest) for digest in hashes.values())
for name in OPENAI_SKILLS:
    assert locked[name]["repo_url"] == "openai/skills"
    assert locked[name]["virtual_path"] == f"skills/.curated/{name}"
assert len({locked[name]["resolved_commit"] for name in OPENAI_SKILLS}) == 1
for name, path in (("grilling", "skills/productivity/grilling"),
                   ("domain-modeling", "skills/engineering/domain-modeling")):
    assert locked[name]["repo_url"] == "mattpocock/skills"
    assert locked[name]["virtual_path"] == path
for filename in ("GLOSSARY-FORMAT.md", "ADR-FORMAT.md"):
    assert f".agents/skills/domain-modeling/{filename}" in locked["domain-modeling"]["deployed_file_hashes"]

EXPECTED = [
    ".codex/AGENTS.md", ".codex/config.toml", ".codex/hooks.json",
    ".codex/runcat-hook.py",
    ".codex/skills/herdr/references/commands.md",
    ".apm/apm.yml", ".apm/apm.lock.yaml", ".apm/config.json",
    ".claude/settings.json", ".claude/CLAUDE.md",
    ".copilot/settings.json", ".latexmkrc",
    ".config/btop/btop.conf", ".config/gh/config.yml", ".config/git/ignore",
    ".config/ghostty/config", ".config/herdr/config.toml",
    ".config/hunk/config.toml", ".config/karabiner/karabiner.json",
    ".config/rstudio/rstudio-prefs.json", ".config/yazi/init.lua",
    ".config/yazi/keymap.toml", ".config/yazi/package.toml",
    ".config/yazi/theme.toml", ".config/yazi/yazi.toml",
    ".config/zed/settings.json", ".config/zed/keymap.json",
    ".config/zellij/config.kdl", ".config/zellij/themes/tokyonight.kdl",
]
EXCLUDED = [
    ".codex/auth.json", ".codex/sessions/test.jsonl", ".codex/state_5.sqlite",
    ".codex/plugins/cache/test", ".codex/skills/.system/test",
    ".codex/rules/default.rules", ".codex/herdr-agent-state.sh",
    ".apm/apm_modules/test", ".agents/skills/apm-usage/SKILL.md",
    ".agents/skills/pkfire/SKILL.md", ".claude/hooks/herdr-agent-state.sh",
    ".copilot/hooks/herdr-agent-state.sh", ".config/gh/hosts.yml",
    ".config/github-copilot/auth.db", ".config/jotworthy/env",
    ".config/herdr/session.json", ".config/hunk/state.json",
    ".config/karabiner/automatic_backups/test.json",
    ".config/yazi/plugins/test/main.lua", ".config/yazi/flavors/test/flavor.toml",
    ".config/zed/conversations/test", ".config/sheldon/plugins.toml",
    ".config/starship.toml", ".config/tmux/tmux.conf", ".gitconfig",
    ".arduinoIDE/settings.json", ".arduinoIDE/arduino-cli.yaml",
    ".arduinoIDE/recent-sketches.json", ".keras/keras.json", ".keras/cache/test",
    ".docker/config.json", ".docker/.token_seed",
]
for skill in APM_SKILLS:
    EXCLUDED += [f".codex/skills/{skill}/SKILL.md", f".agents/skills/{skill}/SKILL.md"]


with tempfile.TemporaryDirectory(prefix="nix-dotfiles-phase4-") as temporary:
    root = Path(temporary)
    source = root / "source"
    shutil.copytree(REPO / "chezmoi", source)
    # Accidental recursive imports must remain ignored even if in source state.
    for target in EXCLUDED:
        path = source.joinpath(*(f"dot_{p[1:]}" if p.startswith(".") else p
                                 for p in Path(target).parts))
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("unwanted source content\n")

    for populated in (False, True):
        home = root / ("existing" if populated else "fresh")
        home.mkdir()
        config = root / f"{home.name}.toml"
        config.touch()
        command = ["chezmoi", "--config", str(config), "--source", str(source),
                   "--destination", str(home), "--persistent-state",
                   str(root / f"{home.name}.boltdb"), "--force"]

        def run(*args, input=None):
            result = subprocess.run(command + list(args), input=input, text=True,
                                    capture_output=True)
            if result.returncode:
                raise RuntimeError(result.stderr or result.stdout)
            return result.stdout

        def toml(path):
            return json.loads(run("execute-template", "--with-stdin",
                                  "{{ fromToml .chezmoi.stdin | toJson }}",
                                  input=path.read_text()))

        if populated:
            for target in EXCLUDED:
                path = home / target
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("existing local state\n")
            (home / ".codex/config.toml").write_text(
                'model = "old-model"\nnotify = ["/local/app"]\n'
                '[mcp_servers.local]\ncommand = "/local/mcp"\n'
                '[projects."/local/repo"]\ntrust_level = "trusted"\n'
                '[features]\nlocal_feature = true\n'
                '[marketplaces.local]\nsource = "/local/cache"\n'
                '[plugins."local@test"]\nenabled = true\n')
            hooks = {"hooks": {"SessionStart": [{"matcher": "*", "hooks": [
                {"type": "command", "command": "/old/.codex/runcat-hook.py"},
                {"type": "command", "command": "herdr-session"}]}],
                "Stop": [{"hooks": [{"command": "local-stop"}]}]}}
            (home / ".codex/hooks.json").write_text(json.dumps(hooks))
            for tool in ("claude", "copilot"):
                (home / f".{tool}/settings.json").write_text(json.dumps(
                    {"hooks": {"SessionStart": [{"command": "herdr-session"}]},
                     "localSetting": "preserved"}))

        run("init", "--guess-repo-url=false")
        run("apply")
        managed = set(run("managed", "--include=files,symlinks").splitlines())
        for target in EXPECTED:
            assert (home / target).is_file(), target
            assert target in managed, target
        for target in EXCLUDED:
            assert target not in managed, target
            if populated:
                assert (home / target).read_text() == "existing local state\n", target
            else:
                assert not (home / target).exists(), target

        preferences = toml(home / ".codex/config.toml")
        assert preferences["model"] == "gpt-6.1-sol"
        assert preferences["model_reasoning_effort"] == "medium"
        assert preferences["features"]["hooks"] is True
        if populated:
            assert preferences["notify"] == ["/local/app"]
            assert preferences["mcp_servers"]["local"]["command"] == "/local/mcp"
            assert preferences["projects"]["/local/repo"]["trust_level"] == "trusted"
            assert preferences["features"]["local_feature"] is True
            assert preferences["marketplaces"]["local"]["source"] == "/local/cache"
            assert preferences["plugins"]["local@test"]["enabled"] is True
        hooks = json.loads((home / ".codex/hooks.json").read_text())["hooks"]
        commands = [h["command"] for group in hooks["SessionStart"] for h in group["hooks"]]
        assert sum("runcat-hook.py" in c for c in commands) == 1
        assert 'python3 "$HOME/.codex/runcat-hook.py"' in commands
        if populated:
            assert "herdr-session" in commands
            assert hooks["Stop"][0]["hooks"][0]["command"] == "local-stop"
        for tool, key, value in (("claude", "theme", "dark"),
                                 ("copilot", "showReasoning", True)):
            settings = json.loads((home / f".{tool}/settings.json").read_text())
            assert settings[key] == value
            if populated:
                assert settings["localSetting"] == "preserved"
                assert settings["hooks"]["SessionStart"][0]["command"] == "herdr-session"
        for filename in ("apm.yml", "apm.lock.yaml", "config.json"):
            assert (home / ".apm" / filename).read_bytes() == (
                source / "dot_apm" / filename).read_bytes()
        # Native chezmoi parsers also validate imported JSONC and TOML syntax.
        for target in EXPECTED:
            path = home / target
            if path.suffix == ".json":
                run("execute-template", "--with-stdin",
                    "{{ fromJsonc .chezmoi.stdin | toJson }}", input=path.read_text())
            elif path.suffix == ".toml":
                toml(path)
        assert (home / ".codex/runcat-hook.py").stat().st_mode & 0o111
        claude_memory = home / ".claude/CLAUDE.md"
        assert claude_memory.is_symlink(), claude_memory
        assert os.readlink(claude_memory) == "../.codex/AGENTS.md"
        assert claude_memory.read_bytes() == (home / ".codex/AGENTS.md").read_bytes()
        before = {p.relative_to(home): p.read_bytes() for p in home.rglob("*") if p.is_file()}
        run("apply")
        after = {p.relative_to(home): p.read_bytes() for p in home.rglob("*") if p.is_file()}
        assert before == after, "apply must be idempotent"

print("chezmoi phase 4 ownership contract: ok")
