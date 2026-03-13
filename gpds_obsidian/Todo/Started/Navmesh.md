Every world has a navmesh region for static geometry that gets baked based on a group name

Every platform has its own navmesh region that covers its surface and moves with it. This region can be baked. if platform has sub-geometry, it needs to be a child of that platform's navigation region

Every staircase has 4 navmesh regions - one for each side - that rotate with it and are enabled/disabled based on platform rotation

Platform navmesh needs expanded to more easily connect to the moving stairs

Do navigation obstacles work to block pathing through the generated meshes? If so we don't need a lot of work for platforms that contain obstacles on them

Region adjacency should be set globally to a very forgiving value.