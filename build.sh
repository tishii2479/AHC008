echo "[LOG] Combinate files..."

python3 comb.py

echo "[LOG] Output file: out/main.swift"

#cat out/main.swift

echo "[LOG] Compile out/main.swift..."

swiftc out/main.swift -o tools/out/main

echo "[LOG] Compile done. -> tools/out/main"
