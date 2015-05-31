globals [
 water-resources
 sun-resources 
 r-factor
 t-factor  
 l-factor  
 f-factor 
]

;;;;plant growing logic
;plants have:  
;part-states list  
;members are: (use getter reporters)
;root-state
;tuber-state
;leaf-state
;fruit-state

;goal-list
;members are: (use getter reporters)
;root-goal
;tuber-goal
;leaf-goal
;fruit-goal

breed [ plants plant ]
breed [ roots root ]
breed [ leaves leaf ]
breed [ fruits fruit ]
breed [ tubers tuber ]

plants-own [ 
  my-roots
  my-leaves
  my-fruits 
  my-tubers 
  
  part-states
  goal-list
]

fruits-own [
  xratio yratio
]

to setup
  ca
  ask patches with [ pxcor != 0  or   pycor != 0 ] [ set pcolor black + 2 ]
  set water-resources 50
  set sun-resources 9
  set r-factor .2
  set t-factor .2
  set l-factor .2
  set f-factor .1
  
  create-a-plant "a"  -.25  -.25
  create-a-plant "b"  .25  -.25
  create-a-plant "a"  -.25  .25
  create-a-plant "b"  .25  .25
  
  reset-ticks
end

;;interface limits controls (will be replaced with the bargraph ui)
to-report left-for-a-without [ anumber ]
  report precision  (1 - (root-a + tuber-a + leaf-a + fruit-a - anumber) ) 1
end

to-report left-for-b-without [ anumber ]
  report precision  (1 - (root-b + tuber-b + leaf-b + fruit-b - anumber) ) 1
end


to run-turn
  ask plants [
   let p harvest-resources 
   spend-resources p
   redraw-plant
  ]
  tick
end


to-report harvest-resources 
  let w min (list water-resources root-of part-states)
  let s min (list sun-resources leaf-of part-states )
  report min (list w s)
end

to spend-resources [units]
  set water-resources water-resources - units
  set sun-resources sun-resources - units
  repeat units [
     let what-index spend-on goal-list
     set goal-list replace-item what-index goal-list (-1 + item what-index goal-list) 
     set part-states replace-item what-index part-states (1 + item what-index part-states) 
  ]
end



to-report root-of [plist]
  report item 0 plist
end
to-report tuber-of [plist]
  report item 1 plist
end
to-report leaf-of [plist]
  report item 2 plist
end
to-report fruit-of [plist]
  report item 3 plist
end

to-report spend-on [glist]
  let choices [ 0 1 2 3 ]
  let i 0
  let selection-list []
  foreach glist [
   repeat ? [ set selection-list lput (item i choices) selection-list ]
   set i i + 1
  ]
  report one-of selection-list
end

to test-spend-on
  let good true
  if spend-on [ 0 0 0 1 ] != 3 [user-message "error with [0 0 0 1]" set good false]
  if spend-on [ 0 0 1 0 ] != 2 [user-message "error with [0 0 1 0]" set good false]
  if spend-on [ 1 0 0 0 ] != 0 [user-message "error with [1 0 0 0]" set good false]
  if (good) [ user-message "pass" ]
end



;;plant construction and redrawing.

to redraw-plant
  let rsize r-factor * item 0 part-states
  let tsize t-factor * item 1 part-states
  let lsize l-factor * item 2 part-states
  let fsize f-factor * item 3 part-states
  
  let tubery 0
  let xc xcor 
  let leafy 0
  
  ask my-roots [ set size rsize ]
  ask my-tubers [ set tubery ycor set size tsize ]
  ask my-leaves [ set size lsize ]
  ask my-fruits [ set size fsize  ]
  ask my-roots [ set ycor tubery - tsize / 4 ]
  ask my-leaves [ set ycor tubery + tsize / 4  set leafy ycor ]
  ask my-fruits [ setxy (xc + xratio * lsize) (leafy + yratio * lsize) ]
end

to create-a-plant [ ptype xc yc  ]
  let initial-part-states [ 1 0 1 0 ]
  let rootsz item 0 initial-part-states
  let tubersz item 1 initial-part-states
  let leavesz item 2 initial-part-states
  let fruitsz item 3 initial-part-states
  create-plants 1 
  [
    setxy xc yc 
    set heading 0
    let r no-turtles
    let l no-turtles
    let t no-turtles
    let f no-turtles
    set color lime
    set part-states initial-part-states
    hatch-roots 1 [ set r self set color yellow  set shape "root" set heading 180 set size rootsz fd .5 * tubersz  ]
    hatch-leaves 1 [ set l self set color lime  set shape "leaf" set heading 0 set size leavesz fd .5 * tubersz 
      hatch-fruits 1 [ set heading 0 set f self set color orange  set shape "fruit" set size .5 * fruitsz set xratio (random-float -.2  + random-float .2) set yratio (.2   + random-float .2)   ]
       ]
    hatch-tubers 1 [ set t self set color brown  set shape "tuber" set size tubersz  ]
    ht
    set my-roots r
    set my-leaves l
    set my-tubers t
    set my-fruits f
    
    ifelse (ptype = "a") 
    [ set goal-list (list (10 * root-a) (10 * tuber-a) (10 * leaf-a) (10 * fruit-a)) ]
    [ set goal-list (list (10 * root-b) (10 * tuber-b) (10 * leaf-b) (10 * fruit-b)) ]
    set goal-list map round goal-list
    
    redraw-plant  
  ]
  
end

to plant-test
 create-a-plant "a"  0  0
end

@#$#@#$#@
GRAPHICS-WINDOW
246
52
616
443
1
1
120.0
1
10
1
1
1
0
1
1
1
-1
1
-1
1
0
0
1
ticks
30.0

SLIDER
37
144
70
293
root-a
root-a
0
left-for-a-without root-a
0.4
.1
1
NIL
VERTICAL

SLIDER
83
144
116
293
tuber-a
tuber-a
0
left-for-a-without tuber-a
0.2
.1
1
NIL
VERTICAL

SLIDER
132
144
165
293
leaf-a
leaf-a
0
left-for-a-without leaf-a
0.2
.1
1
NIL
VERTICAL

SLIDER
179
144
212
293
fruit-a
fruit-a
0
left-for-a-without fruit-a
0.2
.1
1
NIL
VERTICAL

SLIDER
654
152
687
302
root-b
root-b
0
left-for-b-without root-b
0.2
.1
1
NIL
VERTICAL

SLIDER
701
152
734
302
tuber-b
tuber-b
0
left-for-b-without tuber-b
0.3
.1
1
NIL
VERTICAL

SLIDER
747
152
780
302
leaf-b
leaf-b
0
left-for-b-without leaf-b
0.2
.1
1
NIL
VERTICAL

SLIDER
800
152
833
302
fruit-b
fruit-b
0
left-for-b-without fruit-b
0.3
.1
1
NIL
VERTICAL

MONITOR
68
333
222
378
Sum Of Allocations - A
1 - left-for-a-without 0
1
1
11

MONITOR
657
347
806
392
Sum of Allocations - B
1 - left-for-b-without 0
17
1
11

MONITOR
133
63
238
108
NIL
sun-resources
17
1
11

MONITOR
133
17
239
62
NIL
water-resources
17
1
11

BUTTON
19
16
85
49
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
75
98
108
NIL
run-turn
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
664
29
727
62
go
if sun-resources = 0 [ stop ]\nrun-turn
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

fruit
true
0
Circle -7500403 true true 134 133 32
Circle -7500403 true true 128 114 18
Circle -7500403 true true 112 145 18
Circle -7500403 true true 165 122 18
Circle -7500403 true true 160 160 18
Circle -7500403 true true 121 160 18
Circle -7500403 true true 147 114 18
Circle -7500403 true true 117 129 18
Circle -7500403 true true 141 167 18
Circle -7500403 true true 169 142 18

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
true
0
Line -7500403 true 150 150 150 0
Line -7500403 true 150 90 90 60
Line -7500403 true 120 75 90 90
Line -7500403 true 105 66 105 51
Line -7500403 true 150 75 180 30
Line -7500403 true 171 44 201 44
Line -7500403 true 189 44 194 56
Line -7500403 true 150 125 198 93
Line -7500403 true 149 37 132 13
Line -7500403 true 139 22 130 22
Line -7500403 true 184 103 191 77
Line -7500403 true 190 83 206 75
Line -7500403 true 170 113 197 109
Line -7500403 true 149 58 140 47
Rectangle -7500403 true true 147 9 154 148
Polygon -7500403 true true 148 85 109 67 108 47 104 44 104 63 88 56 82 59 117 75 91 86 83 96 120 80 149 94
Polygon -7500403 true true 154 119 184 98 190 69 194 71 192 79 208 74 208 78 191 85 191 97 199 90 200 96 177 108 203 108 201 111 167 115 155 126
Polygon -7500403 true true 154 66 183 18 184 29 175 41 209 42 204 48 194 48 200 55 193 54 187 47 173 45 155 74
Polygon -7500403 true true 151 65 131 41 141 44 151 56 152 40 139 24 121 24 116 18 135 20 129 9 136 6
Polygon -7500403 true true 150 136 132 119 109 121 106 116 127 117 121 91 127 93 132 112 152 131
Polygon -7500403 true true 153 106 164 92 175 92 180 87 169 87 182 72 201 67 201 62 181 68 176 53 172 55 178 70 167 81 167 72 164 75 164 88 156 95 152 97
Polygon -7500403 true true 153 53 163 29 172 28 172 26 165 26 171 15 180 13 180 9 171 12 165 5 162 6 169 16 155 39
Polygon -7500403 true true 150 76 134 60 126 36 124 33 131 58 122 52 115 42 114 47 119 54 95 66 97 69 122 57 151 79
Polygon -7500403 true true 142 123 138 103 143 94 142 92 139 97 128 90 128 94 136 101 139 122

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

root
true
0
Line -7500403 true 150 150 150 0
Line -7500403 true 150 90 90 60
Line -7500403 true 120 75 90 90
Line -7500403 true 105 66 105 51
Line -7500403 true 150 75 180 30
Line -7500403 true 171 44 201 44
Line -7500403 true 189 44 194 56
Line -7500403 true 150 125 198 93
Line -7500403 true 149 37 132 13
Line -7500403 true 139 22 130 22
Line -7500403 true 184 103 191 77
Line -7500403 true 190 83 206 75
Line -7500403 true 170 113 197 109
Line -7500403 true 149 58 140 47
Rectangle -7500403 true true 147 -1 155 148
Polygon -7500403 true true 148 85 109 67 108 47 104 44 104 63 88 56 82 59 117 75 91 86 83 96 120 80 149 94
Polygon -7500403 true true 154 119 184 98 190 69 194 71 192 79 208 74 208 78 191 85 191 97 199 90 200 96 177 108 203 108 201 111 167 115 155 126
Polygon -7500403 true true 154 66 183 18 184 29 175 41 209 42 204 48 194 48 200 55 193 54 187 47 173 45 155 74
Polygon -7500403 true true 151 65 131 41 141 44 151 56 152 40 139 24 121 24 116 18 135 20 129 9 136 6
Polygon -7500403 true true 150 135 120 120 105 135 98 135 109 127 75 130 77 124 97 123 112 123 119 116 153 131
Polygon -7500403 true true 153 117 117 104 92 114 80 114 111 101 66 85 55 82 53 74 78 83 57 49 69 59 88 89 129 103 120 62 126 66 133 104
Polygon -7500403 true true 154 143 178 139 200 149 210 150 189 138 217 133 244 130 257 136 270 134 254 129 282 115 275 111 252 124 225 127 258 91 275 94 285 83 280 79 276 81 273 87 261 85 251 62 246 62 255 84 232 110 230 86 243 78 243 75 239 71 227 80 214 60 206 64 223 85 227 106 213 98 208 101 229 114 217 126 194 130 167 83 166 85 174 99 164 99 164 104 173 102 189 128 189 131 153 138
Polygon -7500403 true true 147 146 99 149 76 140 62 143 56 138 72 137 38 125 15 141 14 136 34 122 26 81 33 81 40 122 70 133 58 93 64 93 76 134 106 147 122 126 126 126 112 144 150 140

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

tuber
true
0
Circle -7500403 true true 75 75 150
Circle -7500403 true true 86 161 67
Circle -7500403 true true 101 71 67
Circle -7500403 true true 176 131 67

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
