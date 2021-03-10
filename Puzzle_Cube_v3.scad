// OpenSCAD Puzzle Cube
// (c) 2021, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.

// Which one would you like to see?
part = "box"; // [box:Box,lower:Lower Half,upper:Upper Half,core:Core]

// Use for command line option '-Dgen=n', overrides 'part'
// 0-7+ - generate parts individually in assembled positions. Combine with MeshLab.
// 0 box
// 1 ring gears and jaws
// 2 sun gear and knob
// 3+ planet gears
gen=undef;

// Overall scale (to avoid small numbers, internal faces or non-manifold edges)
scl = 1000;

// External dimensions of cube
cube_w_ = 76.2;
cube_w = cube_w_*scl;

// Pegs to navigate labyrinth
pegs=2;

// Height of planetary layers (layer_h will be subtracted from gears>0). Non-uniform heights will reveal bugs.
gh_ = 8*[1, 1, 1, 1, 1, 1];
gh = scl*gh_;
// Modules, planetary layers
modules = len(gh); //[2:1:3]

// Outer diameter of core
outer_d_ = 40.5; //[30:0.2:300]
// +9/2
outer_d = scl*outer_d_;
// Ring wall thickness (relative pitch radius)
wall_ = 3.1; //[0:0.1:20]
wall = scl*wall_;

// Negative - tinkercad import will fill in hollow shapes (most unhelpful). This will also save a subtraction operation ie. This will give us the shape to subtract from the art cube directly.
Negative = 1;				// [1:No, 0.5:Yes, 0:Half]

// Shaft diameter
shaft_d_ = 6; //[0:0.1:25]
shaft_d = scl*shaft_d_;
// Spring outer diameter
spring_d_ = 5; //[0:0.1:25]
spring_d = scl*spring_d_;
// False gate depth
fg_ = 1; //[0:0.1:5]
fg = scl*fg_;

// Width of outer teeth
outer_w_=3; //[0:0.1:10]
outer_w=scl*outer_w_;
// Aspect ratio of teeth (depth relative to width)
teeth_a=0.75;
// Aspect ratio of core teeth (depth relative to width)
teeth_a2=0.5;
// Offset of wider teeth (angle)
outer_o=2; //[0:0.1:10]
// Outside Gear depth ratio
depth_ratio=0.25; //[0:0.05:1]
// Inside Gear depth ratio
depth_ratio2=0.5; //[0:0.05:1]
// Gear clearance
tol_=0.2; //[0:0.01:0.5]
tol=scl*tol_;
// pressure angle
P=30; //[30:60]
// Bearing height
bearing_h_ = 1;  //[0:0.01:5]
bearing_h = scl*bearing_h_;
// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
layer_h = scl*layer_h_;
// height of rim (ideally a multiple of layer_h
rim_h=3;
// Chamfer exposed gears, top - watch fingers
ChamferGearsTop = 0;				// [1:No, 0.5:Yes, 0:Half]
// Chamfer exposed gears, bottom - help with elephant's foot/tolerance
ChamferGearsBottom = 0;				// [1:No, 0.5:Yes, 0:Half]

// Tolerances for geometry connections.
AT_=1/64;
// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;
// Curve resolution settings, number of segments
$fn=96;

g=gen;

// Calibration cube (invalid input)
if (g==99) {
    translate(scl*10*[-1,-1,0])cube(scl*20);
}

// Tolerances for geometry connections.
AT=scl/64;
ST=AT*2;
TT=AT/2;

core_h=addl(gh,modules);
core_h2 = (cube_w-core_h)/2;

r=1*scl+outer_d/2-4*tol;
h=core_h2;
d=h/4;

// diameter of core fins, smaller allows assembly
//fin=cube_w/2-2*scl-2*tol;
fin=outer_d/2+6*scl;

// travel of inner slider
tra=core_h/2-2.5*scl-2*layer_h;
of=7.5*scl+2*layer_h; // initial offset, once engaged
st=(tra-of)/3;

// (translate,rotate) start, finish, steps, power
// it, ir1, ir2, t, r1, r2, s, pt, pr1, pr2
maze=[
    [0,0,0,of,40,0,10,1,1,1],
    [of,40,0,of+st,40,40,10,1,1,1],
    [of+st,40,40,of+2*st,80,40,10,1,1,1],
    [of+2*st,80,40,of+3*st,80,80,10,1,1,1],
    [of+3*st,80,80,of+2*st,120,80,10,1,1,1],
    [of+2*st,120,80,of+st,120,120,10,1,1,1],
    [of+st,120,120,of,160,120,10,1,1,1],
    [of,160,120,of+st,160,160,10,1,1,1],
    [of+st,160,160,of+2*st,200,160,10,1,1,1],
];

// Box
if(g==0||g==undef&&(part=="box"||part=="lower"||part=="upper"))difference(){
    if(Negative)cube(cube_w,center=true);
    lament();
}

module lament(){
    if(g==0||part=="box"||part=="lower"){
        lamenthalf(turns=true)children();
        // central shaft
        difference(){
            translate([0,0,core_h2-cube_w/2-layer_h-AT])
                cylinder(r=outer_d/2-7*scl-4*tol,h=core_h/2+2.5*scl+layer_h+AT);
            // maze path
            for(j=[0:pegs-1],k=[0:1],l=[0:len(maze)-1])
                path(maze[l][0],maze[l][1],maze[l][3],maze[l][4],maze[l][6],maze[l][7],maze[l][9])rotate(j*360/pegs)
                    translate([outer_d/2-7*scl-4*tol+AT,0,k?-layer_h:2.5*scl+layer_h-core_h/2])
                        mirror([1,0,1])cylinder(r1=2.5*scl,r2=0.5*scl,h=2*scl+AT,$fn=24);
        }
    
        // post
        translate([0,0,2.5*scl-TT])cylinder(r=outer_d/2-11*scl-10*tol,h=10*scl+AT);
        // key
        translate([0,0,6.5*scl-layer_h])intersection(){
            rotate_extrude(convexity=5)
                polygon(points=[
        [outer_d/2-12*scl-10*tol,4*scl+2*scl],
        [outer_d/2-11*scl-10*tol,4*scl+2*scl],
        [outer_d/2-9*scl-10*tol,6*scl-2*scl/sqrt(3)],
        [outer_d/2-9*scl-10*tol,2*scl/sqrt(3)+2*scl],
        [outer_d/2-11*scl-10*tol,2*scl],
        [outer_d/2-12*scl-10*tol,2*scl]]);
            for(j=[0:3]){
                rotate((j?j*360/3:180)+360/16+360/32+180)
                    translate([outer_d/4,0,core_h/4+scl])cube([outer_d/2,(j<3?4:6)*scl,core_h/2+2*scl],center=true);
            }
        }
    }
    if(g==0||part=="box"||part=="upper"){
        mirror([0,0,1])mirror([0,1,0])lamenthalf()mirror([0,0,1])mirror([0,1,0])children();
        // central shaft
        rotate(180)difference(){
            translate([0,0,2.5*scl+layer_h])cylinder(r=outer_d/2-7*scl-4*tol,h=core_h/2-2.5*scl-layer_h+layer_h+AT);
            
            // maze path
            for(j=[0:pegs-1],k=[0:1],l=[0:len(maze)-1])
                path(maze[l][0],maze[l][2],maze[l][3],maze[l][5],maze[l][6],maze[l][7],maze[l][9])rotate(j*360/pegs)
                    translate([outer_d/2-7*scl-4*tol+AT,0,k?-layer_h:2.5*scl+layer_h-core_h/2])
                        mirror([1,0,1])cylinder(r1=2.5*scl,r2=0.5*scl,h=2*scl+AT,$fn=24);
            // socket
            translate([0,0,2.5*scl-TT])cylinder(r=outer_d/2-11*scl-8*tol,h=10*scl+2*tol+TT);
            translate([0,0,6.5*scl-layer_h])
                rotate_extrude(convexity=5)
                        polygon(points=[
                [outer_d/2-12*scl-8*tol,4*scl+2*scl],
                [outer_d/2-11*scl-8*tol,4*scl+2*scl],
                [outer_d/2-9*scl-8*tol,4*scl+2*scl-2*scl/sqrt(3)],
                [outer_d/2-9*scl-8*tol,2*scl/sqrt(3)+2*scl],
                [outer_d/2-11*scl-8*tol,2*scl],
                [outer_d/2-12*scl-8*tol,2*scl]]);
            translate([0,0,2.5*scl])intersection(){
                rotate_extrude(convexity=5)
                        polygon(points=[
                [outer_d/2-12*scl-8*tol,10*scl-layer_h],
                [outer_d/2-11*scl-8*tol,10*scl-layer_h],
                [outer_d/2-9*scl-8*tol,10*scl-2*scl/sqrt(3)-layer_h],
                [outer_d/2-9*scl-8*tol,-TT],
                [outer_d/2-11*scl-8*tol,-TT],
                [outer_d/2-12*scl-8*tol,-TT]]);
                for(j=[0:3]){
                    rotate((j?j*360/3:180)+360/16+360/32)
                        translate([outer_d/4,0,core_h/4+scl])cube([outer_d/2,(j<3?4:6)*scl+4*tol,core_h/2+2*scl],center=true);
                }
            }
            // tapered bottom
            translate([0,0,2.5*scl+layer_h])rotate_extrude()scale([1,3/4,1]){
                translate([outer_d/2-9*scl-5*tol+AT,layer_h*4/3,0])rotate(-45)square(5*scl);
                translate([outer_d/2-9*scl-7*tol,layer_h*4/3,0])rotate(-180-45)square(5*scl);
                translate([outer_d/2-9*scl-5*tol+AT,0,0])square(layer_h*4/3);
                translate([outer_d/2-9*scl-7*tol,0,0])rotate(90)square(layer_h*4/3);
            }
        }
    }
}

module lamenthalf(turns=false){
    // progressive bridging (experimental, rough)
    /*if(!turns){
        translate([0,0,layer_h/2-core_h/2])for(i=[0:4:15])hull(){
            intersection(){
                rotate([0,0,i*360/16])
                    translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                rotate([0,0,(i-1)*360/16])
                    translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                difference(){
                    cylinder(r=outer_d/2+2*tol+AT,h=layer_h,center=true);
                    cylinder(r=outer_d/2+2*tol,h=layer_h+AT,center=true);
                }
            }
            intersection(){
                rotate([0,0,(i+2)*360/16])
                    translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                rotate([0,0,(i+1)*360/16])
                    translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                difference(){
                    cylinder(r=outer_d/2+2*tol+AT,h=layer_h,center=true);
                    cylinder(r=outer_d/2+2*tol,h=layer_h+AT,center=true);
                }
            }
        }
        translate([0,0,layer_h/2-core_h/2-layer_h])for(i=[0:4:15])hull(){
            intersection(){
                rotate([0,0,i*360/16])
                    translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                rotate([0,0,(i-1)*360/16])
                    translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                difference(){
                    cylinder(r=outer_d/2+2*tol+AT,h=layer_h,center=true);
                    cylinder(r=outer_d/2+2*tol,h=layer_h+AT,center=true);
                }
            }
            intersection(){
                rotate([0,0,(i+2)*360/16])
                    translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                rotate([0,0,(i+1)*360/16])
                    translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                difference(){
                    cylinder(r=outer_d/2+2*tol+AT,h=layer_h,center=true);
                    cylinder(r=outer_d/2+2*tol,h=layer_h+AT,center=true);
                }
            }
        }
        translate([0,0,layer_h/2-core_h/2-layer_h])for(i=[2:4:15])hull(){
            intersection(){
                rotate([0,0,i*360/16])
                    translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                rotate([0,0,(i-1)*360/16])
                    translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                difference(){
                    cylinder(r=outer_d/2+2*tol+AT,h=layer_h,center=true);
                    cylinder(r=outer_d/2+2*tol,h=layer_h+AT,center=true);
                }
            }
            intersection(){
                rotate([0,0,(i+2)*360/16])
                    translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                rotate([0,0,(i+1)*360/16])
                    translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                difference(){
                    cylinder(r=outer_d/2+2*tol+AT,h=layer_h,center=true);
                    cylinder(r=outer_d/2+2*tol,h=layer_h+AT,center=true);
                }
            }
        }
    }*/
    difference(){
        union(){
            translate([0,0,-cube_w/2])
                cylinder(d=outer_d,h=core_h2-tol,$fn=96);
            for (i=[0:2:15]){
                difference(){
                    intersection(){
                        cube(cube_w,center=true);
                        rotate([0,0,i*360/16])
                            translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                        rotate([0,0,(i-1)*360/16])
                            translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                    }
                    //difference(){ // TODO: flatten positive and negative volumes
                    translate([0,0,core_h2-tol-cube_w/2])
                        cylinder(d=outer_d+4*tol,h=cube_w-core_h2+tol+AT);
                    translate([0,0,-AT-cube_w/2])
                        cylinder(d=outer_d-AT,h=core_h2);
                }
            }
        }
        // Dial spool track
        // TODO: parameterise dial diameter and hard coded offsets, scope global variables
        translate([0,0,-cube_w/2])rotate_extrude()
            polygon( points=[
                [r,-AT],[r,1*scl],[r-2.5*d,2*d],[r-2.5*d,h-1.5*d],[r-d,h-1*scl],[r-d,h+AT],[r-d-2*tol,h+AT],
                [r-d-2*tol,h-1*scl],[r-2.5*d-2*tol,h-1.5*d],[r-2.5*d-2*tol,2*d],[r-2*tol,1*scl],[r-2*tol,-AT]]);
        // Locking spool (experimental)
        //translate([0,0,-cube_w/2])rotate_extrude()
            //polygon( points=[
                //[r,-AT],[r,2*scl],[r+d,1.5*d],[r+d,1.5*d+2*scl],[r-d,h-2*scl],[r-d,h+AT],[r-d-2*tol,h+AT],
                //[r-d-2*tol,h-2*scl],[r+d-2*tol,1.5*d+2*scl],[r+d-2*tol,1.5*d],[r-2*tol,2*scl],[r-2*tol,-AT]]);

        translate([0,0,core_h2-cube_w/2])intersection(){
            r=(outer_d+outer_w/sqrt(2))/2+2*tol;
            r1=outer_d/2+2*tol;
            h=core_h+core_h2-2*scl;
            d=fin-r1;
            dz=d/sqrt(3);
            rotate_extrude()
                polygon(points=[[r1-d-AT,2*scl],[r1,2*scl],[r1+d,dz+2*scl],[r1+d,h-dz],[r1,h],[r1-d-AT,h]]);
            // outer teeth
            for(j = [1:8]){
                intersection(){
                    rotate(-90+j*360/8)
                        translate([0,2*scl,0])mirror([1,0,0])cube([4*r1+d+AT,r1+d+AT,h]);
                    rotate(90-360/16+j*360/8)
                        translate([0,2*scl,0])cube([4*r1+d+AT,r1+d+AT,h]);
                }
            }
        }
    }
}

// Core
if(false||g==1||g==undef&&part=="core"){
    difference(){
        // positive volume
        union(){
            
            mir()intersection(){
                r=(outer_d+outer_w/sqrt(2))/2+2*tol;
                r1=outer_d/2;
                h=core_h+core_h2-2*scl-cube_w/2;
                d=fin-r1-2*tol;
                dz=d/sqrt(3);
                rotate_extrude()
                    polygon(points=[[r1-d-AT,2*scl],[r1,2*scl],[r1+d,dz+2*scl],[r1+d,h-dz],[r1,h],[r1-d-AT,h]]);
                // outer teeth
                for(j = [1:8]){
                    intersection(){
                        rotate(-90+j*360/8+360/16)
                            translate([0,2*scl+2*tol,0])mirror([1,0,0])cube([4*r1+d+AT,r1+d+AT,h]);
                        rotate(90-360/16+j*360/8+360/16)
                            translate([0,2*scl+2*tol,0])cube([4*r1+d+AT,r1+d+AT,h]);
                    }
                }
            }

            translate([0,0,core_h2-cube_w/2])
                cylinder(r=outer_d/2,h=core_h);
               
        }
        // negative volume
        
        // spinning fins
        rotate_extrude(convexity=5)
            polygon(points=[[outer_d/2+2*scl,core_h/2-2*scl+layer_h],[outer_d/2,core_h/2-2*scl+layer_h],[outer_d/2-2*scl,core_h/2-2*scl-2*scl/sqrt(3)+layer_h],[outer_d/2-2*scl,2*scl/sqrt(3)+2*scl-layer_h],[outer_d/2,2*scl-layer_h],[outer_d/2+2*scl,2*scl-layer_h],[outer_d/2+2*scl,2*scl-2*layer_h],[outer_d/2-tol,2*scl-2*layer_h],[outer_d/2-2*scl-2*tol,2*scl/sqrt(3)+2*scl-layer_h],[outer_d/2-2*scl-2*tol,core_h/2-2*scl-2*scl/sqrt(3)+layer_h],[outer_d/2-tol,core_h/2-2*scl+2*layer_h],[outer_d/2+2*scl,core_h/2-2*scl+2*layer_h]]);

        // slider tracks
        translate([0,0,-core_h/2])intersection(){
            rotate_extrude(convexity=5)
                polygon(points=[[outer_d/2-7*scl,4*scl+tra+2*scl],[outer_d/2-5*scl,4*scl+tra+2*scl],[outer_d/2-3*scl,4*scl+tra+2*scl-2*scl/sqrt(3)],[outer_d/2-3*scl,2*scl/sqrt(3)+2*scl],[outer_d/2-5*scl,2*scl],[outer_d/2-7*scl,2*scl]]);
            for(j = [1:8]){
                rotate(j*360/8+360/16+360/32)
                    translate([0,-2*scl-2*tol,0])cube([outer_d/2,4*scl+4*tol,core_h]);
            }
        }

        // payload
        translate([0,0,core_h2-cube_w/2-TT])
            cylinder(r=outer_d/2-5*scl,h=core_h+AT);
        
        // tapered bottom
        translate([0,0,-core_h/2])rotate_extrude()scale([1,3/4,1]){
            translate([outer_d/2-2.5*scl+tol+AT,layer_h*4/3,0])rotate(-45)square(3.5*scl);
            translate([outer_d/2-2.5*scl-tol,layer_h*4/3,0])rotate(-180-45)square(3.5*scl);
            translate([outer_d/2-2.5*scl+tol+AT,0,0])square(layer_h*4/3);
            translate([outer_d/2-2.5*scl-tol,0,0])rotate(90)square(layer_h*4/3);
        }
    }
}

// Inner slider
if(false||g==1||g==undef&&part=="core"){
    translate([0,0,core_h2-cube_w/2])difference(){
        cylinder(r=outer_d/2-5*scl-2*tol,h=core_h/2+2.5*scl);
        translate([0,0,-TT])cylinder(r=outer_d/2-7*scl-2*tol,h=core_h/2+2.5*scl+AT);
            
        // tapered bottom
        translate([0,0,0])rotate_extrude()scale([1,3/4,1]){
            translate([outer_d/2-7*scl+AT,layer_h*4/3,0])rotate(-45)square(5*scl);
            //translate([outer_d/2-7*scl-2*tol,0,0])rotate(-180-45)square(5*scl);
            translate([outer_d/2-7*scl+AT,0,0])square(layer_h*4/3);
            //translate([outer_d/2-7*scl-2*tol,0,0])rotate(90)square(layer_h*4/3);
        }
    }

    // slider teeth
    translate([0,0,-core_h/2])intersection(){
        rotate_extrude(convexity=5)
            polygon(points=[[outer_d/2-6*scl-2*tol,4*scl+2*scl],[outer_d/2-5*scl-2*tol,4*scl+2*scl],[outer_d/2-3*scl-2*tol,4*scl+2*scl-2*scl/sqrt(3)],[outer_d/2-3*scl-2*tol,2*scl/sqrt(3)+2*scl],[outer_d/2-5*scl-2*tol,2*scl],[outer_d/2-6*scl-2*tol,2*scl]]);
        for(j = [1:8]){
            rotate(j*360/8+360/16+360/32)
                translate([0,-2*scl,0])cube([outer_d/2,4*scl,core_h/2+2*scl]);
        }
    }
    
    // maze teeth
    for(j=[0:pegs-1],k=[0:1])rotate(j*360/pegs)
        translate([outer_d/2-7*scl-2*tol+AT,0,k?-layer_h:2.5*scl+layer_h-core_h/2])
            mirror([1,0,1])cylinder(r1=2.5*scl,r2=0.5*scl,h=2*scl+AT,$fn=24);
}

module mir(){
    children();
    mirror([1,0,0])mirror([0,0,1])children();
}

// cut a path segment, translate t, rotate r over s steps
module path(it=0,ir=0,t=0,r=0,s=0,pt=1,pr=1){
    translate([0,0,it])rotate(ir)if(s)for(i=[1:s])hull(){
        translate([0,0,(t-it)*pow(i/s,pt)])rotate((r-ir)*pow(i/s,pr))children();
        translate([0,0,(t-it)*pow((i-1)/s,pt)])rotate((r-ir)*pow((i-1)/s,pr))children();
    }else children();
}

// Recursively sums all elements of a list up to n'th element, counting from 1
function addl(list,n=0) = n>0?(n<=len(list)?list[n-1]+addl(list,n-1):list[n-1]):0;