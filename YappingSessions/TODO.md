# TODO
This is the file that I save all of the things that I still have to do



## User Interactions
- [ ] Better ui for single item edits & triple item edits
    - [x] Sliding
        - [x] Better sensitivity sliding
    - [ ] Better step sizes?
    - [x] Steppers on either side
    - [x] Lighter BG
    - [x] Larger Form
    - [x] ***Blender Based***
    - [x] Check that it actually works right
        - I way over complicated it, now it's 3 lines, no "numberSliderState" and an .onChange for clamps   (╯°□°)╯︵ ┻━┻
    - [x] Add ranges
- [ ] Make the scene tree disclosures open by default
- [x] Add MacOs menubar commands
    - [x] Saving scenes
    - [x] Opening scenes
- [x] Plus Minus objects & mats
- [x] Changing object types

## User Interface
- [x] Material editor
- [x] Fix the scene tree when updateed
- [ ] Keep scene tree open & in same state after update (add / remove)

## Shader Stuff
- [ ] Full Refactoring of said file
  - [ ] Comments
  - [ ] Code Placement
- [x] Add the point lights
- [x] Bounding Box
- [x] Use multithreading to decouple renderer and SwiftUI
- [ ] Better buffer implimentations?
    - Example: https://github.com/ralfebert/MetalSwiftUIExample/blob/main/MetalSwiftUIExample/Renderer.swift
- [ ] Better implementation with Uniform struct
- [x] buildSceneBuffer redo
- [x] Define the byte counts for the arrays
- [x] THREADS
- [x] Fix BB error with planes
- [x] Split up into multiple files (and put in own dir)
- Shading models
    - [x] BDRF
    - [x] Simple Shading (NdotL)
    - [x] Hit detetect
    - [x] Hit detetect w/ color
    - [x] Phong
- [x] Fill up the BDRF class to have a better use in the fragmentMain
- [x] Make the modelinator have a shadows boolean
- [x] Make a shadows override box
    - 0 = default based on shading model
    - 1 = shadows off
    - 2 = shadows on
- [ ] Ambient

## Background Stuff
- [ ] Recommenting
 - [x] Done 9/7/25 - d/m/yy at 00:35
 - [x] Done 18/7/25 - d/m/yy at 5:46 - Full done on NumberSliderState (only that though)
- [x] Attribute protection levels everywhere I can
- [x] Sepperate structs and other things into more files
- [x] RENAME APP STATE
- [ ] Rename Render Settings ?
- [x] Change the passing of scene info around to using envirormentObjects
- [ ] Try to use getter and setter methods to not need .onChange as much
- [x] Try to remove the 2 .onChange(s) in ContentView and only have 1
    - Maybe an update flag in RendererSettings
- [x] Change number Slider State where needed
    - No idea what I did to need to have this

## Errors
- [x] Error with .Full updates persisting and not being overritten
- [x] New items not showing up??
    - Fixed itself (21/7/2025 - dd/m/yyyy). No idea what was casuing it
- [x] Object type editor isn't working right
    - Always use object clone
- [x] Deleting objects isn't working either, duplication again
    - I was using object instead of object clone

## Big Stuff
- [ ] Change the way that sdf opperations are done
  - Idea: Use object data slot 3
    - Indicates an object index that is being opporated on
    - Indicates what opporation "group" is being opporated on



# Future stuff
This is the stuff in the future for ideas to mark down

## User Interactions
- [ ] Add a circle-like dragable for updating x & y at the same time
- [ ] Gizmos

## Shader Stuff
- [ ] Full BVH instead of just a Bounding Box

## Background Stuff

## Major Stuff
- [ ] Make a block language to interact with the renderer
