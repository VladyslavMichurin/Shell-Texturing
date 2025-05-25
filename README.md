# Shell-Texturing
This is a material that aims to make 3d objects look as if they were drawn in manga style. The shader uses lambertian diffuse for light and divides it in 3 sections: highlights, base color and shadows. Each section can be remaped to a specific color and you can regulate it's size. For shadows you can choose a texture that will be applied to that region, it rotates based on light direction and has several modes to determine how it should do it(you can change mode in shader). The outlines are made using inverted hull method and you can use a noise texture to make them more jagged.

## Showcase  
![Pulchra](./Examples/Pulchra-Rotating.gif)

### Images  
![Pulchra](./Examples/Pulchra-Face.png)
![Pulchra](./Examples/Pulchra-Body.png)
![Pulchra](./Examples/Pulchra-Legs.png)
![Pulchra](./Examples/Pulchra-Tail.png)

## Resources Used
1)[Acerola](https://www.youtube.com/watch?v=9dr-tRQzij4&t=789s) 

2)[A Practical Guide to Generating Real-Time Dynamic Fur
and Hair using Shells](https://xbdev.net/misc_demos/demos/fur_course_notes/paper.pdf)

3)[Fur (using Shells and Fins)](https://developer.download.nvidia.com/SDK/10/direct3d/Source/Fur/doc/FurShellsAndFins.pdf)

4)[toninhoPinto](https://github.com/toninhoPinto/Shells-and-Fins#)

5)[Pulchra model from Zenless Zone Zero](https://sketchfab.com/3d-models/pulchra-zenless-zone-zero-game-character-743a408ba3f94635b33e71f2bcd882c2)
