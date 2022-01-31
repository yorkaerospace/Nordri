use <./JigsGeneric/FinAssembly/BaseClamp.scad>;
use <./JigsGeneric/FinAssembly/FinClamp.scad>;

tube_diameter = 54;

fin_length = 50;
fin_thickness = 4;
num_fins = 4;

rocket_base_clamp(tube_diameter, fin_thickness);
translate([tube_diameter + fin_length * 2, 0, 0])
    rocket_fin_clamp(tube_diameter, fin_thickness, fin_length);
