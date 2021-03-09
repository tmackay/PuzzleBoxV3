// Overall scale (to avoid small numbers, internal faces or non-manifold edges)
scl = 1000;

// External dimensions of cube
cube_w_ = 76.2;
cube_w = cube_w_*scl;

// Outer diameter of core
outer_d_ = 40.5; //[30:0.2:300]
// +9/2
outer_d = scl*outer_d_;

// Width of outer teeth
outer_w_=3; //[0:0.1:10]
outer_w=scl*outer_w_;

// Pegs to navigate labyrinth
pegs=2;

// Gear clearance
tol_=0.2; //[0:0.01:0.5]
tol=scl*tol_;

// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
layer_h = scl*layer_h_;

// Height of planetary layers (layer_h will be subtracted from gears>0). Non-uniform heights will reveal bugs.
gh_ = 8*[1, 1, 1, 1, 1, 1];
gh = scl*gh_;

// Tolerances for geometry connections.
AT_=1/64;
// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;
// Curve resolution settings, number of segments
$fn=96;
// Tolerances for geometry connections.
AT=scl/64;
ST=AT*2;
TT=AT/2;

// Modules, planetary layers
modules = len(gh); //[2:1:3]

core_h=addl(gh,modules);
core_h2 = (cube_w-core_h)/2;

h=core_h2;
d=h/4;

// Recursively sums all elements of a list up to n'th element, counting from 1
function addl(list,n=0) = n>0?(n<=len(list)?list[n-1]+addl(list,n-1):list[n-1]):0;

module mir(){
    children();
    mirror([1,0,0])mirror([0,0,1])children();
}

ld=8.1;

// diameter of core fins, smaller allows assembly
//fin=cube_w/2-2*scl-2*tol;
fin=outer_d/2+2*scl+2*tol;

// travel of inner slider
tra=core_h/2-2.5*scl-2*layer_h;

// Core
if(false||g==1||g==undef&&part=="core"){
    difference(){
        // positive volume
        union(){
            
            mir()intersection(){
                r=(outer_d+outer_w/sqrt(2))/2+2*tol;
                r1=outer_d/2;
                h=core_h+core_h2-2*scl-cube_w/2;
                d=fin-r1;
                dz=d/sqrt(3);
                rotate_extrude()
                    polygon(points=[[r1-d-AT,2*scl],[r1,2*scl],[r1+d,dz+2*scl],[r1+d,h-dz],[r1,h],[r1-d-AT,h]]);
                // outer teeth
                for(j = [1:8]){
                    intersection(){
                        rotate(-90+j*360/8)
                            translate([0,2*scl+2*tol,0])mirror([1,0,0])cube([4*r1+d+AT,r1+d+AT,h]);
                        rotate(90-360/16+j*360/8)
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
        translate([0,0,-core_h/2])rotate_extrude(){
            translate([outer_d/2-2.5*scl+2*tol,0,0])rotate(-45)square(3*scl);
            translate([outer_d/2-2.5*scl-2*tol,0,0])rotate(-180-45)square(3*scl);
        }
    }
    
}

// Inner slider
if(true){
    translate([0,0,core_h2-cube_w/2])difference(){
        cylinder(r=outer_d/2-5*scl-2*tol,h=core_h/2+2.5*scl);
        translate([0,0,-TT])cylinder(r=outer_d/2-7*scl-2*tol,h=core_h/2+2.5*scl+AT);
            
        // tapered bottom
        translate([0,0,0])rotate_extrude(){
            translate([outer_d/2-7*scl+2*tol,0,0])rotate(-45)square(3*scl);
            translate([outer_d/2-7*scl-2*tol,0,0])rotate(-180-45)square(3*scl);
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

// (translate,rotate) start, finish, steps, power
// it, ir1, ir2, t, r1, r2, s, pt, pr1, pr2

of=7.5*scl+2*layer_h; // initial offset, once engaged
st=(tra-of)/3;

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

// central shafts
if(true){
    difference(){
        translate([0,0,core_h2-cube_w/2])
            cylinder(r=outer_d/2-7*scl-4*tol,h=core_h/2+2.5*scl);
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

    rotate(180)difference(){
        translate([0,0,2.5*scl+layer_h])cylinder(r=outer_d/2-7*scl-4*tol,h=core_h/2-2.5*scl-layer_h);
        
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
        translate([0,0,2.5*scl+layer_h])rotate_extrude(){
            translate([outer_d/2-9*scl-4*tol,0,0])rotate(-45)square(3*scl);
            translate([outer_d/2-9*scl-8*tol,0,0])rotate(-180-45)square(3*scl);
        }
        
    }
}

// cut a path segment, translate t, rotate r over s steps
module path(it=0,ir=0,t=0,r=0,s=0,pt=1,pr=1){
    translate([0,0,it])rotate(ir)if(s)for(i=[1:s])hull(){
        translate([0,0,(t-it)*pow(i/s,pt)])rotate((r-ir)*pow(i/s,pr))children();
        translate([0,0,(t-it)*pow((i-1)/s,pt)])rotate((r-ir)*pow((i-1)/s,pr))children();
    }else children();
}