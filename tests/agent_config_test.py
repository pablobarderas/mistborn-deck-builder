"""Negative contract cases for the SDD configuration validator; no disk mutations."""

from __future__ import annotations

import importlib.util
import io
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("check_agents", ROOT / "tools/check_agents.py")
assert SPEC is not None and SPEC.loader is not None
CHECK = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECK)


class AgentConfigTest(unittest.TestCase):
    def test_delivered_configuration(self) -> None:
        self.assertEqual(CHECK.validate(ROOT), [])

    def test_invalid_configurations_are_rejected(self) -> None:
        role_path = ROOT / ".codex/agents/sdd_rules.toml"
        config_path = ROOT / ".codex/config.toml"
        role = role_path.read_text(encoding="utf-8")
        config = config_path.read_text(encoding="utf-8")
        cases = {
            "invalid_toml": (config_path, "[agents"),
            "missing_role": (role_path, None),
            "duplicate_name": (role_path, role.replace('name = "sdd_rules"', 'name = "sdd_reviewer"')),
            "missing_field": (role_path, role.replace('model_reasoning_effort = "high"', "")),
            "unknown_model": (role_path, role.replace("gpt-6.1-sol", "unknown-model")),
            "invalid_effort": (role_path, role.replace('"high"', '"invalid"')),
            "wrong_type": (role_path, role.replace('model = "gpt-6.1-sol"', "model = []")),
            "permission_override": (role_path, role + '\nsandbox_mode = "read-only"\n'),
            "root_model_override": (config_path, config + '\n[model]\nname = "unknown"\n'),
            "bad_concurrency": (config_path, config.replace("= 2", "= true")),
            "missing_reference": (role_path, role.replace("docs/gestion/agentes-sdd.md", "absent.md")),
        }
        original_open = Path.open
        for name, (changed_path, changed_source) in cases.items():
            with self.subTest(case=name):
                def fake_open(path: Path, *args, **kwargs):
                    if path == changed_path:
                        if changed_source is None:
                            raise FileNotFoundError("simulated missing role")
                        return io.BytesIO(changed_source.encode("utf-8"))
                    return original_open(path, *args, **kwargs)

                with patch.object(Path, "open", fake_open):
                    self.assertTrue(CHECK.validate(ROOT))


if __name__ == "__main__":
    unittest.main(verbosity=2)
