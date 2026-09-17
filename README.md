# Isabella

A julia-based utility to generate special-purpose programmable controllers in Verilog.
Developed for Digital Design instruction at Utah State University.

Isabella generates controllers can be used to program peripheral interfaces and behaviors 
in FPGA designs, without requiring an embedded microprocessor. The designer specifies a 
list of 8-bit command codes and the registers they control. Programs of up to 255 bytes 
are supported. Very basic looping and branching instructions are provided as part of the
base instruction set. 

The Isabella tool is named after the Bear Lake Monster which haunts the mountain 
waters of northern Utah and southern Idaho.

## Synposis

You have a Verilog project with some peripheral resource R. You want R to do some
sophisticated things. At the RTL level, you might design a state machine. A low-level
state machine might be "brittle", difficult to debug, revise, and add functionality.
The Isabella model uses a program/processor strategy for the state machine. You define
the instructions, connect them to RTL events, and write assembly-like programs to 
control the state machine. 

Isabella controllers are meant to be simple, and are defined within a single YAML file.
The YAML file declares the resource-specific inputs, outputs, instructions, RTL events, and
assembly program for your module. The Isabella tool translates the YAML into a SystemVerilog
controller module that you can embed into a larger project.


## Dependencies and Installation

Isabella itself is written as a **Julia module**. At present, there is only a development
version of Isabella. To use it, first install the Julia language. From within Julia, type
`]` to activate the package manager, then type 

```
add https://github.com/cjwinstead/Isabella
```

That should download the repository and any package dependencies. 


### Using the Isabella Julia Module

At this point, Isabella is in early development and is being designed to work as a server with the
Socketash.jl tool. What Isabella does is read high-level YAML definitions for a controller design,
and translate them into RTL-level SystemVerilog source files. The output files are contained together
in a YAML data structure that we'll call the "target project".

The server functionality is not yet implemented. To use the Isabella tool locally,
start `julia`, make sure Isabella is installed (update if necessary), and run this sequence of 
commands:

```julia
using Isabella, YAML

filename = ### put source YAML filename string here
target   = ### put target project YAML filename string here
data = YAML.load_file(filename);
prj = generate_controller_project(data);
YAML.write_file(target);
```

Once this is done, the `target` filename should contain all the generated project files. The 
next step is to extract them into a project directory tree. This can be done with the `controller_project`
script described in the next section.


### Project Template Script `controller_project`

Isabella generates SystemVerilog sources and data files bundled in a YAML format. 
The YAML bundle can be unpacked using the provided Bash script, `scripts/controller_project`.
The script has these dependencies:

* Bash terminal shell
* `yq` terminal YAML processor [https://github.com/kislyuk/yq]


-----
## Pre-Defined Commands

| Command    | Hex | Data Byte            |
|------------|-----|----------------------|
| `NULL_CMD` | 00  | -                    |
| `SLEEP_US` | 01  | time (microseconds)  |
| `SLEEP_MS` | 02  | time (milliseconds)  |
| `SLEEP_S`  | 03  | time (seconds)       |
| `JUMP`     | 04  | destination line     |



-----

## Example Design: LED Controller

An example is given in `examples/controller_with_shift.yaml`. This example supposes 
that we have 16 LEDs to control. The first few YAML fields define the controller name,
inputs, outputs, and initializations:

```yaml
module: led_controller_with_shift
inputs: |
  // no special inputs for this controller
outputs: |
  output reg [15:0] led
initial: |
  led = 0;
rst: |
  led <= 0;
```

The text defined in the `inputs` and `outputs` fields is appended to the module port
declarations. The `initial` field defines power-on assignments, and the `rst` field
defines active reset assignments.

The next field defines a `hex_prefix`. This is the upper nibble for the resource's
instruction set. In the example, the prefix is `8`, so all of the defined commands
will start with `8`.

Each command is defined by three fields: `name`, `databytes`, and `verilog`.
The `name` is conventionally all-capital letters with underscores. A command
may be followed by zero or one `databytes` that are loaded into a register named
`data` before executing the command. The command's behavior is defined by the
`verilog` field. 

For this example, the defined commands are summarized in the table below.


| `name`               | `databytes`  | `verilog`                                |
|----------------------|--------------|------------------------------------------|
| `         LED_CLEAR` | `         0` | `      led  =>                       0;` |
| `  LED_SET_LOW_BYTE` | `         1` | ` led[7:0]  =>                    data;` |
| ` LED_SET_HIGH_BYTE` | `         1` | `led[15:8]  =>                    data;` |
| `   LED_OR_LOW_BYTE` | `         1` | ` led[7:0]  =>           led[7:0]|data;` |
| `  LED_OR_HIGH_BYTE` | `         1` | `led[15:8]  =>          led[15:8]|data;` |
| ` LED_NAND_LOW_BYTE` | `         1` | ` led[7:0]  =>           led[7:0]&data;` |
| `LED_NAND_HIGH_BYTE` | `         1` | `led[15:8]  =>          led[15:8]&data;` |
| `         LED_FLOOD` | `         0` | `      led  =>                16'hffff;` |
| `   LED_RIGHT_SHIFT` | `         0` | `      led  =>      {led[0],led[15:1]};` |
| `    LED_LEFT_SHIFT` | `         0` | `      led  =>     {led[14:0],led[15]};` |


After the command definitions, the YAML file defines a `program` to be executed. Each 
program line has this format:

`<line_number>: <COMMAND_NAME | DATA_BYTE>  [# COMMENT]`

The example program sets the LEDs to `h01` in lines 0--3. At line 4, the LED
values are shifted to the left. Lines 5--6 put the program to sleep for `h20`
milliseconds (32ms in decimal). Lines 7--8 loop back to line 4, creating an 
infinite loop where the single illuminated LED is shifted continuously to the 
left.

```
  0:	LED_SET_LOW_BYTE  # set 0-7
  1:	01		          # one light on
  2:	LED_SET_HIGH_BYTE # set 8-16
  3:	00		          # no lights on
  4:	LED_LEFT_SHIFT	  # rotate light
  5:	SLEEP_MS 	      # pause
  6:	20     		      # 20ms
  7: 	JUMP   		      # loop back
  8:	04      	      # to left shift cmd
```

## Second Example: LED Controller with Multiple Programs

Another example is given in `examples/controller_with_multiple_inputs.yaml`. This example supposes 
that we have 16 LEDs to control. Like the previous example, the first few YAML fields define the controller name,
inputs, outputs, and initializations:

```yaml
module: led_controller_with_multiple_programs
inputs: |
  input [15:0] data_in,
outputs: |
  output reg [15:0] led
initial: |
  led = data_in;
rst: |
  led <= data_in;
```

This time there is an additional input, `data_in`. The `initial` and `rst` assignments
use the `data_in` input. 

The commands and `hex_prefix` are the same as the previous example, except two new commands are 
added:

```yaml
- name: LED_SET
  databytes: 0
  verilog: led <= data_in;
- name: LED_NOT
  databytes: 0
  verilog: led <= ~led;
```

Now the big difference: the `program` section contains four distinct programs, one after the
other. Each program ends either in a loop instruction or `NULL_CMD`. To run a particular 
program, the `iadr` input is set to the address of the desired program, and the interrupt 
signal `intr` is raised to trigger execution. 

Here are the new programs:

```yaml
program: |
  # FIRST PROGRAM at iaddr 'd0
  0:	LED_SET_LOW_BYTE  # set 0-7
  1:	01		  # one light on
  2:	LED_SET_HIGH_BYTE # set 8-16
  3:	00		  # no lights on
  4:	LED_LEFT_SHIFT	  # rotate light
  5:	SLEEP_MS 	  # pause
  6:	20     		  # 20ms
  7: 	JUMP   		  # loop back
  8:	04      	  # to left shift cmd
  # SECOND PROGRAM at iaddr 'd9
  9:    LED_FLOOD         # all leds on
  10:    NULL_CMD         # wait for next intr
  # THIRD PROGRAM at iaddr 'd10
  11:    LED_SET          # set all leds to data_in
  12:    NULL_CMD         # wait for next intr
  # FOURTH PROGRAM at iaddr 'd13
  13:    LED_NOT          # invert the leds
  14:    NULL_CMD         # wait for next intr
```

Now suppose this controller is embedded in a module named `top`. Within `top`, 
there are four distinct signals named `scan`, `flood`, `set`, and `invert`, 
associated respectively to the four programs. The programs can be initiated like
this:

```verilog
always @(posedge clk) begin
   if (scan) begin
      intr  <= 1;
      iadr <= 0;    
   end else if (set) begin
      intr <= 1;
      iadr <= 9;    
   end else if (invert) begin
      intr <= 1;
      iadr <= 11;    
   end else if (flood) begin
      intr <= 1;
      iadr <= 13;    
   end else begin
      intr <= 0;    
   end
end
```
