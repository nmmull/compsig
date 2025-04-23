import matplotlib.pyplot as plt
import numpy as np
x = np.linspace(0, 10, int(44100 * 10))
y = np.sin(6.28318530718 * x) * np.sin(2764.60153516 * x)
fig, ax = plt.subplots()
ax.plot(x, y)
plt.show()