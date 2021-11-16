// Tube dimensions
MAIN_OUTER = 53.8;
MAIN_INNER = 50.8;
TUBE_OUTER = 30.7;
TUBE_INNER = 29;

// Fin dimensions
FIN_THICKNESS = 3;
FIN_ROOT = 120;
FIN_POINTS = [
    [0,0], [90,50], [150,50], [120,0]
];

// Other
SLOT_HEIGHT = 5;
RING_THICKNESS = 6;
NUM_FINS = 3;

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
            translate([-RING_THICKNESS,-0.1,0]){
                square([FIN_ROOT + RING_THICKNESS*2, SLOT_HEIGHT+0.1], center=false);
            }
        }
    }
}

// Creates the n-fin assembly aligned around the inner tube
module Fins(){
    rotate([0,90,0]){
        for(i = [0 : 360/NUM_FINS : 360]){
            rotate([i, 0,0]){
                translate([0,TUBE_OUTER/2]){ Fin(); }
            }
        }
    }
}
*Fins();

// Creates a ring on the xy plane with the fin slots cut out
module Ring(){
    difference(){
        linear_extrude(RING_THICKNESS-1, center=false){
            difference(){
                circle(d=MAIN_INNER, $fn=100);
                circle(d=TUBE_OUTER, $fn=100);
            }
        }
        Fins();
    }
}

// Projects laser cut template for the ring
*projection(){
    Ring();
}

// Projects laser cut template for the fin
*translate([60,0,0]){
projection(){
    Fin();
}
}

// ---=== Render a pretty model ===---
// Fins in red
color("red"){
    Fins();
}
// 2 rings in yellow, at the top and bottom of the fins
color("yellow"){
    Ring();
    translate([0,0,-126]){
        Ring();
    }
}