./build.sh

cd tools

echo "[LOG] Start test."

cargo run --release --bin tester out/main < in/0006.txt > out/main.log

echo "[LOG] End test."

cd ..

pbcopy < tools/out/main.log
