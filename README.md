# README

This is a fork of [three-loader](https://github.com/pnext/three-loader), which itself is a modularized version of [Potree](http://potree.org/). This fork is updated to support the new PotreeConverter 2.0 format, updated to use WebGL2, and has the bundler changed to Vite. The API is identical to the original version. I am mainly using this for a [heritage archive project](https://thelostmetropolis.org).

# Known issues
- Warning about THREE being imported twice

# 

# Usage

```typescript
import { Scene } from 'three';
import { PointCloudOctree, Potree } from 'potree-loader';

const scene = new Scene();
// Manages the necessary state for loading/updating one or more point clouds.
const potree = new Potree();
// Show at most 2 million points.
potree.pointBudget = 2_000_000;
// List of point clouds which we loaded and need to update.
const pointClouds: PointCloudOctree[] = [];

potree
  .loadPointCloud(
    // The name of the point cloud which is to be loaded.
    'metadata.json',
    // Given the relative URL of a file, should return a full URL (e.g. signed).
    relativeUrl => `${baseUrl}${relativeUrl}`,
  )
  .then(pco => {
    pointClouds.push(pco);
    scene.add(pco); // Add the loaded point cloud to your ThreeJS scene.

    // The point cloud comes with a material which can be customized directly.
    // Here we just set the size of the points.
    pco.material.size = 1.0;
  });

function update() {
  // This is where most of the potree magic happens. It updates the visiblily of the octree nodes
  // based on the camera frustum and it triggers any loads/unloads which are necessary to keep the
  // number of visible points in check.
  potree.updatePointClouds(pointClouds, camera, renderer);

  // Render your scene as normal
  renderer.clear();
  renderer.render(scene, camera);
}
```

# Todo
- [ ] Types!
- [ ] Async / await
- [ ] Occlusion culling
