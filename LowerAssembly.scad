// Laser Material Thickness
MATERIAL = 3.5;

// Tube dimensions
MAIN_OUTER = 54;
MAIN_INNER = 51;
COUPLER_INNER = 48.5;
TUBE_OUTER = 32;
TUBE_INNER = 29.5;
TUBE_LENGTH=200;

// Fin dimensions
FIN_THICKNESS = MATERIAL;
FIN_POINTS = [
    [0,0], [60,45], [100,45], [120,0]
];
FIN_ROOT = FIN_POINTS[len(FIN_POINTS)-1][0];
SLOT_HEIGHT = 5; // radial height of fin tabs

// Other
RING_THICKNESS = MATERIAL;
NUM_FINS = 4;
CORD_HOLE = 4; // diameter of the hole for the paracord
$fn = 100;

// Creates a 3d single fin on the xy plane aligned to 0,0
module Fin(){
    tab_len = (MAIN_OUTER - TUBE_OUTER)/2;
    linear_extrude(FIN_THICKNESS, center=true){
        union(){
            // Fin itself
            translate([0,tab_len,0]){
                polygon(FIN_POINTS);
            }
            // Main tab
            square([FIN_ROOT, tab_len], center=false);
            // Centering Slot
            translate([-RING_THICKNESS*2,-0.1,0]){
                square([FIN_ROOT + RING_THICKNESS*5, SLOT_HEIGHT+0.1], center=false);
            }
        }
    }
}

// Creates the n-fin assembly aligned around the inner tube
module Fins(){
    translate([0,0,FIN_ROOT+RING_THICKNESS*2])
    rotate([0,90,0]){
        for(i = [0 : 360/NUM_FINS : 360]){
            rotate([i, 0,0]){
                translate([0,TUBE_OUTER/2,0]){ Fin(); }
            }
        }
    }
}

// Model of the inner tube
module InnerTube(h=TUBE_LENGTH) {
    difference(){
        cylinder(h=h, d=TUBE_OUTER);
        cylinder(h=h, d=TUBE_INNER);
    }
}

module M3_nut(h=2.4, center=true) {
    // div by cos(30) converts hexagon side distance to corner distance

    LASER_TOLERANCE = 0.2;
    // Maximum width across flats (5.5)
    cylinder(h=h, d=5.5/cos(30)-LASER_TOLERANCE, $fn=6, center=center); 
    // Minimum width across flats (5.32)
    *cylinder(h=h, d=5.32/cos(30)-LASER_TOLERANCE, $fn=6, center=center); 
    // Minimum width across corners (6.01)
    *cylinder(h=h, d=6.01-LASER_TOLERANCE, $fn=6, center=center); 
}

module NutRetainer(w=10, h=3.5, nut=true){
    difference(){
        union(){
            color("red") 
            cube([w, MATERIAL*2 + h, MATERIAL], center=true);
            cube([w+8,h, MATERIAL], center=true);
        }
        if(nut) rotate(30) M3_nut(h=100);
    }
}

module Retainers(nut=false, h=3.5){
    rotate([0,90,0]){
        for(i = [360/NUM_FINS/2 : 360/NUM_FINS : 360]){
            rotate([i, 0,0]){
                translate([h/2,TUBE_OUTER/2 +4, 0]){ 
                    rotate([90,90,0]) NutRetainer(nut=nut, h=h);
                    }
            }
        }
    }
}

// Creates a ring on the xy plane with the fin slots cut out
module CouplerRing(){
    difference(){
        linear_extrude(RING_THICKNESS, center=false){
            difference(){
                circle(d=COUPLER_INNER);
                circle(d=TUBE_OUTER);
                translate([(TUBE_OUTER + CORD_HOLE) /2 -1,0,0]) circle(d=CORD_HOLE);
            }
        }
        Retainers(h=MATERIAL);
    }
}

module UpperFinRing(){
    difference(){
        linear_extrude(RING_THICKNESS, center=false){
            difference(){
                circle(d=MAIN_INNER);
                circle(d=TUBE_OUTER);
            }
        }
        Fins();
    }
}

module LowerFinRingTop(){
    difference(){
        linear_extrude(RING_THICKNESS, center=false){
            difference(){
                circle(d=MAIN_INNER);
                circle(d=TUBE_OUTER);
            }
        }
        Fins();
        for (r = [45: 180: 360]){
            rotate([0,0,r])
            translate([20,0,0])
            rotate([0,0,30]) M3_nut(h=10);
        }
    }
}

module LowerFinRingBottom(){
    difference(){
        linear_extrude(RING_THICKNESS, center=false){
            difference(){
                circle(d=MAIN_INNER);
                circle(d=TUBE_OUTER);
            }
        }
        Fins();
        for (r = [45: 180: 360]){
            rotate([0,0,r])
            translate([21,0,0])
            rotate([0,0,30]) cylinder(10,3, center=true);
        }
    }
}

// ---=== Render a pretty model ===---
module full_model(){
    InnerTube();
    // Fins in red
    color("red"){
        Fins();
    }
    translate([0,0,TUBE_LENGTH-RING_THICKNESS]) CouplerRing();
    translate([0,0,TUBE_LENGTH-RING_THICKNESS]) Retainers(nut=true);
    translate([0,0,TUBE_LENGTH-RING_THICKNESS*3]) CouplerRing();
    
    translate([0,0,FIN_ROOT + RING_THICKNESS*3]) UpperFinRing();
    translate([0,0,FIN_ROOT + RING_THICKNESS*2]) UpperFinRing();
    
    translate([0,0,RING_THICKNESS]) LowerFinRingBottom();
    translate([0,0,]) LowerFinRingTop();
    translate([0,0,-RING_THICKNESS]) LowerFinRingBottom();
}

full_model();

// Parts to cut
*projection() CouplerRing(); // x2
*projection() UpperFinRing(); // x2
*projection() LowerFinRingTop(); // x1
*projection() LowerFinRingBottom(); // x2
*projection() rotate([0,0,90]) Fin(); // x4
!projection() for(i = [0:6]) {
    translate([0, 11*i, 0]) NutRetainer();
}