import matplotlib.pyplot as plt
import numpy as np
x = np.linspace(0, 0.1, int(44100 * 0.1))
y = np.sin(628.318530718 * x) * np.sin(2764.60153516 * x)
fig, ax = plt.subplots()
ax.plot(x, y)
plt.show()