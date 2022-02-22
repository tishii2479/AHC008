with open('v18.dt3') as f:
    data: str = f.readline()
    size, dots, palette, _ = data.split(':')
    dots = dots.split(',')
    assert len(dots) == 900
    color = "104"
    pos = []
    for i in range(900):
        if dots[i] == color:
            pos.append(i)

    for p in pos:
        print(f'            Position(x: {p % 30}, y: {p // 30}),')
