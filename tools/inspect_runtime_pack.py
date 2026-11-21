"""Inspección adicional de bytes completos de los originales en el PCK local."""
import hashlib
import json
import pathlib
import sys
pack = pathlib.Path(sys.argv[1])
source_dir = pathlib.Path(sys.argv[2])
content = pack.read_bytes()
checks = []
for name in ("misiones.1.png", "misiones.2.png", "mercado.3.png"):
    original = (source_dir / name).read_bytes()
    found = original in content
    checks.append({"name": name, "bytes": len(original), "sha256": hashlib.sha256(original).hexdigest(), "present_in_pack": found})
report = {"pack_bytes": len(content), "pack_sha256": hashlib.sha256(content).hexdigest(), "originals": checks}
pathlib.Path(sys.argv[3]).write_text(json.dumps(report, indent=2), encoding="utf-8")
if any(row["present_in_pack"] for row in checks):
    raise SystemExit("El paquete contiene bytes originales")
print("P08_RUNTIME_BYTES_OK")
