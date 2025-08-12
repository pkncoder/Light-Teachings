# Lesson Plans for Light Teachings App

## Table of Contents
- Theory
    - [ ] What is Ray Tracing and where is it used?
    - [ ] How does Ray-Tracing Work?
    - [ ] Concepts
    - [ ] How to hit an object to return colors
    - [ ] Simple Diffuse Lighting and basic shading
    - [ ] Basic Full lighting model (Phong)
    - BRDFs
        - [ ] What is a BRDF?
        - [ ] Cook-Torrance BRDF
        - [ ] Other BRDF's
            - Disney BRDF

## Plans
- What is Ray Tracing and where is it used?
    - Explain the idea of ray tracing
        - Emulating how light works in the real world to produce realistic images
    - Explain examples of where people have seen the use of Ray Tracing
        - Video Games
        - Movies
    - *Overview?*
    - Next video
        - How does ray tracing works


- How does Ray-Tracing work?
    - How does light work in real life?
        - Light starts from a light source, like a lamp or our sun
        - It bounces around, each time coloring itself based on the color of whatever it hit
        - Eventually it reaches our eyes, and we use the light to see the world
    - How can we emulate this using Ray tracing?
        - We start with creating an "eye" so we can detect light
        - Now, if we start with the same idea as how light works in real life
            - Light starts from a light source
            - It bounces around hitting objects, coloring itself on each bounce
            - Eventually hitting our "eye"
                - This gives us color information, so we can see the ray traced world around us
    - This works, however is is really show
        - The light that comes from light sources has a very small chance of hitting our eye, so we have to wait longer to get more light. Like exposure on a camera
        - Solution
            - To ensure that all of the light hits our eye, we can do things in reverse
            - Instead of starting from light sources, we can start from our eye, going outward into an area instead
            - For every object that our new light ray hits along it's path, we save the color
            - Eventually the ray will hit a light source and we can use the final color of that ray to paint a picture
    - Overview
        - Light in real life comes from light sources like a lamp or our sun, bounces around getting colored until it hits somebodies' eye, letting us see the world
        - In ray tracing however, we do things backwards, we send out rays from an eye, hitting objects, giving the light ray a color, and eventually hitting a light source, letting us paint a picture
    - Next video
        - Concepts needed to know before continuing to learn how to use the light rays to give us a color


- Concepts
    - Things that are needed to know to continue
    - Come back to this video if needed, and pause at any time to get some understanding on the concepts
    - The goal of ray tracing
        - Represent how computers are able render scenes with realistic lighting
        - It all starts with the eye
            - The eye acts as an observer/person looking at a computer screen
            - The screen has pixels, and each pixel needs to be colored depending on how light is hitting objects in a scene
                - A scene being anything that has objects/things in it
        - The ray is the next bit
            - It is used to emulate the path the beam of light takes to reach the eye, and is important so we know what objects light hits and where the light hits the objects at
            - Rays are not always used this way, however it is the most common use
    - Important information
        - Functions
            - All a function does is take in information, and use it to output - or return - more information
                - Think of it like a calculator, the calculator takes in an equation, and gives you the result. The calculator is the function in this case
        - Lighting models
            - A lighting model the different ways of coloring a scene
        - Vectors
            - Here, we use vectors as lines with a direction and intensity(or magnatude), that we can use to compare with other vectors
    - Next Video
        - Learn how we can hit objects and finally paint a picture


- How to hit an object to return colors
    - Final product
        - A scene
            - One purple ball to the left of center
            - One red ball to the right of center
    - How do we get there
        - As said before, we send rays out through an eye into the scene
        - Those rays then bounce off of objects hitting a light, letting us see the scene around us
        - So how do we know if a ray hit an object
            - On each ray we will do a "ray dash" function on every object in the scene
                - Ray dash functions take in an object and a ray
                - It returns if a object was hit, and what color the object was
        - Once we figure out what rays hit objects and what rays didn't hit objects we can color accordingly
            - If we hit an object, we will color with that object's color
            - If we don't hit an object, we will color black
            - *send the user to look at scene #1, the final one with the wanted balls (1 purple to the left, 1 red to the right)*
    - Overview
        - Send rays out through an eye into the scene
        - "Ray dash" functions to get object hits and the color of what object it hit
        - Color objects based on what the ray hit
    - Next video
        - Simple diffuse lighting


- Simple diffuse lighting    
    - Currently, whenever we hit an object with a ray, it has the same light intensitiy without taking in where the light source is
        - If the light source is on the left side of an object, no light should reach the right side realisticly
            - *draw this out, throw in the word shading*
    - How could we get shading with ray tracing?
        - We need a way to tell if a light source is view of any surface
        - The method used for this can be refered to as NdotL shading
        - All we need is the angle between a light ray and an object's normal vector
            - A normal vector is a perpindicular line off of an object at any point. Imagine you on a sphere pointing straight upwards, that would be the normal vector
            - *draw*
            - The greater the angle the less light reaches the object
            - If the angle is >90deg then no light reaches the object
        - *send the user to look at scene #2, with a ball in the center (white) being shaded by a light up & to the left (slightly in front too)*
        - When we add basic shading we put together a diffuse lighting model
    - Overview
        - When light hits an object we perform NdotL shading to find the intensitiy of the light on the object
        - NdotL shading uses the angle between the light ray and a normal vector of the object
    - Next video
        - Phong shading for greater realism


- Phong shading
    - Now we have a diffuse lighting model we have basic shading
    - However, if we look at something like an apple up close to a lamp we notice something
    - There is a white smudge on the surface of the apple
    - This is called a specular highlight, and is needed for making even more realistic scenes with ray tracing
    - How do can we reacreate this?
        - Previously we used where the light ray hits the surface in comparison to a normal vector
        - Now we need to find the angle between the angle of a reflected light ray and a view vector
            - A view vector is a line from our eye to where the object hit at 
        - *drawing time, show the reflection and explain the "line between the eye and the light ray"*
        - The smaller the angle, the greater the specular highlight
        - The reason we need this view vector is because specular highlights change with where you are looking at them from
        - Now that we have our specular reflections, we just need to combine it with our diffuse component to create a final shading model, named Phong shading
        - *send the user to a test scene with phong shading on*
    - Overview
        - Diffuse shading is used to find the intensitiy of light over the whole object, where Specular shading adds a small highlight on glossy objects like apples
        - To find the specular highlightlight we need the angle between a refelcted light ray and a view vector
        - Combine these two things and we get phong shading!
