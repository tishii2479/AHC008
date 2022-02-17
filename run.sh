./build.sh

cd tools

echo "[LOG] Start test."

python3 ../run.py

echo "[LOG] End test."

cd ..

pbcopy < tools/out/main.log
