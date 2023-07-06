  [gcode_macro START_PRINT] 
gcode: 
  {% set BED_TEMP = params.BED_TEMP|default(60)|float %}
  {% set EXTRUDER_TEMP = params.EXTRUDER_TEMP|default(200)|float %}
  G21 #all moves starting now have their units specified in millimeters
  G90 #In absolute mode all coordinates given in G-code are interpreted as positions in the logical coordinate space
  M82 #This command is used to override G91 and put the E axis into absolute mode independent of the other axes. G90 and G91 clear this mode.
  M107 T0 #Turn off one of the fans. If no fan index is given, the print cooling fan. Turn on fans with M106.
  M140 S{BED_TEMP} #Set a new target temperature for the heated bed and continue without waiting. The firmware manages heating in the background. Use M190 to wait for the bed to reach the target temperature.
  G28 #Home printer
  G1 Z200 #Move down Z
  G1 X-150 #Move to the side
  {% if printer.heater_bed.temperature < params.BED_TEMP|float*0.8 %}
    M104 S{EXTRUDER_TEMP} T0 #Set a new target hot end temperature and continue without waiting. The firmware will continue to try to reach and hold the temperature in the background.Use M109 to wait for the hot end to reach the target temperature.
    SET_PIN PIN=LED_pin VALUE=1
  {% endif %}
  M190 S{BED_TEMP}
  M109 S{EXTRUDER_TEMP}
  BED_MESH_PROFILE LOAD=default #Load bed mesh
  G1 F3000 X-150 Y-80 Z1 #Move to position for first purge
  G1 Z0.4 #drop Z position
  G92 E0 #Set next extruder position
  G3 X0 Y-150 I150 Z0.3 E30 F2000 #Print a circular shape from current position to specified position... G2 adds a clockwise arc move to the planner; G3 adds a counter-clockwise arc. An arc move starts at the current position and ends at the given XYZ, pivoting around a center-point offset given by I and J or R.CNC_WORKSPACE_PLANES allows G2/G3 to operate in the selected XY, ZX, or YZ workspace plane.This command has two forms:
  G92 E0 #Set next extruder position