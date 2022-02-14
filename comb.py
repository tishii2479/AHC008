files = [
    "main.swift",
    "GameManager.swift",
    "Models.swift",
    "IO.swift"
]

out_file = "out/main.swift"

imports = set()
src = []

for file in files:
    src.append("\n// MARK: " + file + "\n\n")
    with open("AHC008/" + file, "r") as f:
        # Skip first line after import if import statement exists
        skip_line = False
        for line in f:
            if len(line) >= 6 and line[:6] == "import":
                imports.add(line)
                skip_line = True
                continue
            if skip_line:
                if len(line) > 0:
                    src.append(line)
                skip_line = False
                continue
            src.append(line)

with open(out_file, "w") as f:
    f.writelines(list(imports))
    f.writelines(src)
