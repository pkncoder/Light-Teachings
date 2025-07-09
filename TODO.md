# TODO
This is the file that I save all of the things that I still have to do



## User Interactions
- [ ] Better ui for single item edits & triple item edits
    - [x] Sliding
        - [ ] Better sensitivity sliding
    - [x] Steppers on either side
    - [x] Lighter BG
    - [x] Larger Form
    - [x] ***Blender Based***
    - [ ] Check that it actually works right
    - [ ] Add ranges
- [ ] Make the scene tree disclosures open by default
- [x] Add MacOs menubar commands
    - [x] Saving scenes
    - [x] Opening scenes

## User Interface
- [x] Material editor

## Shader Stuff
- [ ] Full Refactoring of said file
  - [ ] Comments
  - [ ] Code Placement
- [ ] Change the way that sdf opperations are done
  - Idea: Use object data slot 3
    - Indicates an object index that is being opporated on
    - Indicates what opporation "group" is being opporated on
- [ ] Add the point lights
- [x] Bounding Box
- [x] Use multithreading to decouple renderer and SwiftUI
- [ ] Better buffer implimentations?
    - [ ] Example: https://github.com/ralfebert/MetalSwiftUIExample/blob/main/MetalSwiftUIExample/Renderer.swift
- [ ] Better implementation with Uniform struct
- [ ] buildSceneBuffer redo?
- [ ] THREADS

## Background Stuff
- [ ] Recommenting
 - [ ] Done 9/7/25 - d/m/yy at 00:35
- [ ] Attribute protection levels everywhere I can
- [ ] Deconstructors & attribute memory levels (like weak)
- [ ] Sepperate structs and other things into more files
- [ ] Rename files
- [x] RENAME APP STATE
- [ ] Rename Render Settings ?
- [x] Change the passing of scene info around to using envirormentObjects
- [ ] Try to use getter and setter methods to not need .onChange as much
    - [ ] If that goes well maybe even add a update flag to render settings so there's only one for all .onChange in ContentView
- [ ] On a new open the scene tree needs updated
- [ ] Change number Slider State where needed



# Future stuff
This is the stuff in the future for ideas to mark down

## User Interactions

## Shader Stuff
- [ ] Full BVH instead of just a Bounding Box

## Background Stuff

## Major Stuff
- [ ] Make a block language to interact with the renderer
