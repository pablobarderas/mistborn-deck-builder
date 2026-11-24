"""Build and verify the authoring inventory for the Spanish competitive market.

The source scans stay outside Git. This inventory is not a playable catalog.
"""

import argparse
import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
AUDIT = ROOT / "docs/referencias/auditoria-escaneos-2026-11-09.md"
INVENTORY = ROOT / "docs/specs/011-competitivo-completo/mercado-inventario.json"
SCAN_NAMES = [f"mercado.{n}.png" for n in range(1, 8)] + ["mercado8.png", "mercado9.png"]
ROW = re.compile(r"^\| (mercado(?:\.[1-7]|8|9)\.png) \| ([1-4]) \| (izquierda|derecha|única) \| ([^|]+) \| (rojo|azul|naranja|amarillo|aliado|atium) \| ([12]) \|$")


def audit_rows(lines=None):
    rows = []
    if lines is None:
        lines = AUDIT.read_text(encoding="utf-8").splitlines()
    for line in lines:
        match = ROW.fullmatch(line.strip())
        if match:
            filename, row, side, name, kind, copies = match.groups()
            sheet = filename.removeprefix("mercado").removesuffix(".png").lstrip(".")
            rows.append({
                "id": f"mercado_{int(sheet):02d}_f{int(row):02d}_{side}",
                "nombre_auditoria": name.strip(),
                "clase_auditoria": kind,
                "copias_declaradas": int(copies),
                "fuente": filename,
                "fila": int(row),
                "posicion": side,
                "fidelidad": "pendiente",
                "ejecucion": "pendiente",
                "distribucion": "pendiente",
            })
    return rows


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build(source_root):
    rows = audit_rows()
    if len(rows) != 65 or sum(row["copias_declaradas"] for row in rows) != 82:
        raise ValueError("Auditoría incompleta")
    sources = []
    for filename in SCAN_NAMES:
        path = source_root / filename
        if not path.is_file():
            raise ValueError(f"Falta fuente local: {filename}")
        sources.append({"archivo": filename, "sha256": digest(path)})
    return {"version": 1, "origen": "SRC-005; docs/referencias/auditoria-escaneos-2026-11-09.md",
            "estado": "inventario_no_admitido", "fuentes": sources, "disenos": rows}


def same_typed(actual, expected):
    if type(actual) is not type(expected):
        return False
    if isinstance(expected, dict):
        return actual.keys() == expected.keys() and all(
            same_typed(actual[key], value) for key, value in expected.items())
    if isinstance(expected, list):
        return len(actual) == len(expected) and all(
            same_typed(left, right) for left, right in zip(actual, expected))
    return actual == expected


def check(data, source_root):
    expected = build(source_root)
    if not same_typed(data, expected):
        raise ValueError("Inventario distinto de auditoría o de fuentes locales")
    rows = data["disenos"]
    if len({row["id"] for row in rows}) != 65:
        raise ValueError("ID duplicado")
    if len({(row["fuente"], row["fila"], row["posicion"]) for row in rows}) != 65:
        raise ValueError("Localizador duplicado")
    groups = {kind: sum(row["clase_auditoria"] == kind for row in rows)
              for kind in ("rojo", "azul", "naranja", "amarillo", "aliado", "atium")}
    if sum(groups[kind] for kind in ("rojo", "azul", "naranja", "amarillo")) != 40 \
            or groups["aliado"] != 21 or groups["atium"] != 4:
        raise ValueError("Composición incorrecta")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    data = build(args.source_root)
    if args.write:
        INVENTORY.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    check(json.loads(INVENTORY.read_text(encoding="utf-8")), args.source_root)
    print("MARKET_INVENTORY_OK: 65 diseños, 82 copias, 9 fuentes")


if __name__ == "__main__":
    main()
