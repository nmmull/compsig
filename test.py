import matplotlib.pyplot as plt
import numpy as np
x = np.linspace(0, 10, int(44100 * 10))
y = np.sin(6.28318530718 * x) * np.sin(1382.30076758 * x)
fig, ax = plt.subplots()
ax.plot(x, y)
plt.show()