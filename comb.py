import sys
import re

files = [
    "Values.swift",
    "main.swift",
    "Manager.swift",
    "Players.swift",
    "Models.swift",
    "JobDirector.swift",
    "GridCreator.swift",
    "SquareGridManagerV2.swift",
    "HumanBrain.swift",
    "Field.swift",
    "Utils.swift",
    "IOController.swift",
    "DataStructures.swift",
    "IO.swift",
#    "Extensions.swift",
]

out_file = "out/main.swift"

imports = set()
headers = []
src = []

for file in files:
    src.append("\n// MARK: " + file + "\n\n")
    with open("AHC008/" + file, "r") as f:
        # Skip first line after import if import block exists
        skip_line = False
        for line in f:
            is_import = len(line) >= 6 and line[:6] == "import"
            is_macro = len(line) >= 1 and line[0] == "#"
            
            # Macro lines (ex: #if ~)
            if is_macro:
                headers.append(line)
                skip_line = True
                continue
            # Import lines (ex: import Foundation)
            if is_import:
                if line not in imports:
                    headers.append(line)
                    imports.add(line)
                skip_line = True
                continue
            
            # Others
            if skip_line:
                # If the first line have content, do not skip
                if not line.isspace():
                    src.append(line)
                skip_line = False
            else:
                src.append(line)

with open(out_file, "w") as f:
    f.writelines(headers)
    f.writelines(src)
