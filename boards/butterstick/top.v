`include "soc.v"

module top (
    input clk30,
    input [1:0] user_buttons,

    output [2:0] user_leds_color,
    output [6:0] user_leds_en,

    output [31:0] syzygy0_s
);

    assign user_leds_color = 3'b110;
    assign user_leds_en = {~user_buttons[1], {3{user_buttons[1], ~user_buttons[1]}}};


    soc soc (
        .sys_clk(clk30),
        .sys_rst(~user_buttons[1]),
        .uart0_tx(syzygy0_s[0]),
        .uart0_tx(syzygy0_s[1])
    );
endmodule
