# Welcome to the Advanced-Movement-System-Godot

The Project is made using [Godot](https://github.com/godotengine/godot) 4 (alpha)

you can get Godot 4 Alpha 16 here : https://godotengine.org/article/dev-snapshot-godot-4-0-alpha-16

## Method 1 (adding to existing project)
1- copy the files to your Godot project 

2- copy and paste the following into your project's "project.godot" file 

```
[input]

forward={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":87,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
back={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":83,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":32,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
sprint={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":16777237,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
aim={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":2,"pressed":false,"double_click":false,"script":null)
]
}
crouch={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":16777238,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
interaction={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":70,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
switch_camera_view={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":67,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
ragdoll={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":88,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
flashlight={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":76,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
EnableSDFGI={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":71,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
exit={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"pressed":false,"keycode":16777217,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
fire={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"store_command":true,"alt_pressed":false,"shift_pressed":false,"meta_pressed":false,"command_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":1,"pressed":false,"double_click":false,"script":null)
]
}
```

3- autoload the "Global.gd" GDscript, you can find it in "res://addons/AMSG/Global.gd"

## Method 2 (creating a new project using the amsg files)

just remove ".amsg" from the file "project.godot.amsg"
open the project and done.

# This project is a template for creating advanced Third/First Person movement in [GODOT](https://github.com/godotengine/godot)
You may use it in any other camera type like RTS, but you will need to tweak it yourself.

# For how to fix the armature wrong bones orientation and create a control rig for mixamo character in blender to animate the character :
https://youtu.be/zfaskQ2BK1s .

# Guide for combining animations from mixamo
https://youtu.be/3NrsSdEUSWI .

# Guide for importing animations from blender (If you don't have a ready game rig (Control Rig only)
https://youtu.be/qwz9aPdVoFg .

# if you don't know what does this (game rig,control rig) mean, then this will help 
https://youtube.com/playlist?list=PLdcL5aF8ZcJvCyqWeCBYVGKbQgrQngen3) .


## How to Move (Key Bindings) :

(W,A,S,D) Move In The Four Directions

(Shift) Run

(Shift) Sprint (Press Shift Again before the character returns to walking (0.4 second))

(C) Long Press : Switch First/Third Person View

(C) One Press : Switch Camera Angle (Right Shoulder,Left Shoulder,Head(Center) )


(Space) Jump

(CTRL) Crouch/UnCrouch



(F) Interaction

(L) Flashlight

(G) To toggle High graphics : SDFGI (Global illumination),SSIL, SSAO,SSR,Glow
