# Problem
Update data is scuffed and if a .Full type is made will never be overwritten



# How it works (before)
- Change is made
    - Object is modified
        - .onChange in the ObjectEditor detects a change in it's binding
            - if update type in rendererSetting's update data is not .Full continue
            - Make new update data w/ type .Object & it's own index reference
    - Material is modified 
        - .onChange in the MaterialEditor detects a change in it's binding
            - if update type in rendererSetting's update data is not .Full continue
            - Make new update data w/ type .Material & it's own index reference
    - Obj/Mat is added
        - Increase array length
        - Make new update data w/ type .Full & index array max
    - Obj/Mat is deleted
        - Decrease array length
        - Make new update data w/ type .Full & index array max
    - File is opened
        - Gen new scene wrapper
        - Make new update data w/ type .Full & index -1

## Differences
- Obj/Mat is modified
    - Not .Full update type
- Obj/Mat is added/deleted
    - Not -1 index
- File is opened
    - -1 index


# Scenario
1. Obj is added (index 7)
2. Existing obj is modified (index 2)


# How to fix
- Obj/Mat is modified
    - When copy is edited it's detected and sent through
        - If skip flag is set toggle it and return out of function
        - Else, set a "skip" flag and update the original
    - When original is modified
        - If skip flag is set, toggle it and return out of function
        - Else, set skip flag and copy new stuff to the copy


# Results?
IT WORKED YIIIPPPPPPPPPPEEEE
