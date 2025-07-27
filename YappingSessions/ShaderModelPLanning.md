## Shader Model Idea
- Fragment Main
    - Create a "shader model decider (smd)"
    - Pass the "smd" to the RayTracer
        - Call color on the "smd"

## Renderer settings
- simd4 * 4
    - arrayLengths
        - [obj, mat, lights, empty]
    - shading info
        - [modelType, shadowOvr, empty, empty]
    - ambient
        - [x, y, z, strength]
    - temp3
        - [empty, empty, empty, empty]
