// TODO: thicker top plate
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

// Gear clearance
tol_=0.2; //[0:0.01:0.5]
tol=scl*tol_;

// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
layer_h = scl*layer_h_;

// Height of planetary layers (layer_h will be subtracted from gears>0). Non-uniform heights will reveal bugs.
gh_ = [7.0, 7.2, 7.2, 7.2, 7.2, 7.2];
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

// Recursively sums all elements of a list up to n'th element, counting from 1
function addl(list,n=0) = n>0?(n<=len(list)?list[n-1]+addl(list,n-1):list[n-1]):0;

module mir(){
    children();
    mirror([0,0,1])children();
}

// cylinder with recess for locking teeth
difference(){
    translate([0,0,-cube_w/2])
        difference(){
            cylinder(d=outer_d,h=core_h2-layer_h,$fn=96);
            // centre hole
            translate([0,0,-TT])cylinder(d=10*scl,h=core_h2-layer_h+AT,$fn=96);
            // supporting layer
            //translate([0,0,core_h2-4*layer_h])cylinder(d=outer_d,h=layer_h,$fn=96);
        }
    // slots for latch movement
    intersection(){
        translate([0,0,-cube_w/2])
            cylinder(d=outer_d+tol,h=core_h2-layer_h-1*scl+2*tol,$fn=96);
        translate([0,0,core_h2-layer_h-5*scl-cube_w/2]){
            r=(outer_d+outer_w/sqrt(2))/2+2*tol;
            r1=outer_d/2;
            e=r1-sqrt(r1*r1-pow(1.5*scl+2*tol,2));
            h=core_h+core_h2-2*scl-cube_w/2;
            d=cube_w/2-r1-2*scl;
            dz=d/sqrt(3);
            for(j=[1:8])rotate(j*360/8+45/4)translate([r1-4*scl-e,0,0])mirror([0,1,1])
                cylinder(r=core_h2-layer_h-6.2*scl+2*tol,h=3*scl+4*tol,center=true);
        }
    }
    // holes for magnet insertion
    difference(){
        for(j=[1:8])hull()mir()translate([0,0,core_h2-layer_h-5*scl-cube_w/2]){
            r=(outer_d+outer_w/sqrt(2))/2+2*tol;
            r1=outer_d/2;
            e=r1-sqrt(r1*r1-pow(1.5*scl+2*tol,2));
            h=core_h+core_h2-2*scl-cube_w/2;
            d=cube_w/2-r1-2*scl;
            dz=d/sqrt(3);
            rotate(j*360/8+45/4)translate([r1-4*scl-e,0,0])mirror([0,1,1])
                rotate(90-la)translate([0,core_h2-layer_h-6.2*scl-3*scl-4*tol,-3*scl-2*tol])
                    cylinder(r=3*scl+2*tol,h=3*scl+4*tol,center=true);
        }
        // supporting layer
        translate([0,0,core_h2-4*layer_h-cube_w/2])cylinder(d=outer_d,h=layer_h,$fn=96);
    }

    //temporary secton
    rotate(45/4)translate([0,-cube_w/2,0])cube(cube_w+AT,center=true);
}

// locking teeth
r1=outer_d/2;
e=r1-sqrt(r1*r1-pow(1.5*scl+2*tol,2));
la=0;

for(j=[1:8])
translate([0,0,core_h2-layer_h-5*scl-cube_w/2])rotate(j*360/8+45/4)translate([r1-4*scl-e,0,0])
rotate([0,-la,0])
translate(-[r1-4*scl-e,0,0])rotate(-j*360/8-45/4)translate(-[0,0,core_h2-layer_h-5*scl-cube_w/2])
intersection(){
    translate([0,0,-cube_w/2])rotate_extrude(){
        translate([r1-4*scl,core_h2-layer_h-5*scl])circle(r=4*scl);
        difference(){
            square([r1,core_h2-layer_h-1*scl]);
            translate([r1-4*scl,core_h2-layer_h-5*scl])square([4*scl,4*scl]);
        }
    }
    translate([0,0,core_h2-layer_h-5*scl-cube_w/2]){
        r=(outer_d+outer_w/sqrt(2))/2+2*tol;
        h=core_h+core_h2-2*scl-cube_w/2;
        d=cube_w/2-r1-2*scl;
        dz=d/sqrt(3);        
        // outer teeth
        rotate(j*360/8+45/4)translate([r1-4*scl-e,0,0])mirror([0,1,1]){
            difference(){
                cylinder(r=core_h2-layer_h-6.2*scl,h=3*scl,center=true);
                cylinder(r=2*scl+2*tol,h=3*scl+4*tol,center=true);
                // hole for magnet
                rotate(90)translate([0,core_h2-layer_h-6.2*scl-3*scl-5*tol,0])cylinder(r=3*scl+tol,h=3*scl+AT,center=true);
            }
            cylinder(r=2*scl,h=3*scl+4*tol+2*AT,center=true);
            // bridge helpers
            //rotate(la)translate([0,core_h2-layer_h-6.2*scl-tol/2,0])cube([14*tol,tol,3*scl+4*tol+2*AT],center=true);
            
            intersection(){
                difference(){
                    cylinder(r=core_h2-layer_h-6.2*scl,h=3*scl+4*tol+AT,center=true);
                    cylinder(r=core_h2-layer_h-6.2*scl-layer_h,h=3*scl+4*tol+ST,center=true);
                }
                mirror([0,1,1])translate(-[r1-4*scl-e,0,0])rotate(-j*360/8-45/4)
                translate(-[0,0,core_h2-layer_h-5*scl-cube_w/2])
                translate([0,0,core_h2-layer_h-5*scl-cube_w/2])rotate(j*360/8+45/4)translate([r1-4*scl-e,0,0])
                rotate([0,la,0])
                translate(-[r1-4*scl-e,0,0])rotate(-j*360/8-45/4)translate(-[0,0,core_h2-layer_h-5*scl-cube_w/2])
                    translate([0,0,-cube_w/2])difference(){
                        cylinder(d=outer_d,h=core_h2-layer_h,$fn=96);
                        cylinder(d=outer_d-20*scl,h=core_h2-layer_h,$fn=96);
                    }
            }
            
        }
    }
}


// locking teeth
/*translate([0,0,2*scl-cube_w/2])intersection(){
    r=(outer_d+outer_w/sqrt(2))/2+2*tol;
    r1=outer_d/2;
    h=core_h+core_h2-2*scl-cube_w/2;
    d=cube_w/2-r1-2*scl;
    dz=d/sqrt(3);
    rotate_extrude()
        polygon(points=[[r1-d-AT,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[r1-d-AT,h]]);
    // outer teeth
    for(j = [1:8]){
        intersection(){
            rotate(-90+j*360/8+45/2)
                translate([0,2*scl+2*tol,0])mirror([1,0,0])cube([4*r1+d+AT,3*scl,core_h2-layer_h-2*scl]);
            //rotate(90-360/16+j*360/8+45/2)
                //translate([0,2*scl+2*tol,0])cube([4*r1+d+AT,r1+d+AT,h]);
        }
    }
}*/