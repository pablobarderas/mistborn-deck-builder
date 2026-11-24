"""Adversarial checks for the authoring market inventory."""

import argparse
import json
import sys
from copy import deepcopy
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import market_inventory as inventory  # noqa: E402


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", type=Path, required=True)
    args = parser.parse_args()
    original = json.loads(inventory.INVENTORY.read_text(encoding="utf-8"))
    inventory.check(original, args.source_root)
    audit_lines = inventory.AUDIT.read_text(encoding="utf-8").splitlines()
    source_rows = [line for line in audit_lines if inventory.ROW.fullmatch(line.strip())]
    swapped = source_rows.copy()
    swapped[0], swapped[1] = swapped[1], swapped[0]
    original_ids = {row["nombre_auditoria"]: row["id"] for row in inventory.audit_rows(source_rows)}
    swapped_ids = {row["nombre_auditoria"]: row["id"] for row in inventory.audit_rows(swapped)}
    assert original_ids == swapped_ids, "Reordenar la auditoría no puede reasignar IDs"
    for mutate in (
        lambda data: data["disenos"][1].update(id=data["disenos"][0]["id"]),
        lambda data: data["disenos"][0].update(copias_declaradas=1),
        lambda data: data["disenos"][0].update(fuente="desconocida.png"),
        lambda data: data["fuentes"][0].update(sha256="0" * 64),
        lambda data: data["disenos"][0].update(fidelidad="verificada"),
        lambda data: data.update(version=True),
        lambda data: data["disenos"][3].update(copias_declaradas=True),
        lambda data: data["disenos"][0].update(fila=1.0),
    ):
        changed = deepcopy(original)
        mutate(changed)
        try:
            inventory.check(changed, args.source_root)
        except ValueError:
            pass
        else:
            raise AssertionError("Se admitió un inventario alterado")
    print("MARKET_INVENTORY_TEST_OK: 10 comprobaciones")


if __name__ == "__main__":
    main()
