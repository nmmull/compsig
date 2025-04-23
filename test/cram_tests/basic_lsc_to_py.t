Create a test file:
  $ cat >ex1.lsc <<EOF
  > let pi = 3.14159265358979312 in
  > let sin_osc = fun freq phase ->
  >   sin << (2. * pi * freq * t + phase)
  > in
  > let s1 = sin_osc 440. 0. in
  > let s2 = sin_osc 1. 0. in
  > s2 * s1
  > EOF
Convert to SuperCollider:
  $ compsig -i lsc -o py < ex1.lsc
  import matplotlib.pyplot as plt
  import numpy as np
  x = np.linspace(0, 10, int(44100 * 10))
  y = np.sin(6.28318530718 * x) * np.sin(2764.60153516 * x)
  fig, ax = plt.subplots()
  ax.plot(x, y)
  plt.show()
