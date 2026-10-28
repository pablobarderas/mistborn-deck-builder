"""Validate the project's SDD agent configuration. Python 3.11+, no packages.

This checks the local contract, not Codex loading or model availability.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import sys
import tomllib


MODELS = {
    "gpt-6-luna": {"low", "medium", "high", "xhigh", "max"},
    "gpt-6.1-sol": {"low", "medium", "high", "xhigh", "max"},
    "gpt-6.1-terra": {"low", "medium", "high", "xhigh", "max"},
    "gpt-6-astra": {"low", "medium", "high", "xhigh", "max"},
}
ROLES = {
    "sdd_support", "sdd_planner", "sdd_developer", "sdd_reviewer",
    "sdd_rules", "sdd_visual", "sdd_escalation",
}
FIELDS = {"name", "description", "model", "model_reasoning_effort", "developer_instructions"}


def validate(root: Path) -> list[str]:
    errors: list[str] = []

    def read(path: Path) -> dict:
        try:
            with path.open("rb") as source:
                return tomllib.load(source)
        except (OSError, ValueError) as exc:
            errors.append(f"{path.relative_to(root)}: {exc}")
            return {}

    config = read(root / ".codex/config.toml")
    # Keep this layer deliberately narrow: no root model, permissions or services.
    if set(config) != {"agents"} or not isinstance(config.get("agents"), dict):
        errors.append(".codex/config.toml: se permite solo la tabla agents")
    else:
        settings = config["agents"]
        if set(settings) != {"enabled", "max_concurrent_threads_per_session"}:
            errors.append("agents: claves distintas del contrato local")
        if settings.get("enabled") is not True:
            errors.append("agents.enabled debe ser true")
        limit = settings.get("max_concurrent_threads_per_session")
        if type(limit) is not int or limit != 2:
            errors.append("agents.max_concurrent_threads_per_session debe ser 2")

    seen: set[str] = set()
    paths = sorted((root / ".codex/agents").glob("*.toml"))
    for path in paths:
        role = read(path)
        label = str(path.relative_to(root))
        if set(role) != FIELDS:
            errors.append(f"{label}: campos requeridos {sorted(FIELDS)}; no se admiten overrides adicionales")
        for key in FIELDS:
            if not isinstance(role.get(key), str) or not role[key].strip():
                errors.append(f"{label}: {key} debe ser texto no vacío")
        name = role.get("name")
        if isinstance(name, str):
            if name in seen:
                errors.append(f"{label}: nombre duplicado {name}")
            seen.add(name)
            if name != path.stem:
                errors.append(f"{label}: nombre y archivo deben coincidir")
        model = role.get("model")
        effort = role.get("model_reasoning_effort")
        if not isinstance(model, str) or model not in MODELS:
            errors.append(f"{label}: modelo fuera de la política local")
        elif not isinstance(effort, str) or effort not in MODELS[model]:
            errors.append(f"{label}: esfuerzo no admitido por la política local")
        instructions = role.get("developer_instructions", "")
        if isinstance(instructions, str):
            for reference in ("AGENTS.md", "docs/gestion/agentes-sdd.md"):
                if reference not in instructions:
                    errors.append(f"{label}: falta referencia a {reference}")
    if seen != ROLES:
        errors.append(f"roles: faltan {sorted(ROLES - seen)}; sobran {sorted(seen - ROLES)}")
    if len(paths) != len(ROLES):
        errors.append(f"se esperaban {len(ROLES)} perfiles; encontrados {len(paths)}")
    for reference in ("AGENTS.md", "docs/gestion/agentes-sdd.md"):
        if not (root / reference).is_file():
            errors.append(f"referencia ausente: {reference}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    errors = validate(args.root.resolve())
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print("SDD_AGENTS_OK: 7 perfiles TOML; contrato local válido; carga/modelos no comprobados")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
