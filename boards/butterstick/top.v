module top (
    input clk30,
    input [1:0] user_buttons,

    output [2:0] user_leds_color,
    output [6:0] user_leds_enable
);

    assign user_leds_color = 3'b110;
    assign user_leds_enable = 7'b1010101;


    soc soc (
        .sys_clk(clk30),
        .sys_rst(~user_buttons[1]),
        .uart0_tx(syzygy0_s[0]),
        .uart0_tx(syzygy0_s[1])
    );
endmodule
