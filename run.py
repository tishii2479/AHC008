import subprocess
sum = 0
n = 50

for i in range(n):
    in_file = "in/" + str(i).zfill(4) + ".txt"
    with open(in_file) as f:
        proc = subprocess.run(
            ["cargo", "run", "--release", "--bin", "tester", "out/main"],
        stdin=f, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output = proc.stderr.decode("utf8")
        
        score = ""
        ok = False
        for c in output:
            if c == "=":
                ok = True
            if c.isdigit() and ok:
                score += c
        sum += int(score)
        print("Score for", in_file, score)

print("[RESULT] Average is", sum / n)
