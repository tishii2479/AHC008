./build.sh

cd tools

echo "[LOG] Start test."

cargo run --release --bin tester out/main < in/0001.txt > out/main.log

echo "[LOG] End test."

cd ..
