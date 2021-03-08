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
pegs=1;

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


//mir()translate([0,0,-cube_w/2])
//    cylinder(d=outer_d,h=core_h2-layer_h,$fn=96);

// Core
if(false||g==1||g==undef&&part=="core"){
    difference(){
        // positive volume
        union(){
            
            mir()intersection(){
                r=(outer_d+outer_w/sqrt(2))/2+2*tol;
                r1=outer_d/2;
                h=core_h+core_h2-2*scl-cube_w/2;
                d=cube_w/2-r1-2*scl-2*tol;
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

            
            /*for (i=[0:modules-2])if(!i||pt[modules-1]*(rt[i-1]-pt[i-1]) != pt[i-1]*(rt[modules-1]-pt[modules-1]))translate([0,0,addl(gh,i)]){
                // outer teeth
                r=(outer_d+outer_w/sqrt(2))/2;
                r1=outer_d/2;
                h=gh[i]/2;
                d=teeth_a*outer_w;
                dz=d/sqrt(3);
                //for(j = [1:16])
                    translate([0,0,i>0?layer_h:0])rotate_extrude() // TODO: translate?
                        polygon(points=[[r1-AT,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[r1-AT,h]]);
            }*/
            /*difference(){
                cylinder(r=outer_d/2,h=core_h);
                cylinder(r=outer_d/2-teeth_a*outer_w-AT,h=core_h);
                for (i=[0:modules-2])if(pt[modules-1]*(rt[i]-pt[i]) != pt[i]*(rt[modules-1]-pt[modules-1]))
                    translate([0,0,addl(gh,i+1)+layer_h-bearing_h]){
                        translate(-outer_d*[1,1,0])cube([2*outer_d,2*outer_d,layer_h]);
                    }
            }*/

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
                polygon(points=[[outer_d/2-7*scl,core_h/2+2*scl],[outer_d/2-5*scl,core_h/2+2*scl],[outer_d/2-3*scl,core_h/2+2*scl-2*scl/sqrt(3)],[outer_d/2-3*scl,2*scl/sqrt(3)+2*scl],[outer_d/2-5*scl,2*scl],[outer_d/2-7*scl,2*scl]]);
            for(j = [1:8]){
                rotate(j*360/8+360/16+360/32)
                    translate([0,-2*scl-2*tol,0])cube([outer_d/2,4*scl+4*tol,core_h/2+2*scl]);
            }
        }

        // payload
        translate([0,0,core_h2-cube_w/2-TT])
            cylinder(r=outer_d/2-5*scl,h=core_h+AT);



        //rotate_extrude()polygon(points=[[0,0],[outer_d/2-2*scl,0],[outer_d/2-2*scl,core_h/2-d/2-2*scl],[outer_d/2-2*scl-d/2,core_h/2-2*scl],[outer_d/2-2*scl-d/2,core_h/2],[0,core_h/2]]);
        //pinhole(r=outer_d/2-2*scl,l=core_h/8,nub=core_h/32,fixed=false,fins=false);
        
        // vertical tracks
        /*union(){
            r=(outer_d+outer_w/sqrt(2))/2;
            r1=outer_d/2;
            h=gh[mid]/2;
            h1=addl(gh,mid)-bearing_h+layer_h;
            h2=addl(gh,mid+2);
            d=teeth_a*outer_w;
            dz=d/sqrt(3);
            translate([0,0,addl(gh,mid+1)])translate([0,0,gh[mid+1]/2])rotate_extrude()
                polygon(points=[[r1+AT,0],[r1,0],[r1-d,dz],[r1-d,h-dz],[r1,h],[r1+AT,h]]);
            for(j = [1:16])intersection(){
                    rotate(j*360/16+asin(tol/r1))cube([r1+d+AT,r1+d+AT,h2]);
                    rotate(90-360/32+j*360/16-asin(tol/r1))cube([r1+d+AT,r1+d+AT,h2]);
                    rotate_extrude()
                        polygon(points=[[r1+d+AT,-AT],[r1-d,-AT],[r1-d,h1],[r1-d*(j%2),h1],[r1-d*(j%2),h2-dz],[r1,h2],[r1+d+AT,h2]]);
                }
        }*/

        //translate([0,0,-spring_d/2])cylinder(d=shaft_d,h=core_h/2,$fn=24);
        //translate([0,0,core_h/2+spring_d/2])cylinder(d=shaft_d,h=core_h/2,$fn=24);
        //translate([0,0,core_h/2-spring_d/2])cylinder(d=spring_d,h=spring_d,$fn=24);
        //translate([0,0,core_h/2-spring_d/2])cylinder(d2=spring_d,d1=shaft_d,h=(shaft_d-spring_d)/2,$fn=24);
        //translate([0,0,core_h/2+spring_d/2-(shaft_d-spring_d)/2])cylinder(d1=spring_d,d2=shaft_d,h=(shaft_d-spring_d)/2,$fn=24);
    
        // upper secondary lock vertical tracks
        /*intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]*2;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,addl(gh,modules-1)])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(j = [0:1])rotate([0,0,180*j])
                translate([r,0,addl(gh,modules-1)])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
        // lower secondary lock vertical tracks. TODO: dedup
        intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]*2;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,gh[0]-h])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(j = [0:1])rotate([0,0,180*j])
                translate([r,0,gh[0]-h])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
    
        // false gates - we could make it a lot harder by setting h=gh[0]/2
        intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]/2+fg;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,addl(gh,modules-1)])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(i = [-1:2:1], j = [0:1])rotate([0,0,90+180*j+i*30])
                translate([r,0,addl(gh,modules-1)])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
        intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]/2+fg;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,gh[0]-h])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(i = [-1:2:1], j = [0:1])rotate([0,0,90+180*j+i*30])
                translate([r,0,gh[0]-h])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
        
        // track
        r=(shaft_d+outer_w/sqrt(2))/2;
        r1=shaft_d/2;
        h=gh[0]/2;
        d=teeth_a2*outer_w;
        dz=d/sqrt(3);
        difference(){
            translate([0,0,addl(gh,modules-1)])
                rotate_extrude($fn=24)
                    polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
                // end stops
                for(j = [0:1])rotate([0,0,90+180*j])
                    translate([r,0,addl(gh,modules-1)])scale([2,1,1])rotate([0,0,45])
                        cylinder(d=outer_w*2,h=core_h+core_h2+tol+ST,$fn=4);
        }
        difference(){
            translate([0,0,gh[0]/2])
                rotate_extrude($fn=24)
                    polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
                // end stops
                for(j = [0:1])rotate([0,0,90+180*j])
                    translate([r,0,gh[0]/2])scale([2,1,1])rotate([0,0,45])
                        cylinder(d=outer_w*2,h=core_h+core_h2+tol+ST,$fn=4);
        }*/
    }
    
}

// Inner slider
if(true){
    translate([0,0,core_h2-cube_w/2])
        difference(){
            cylinder(r=outer_d/2-5*scl-2*tol,h=core_h/2);
            translate([0,0,-TT])cylinder(r=outer_d/2-7*scl-2*tol,h=core_h/2+AT);
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
        translate([outer_d/2-7*scl-2*tol+AT,0,k?-2.5*scl-layer_h:2.5*scl+layer_h-core_h/2])
            mirror([1,0,1])cylinder(r1=2.5*scl,r2=0.5*scl,h=2*scl+AT,$fn=24);
}

// (translate,rotate) start, finish, steps, power
// it, ir1, ir2, t, r1, r2, s, pt, pr1, pr2
tra=core_h/2-5*scl-2*layer_h;
/*maze=[
    [0,0,0,tra*0.9,360*0.9,360*0.9,50,1,1,1],
    [tra*0.9,360*0.9,360*0.9,tra,360*0.9,360,5,1,1,1],
];*/
maze=[
    [0,0,0,5*scl+2*layer_h,20,0,10,1,1,1],
    [5*scl+2*layer_h,20,0,tra*0.9,360*0.9,360*0.9,50,1,1,1],
    [tra*0.9,360*0.9,360*0.9,tra,360*0.9,360,5,1,1,1],
];

/*difference(){
    cylinder(r=outer_d/2-9*scl-4*tol,h=layer_h);
    cylinder(r=outer_d/2-9*scl-8*tol,h=layer_h);
}*/
//translate([outer_d/2-9*scl-4*tol,0,0])rotate([0,45,0])cube(2*scl);
//translate([outer_d/2-9*scl-8*tol,0,0])rotate([0,180+45,0])cube(2*scl);

/*translate([0,0,layer_h])rotate_extrude(){
    translate([outer_d/2-9*scl-4*tol,0,0])rotate(-45)square(3*scl);
    translate([outer_d/2-9*scl-8*tol,0,0])rotate(-180-45)square(3*scl);
}*/

// central shafts
if(true){
    color("green")difference(){
        translate([0,0,core_h2-cube_w/2])
            cylinder(r=outer_d/2-7*scl-4*tol,h=core_h/2);
        // maze path
        for(j=[0:pegs-1],k=[0:1],l=[0:len(maze)-1])
            path(maze[l][0],maze[l][1],maze[l][3],maze[l][4],maze[l][6],maze[l][7],maze[l][9])rotate(j*360/pegs)
                translate([outer_d/2-7*scl-4*tol+AT,0,k?-2.5*scl-layer_h:2.5*scl+layer_h-core_h/2])
                    mirror([1,0,1])cylinder(r1=2.5*scl,r2=0.5*scl,h=2*scl+AT,$fn=24);
    }

    // post
    translate([0,0,-TT])cylinder(r=outer_d/2-11*scl-10*tol,h=10*scl+AT);
    // key
    translate([0,0,4*scl-layer_h])intersection(){
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

    color("red")rotate(180)difference(){
        translate([0,0,layer_h])cylinder(r=outer_d/2-7*scl-4*tol,h=core_h/2-layer_h);
        
        // maze path
        for(j=[0:pegs-1],k=[0:1],l=[0:len(maze)-1])
            path(maze[l][0],maze[l][2],maze[l][3],maze[l][5],maze[l][6],maze[l][7],maze[l][9])rotate(j*360/pegs)
                translate([outer_d/2-7*scl-4*tol+AT,0,k?-2.5*scl-layer_h:2.5*scl+layer_h-core_h/2])
                    mirror([1,0,1])cylinder(r1=2.5*scl,r2=0.5*scl,h=2*scl+AT,$fn=24);
        // socket
        translate([0,0,-TT])cylinder(r=outer_d/2-11*scl-8*tol,h=10*scl+2*tol+TT);
        translate([0,0,4*scl-layer_h])
            rotate_extrude(convexity=5)
                    polygon(points=[
            [outer_d/2-12*scl-8*tol,4*scl+2*scl],
            [outer_d/2-11*scl-8*tol,4*scl+2*scl],
            [outer_d/2-9*scl-8*tol,4*scl+2*scl-2*scl/sqrt(3)],
            [outer_d/2-9*scl-8*tol,2*scl/sqrt(3)+2*scl],
            [outer_d/2-11*scl-8*tol,2*scl],
            [outer_d/2-12*scl-8*tol,2*scl]]);
        intersection(){
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
        translate([0,0,layer_h])rotate_extrude(){
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