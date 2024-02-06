module top (
    input clk30,
    input [1:0] user_buttons,
    output reg [2:0] user_leds_color,
    output reg [6:0] user_leds_en
);
 
    reg en;
    reg [2:0] color;

    always @(*) begin
        user_leds_en = {en, {3{~en, en}}};
        user_leds_color = color;
    end

    always @(negedge user_buttons[1]) begin
        color <= color + 1;
        en <= ~en;
    end

endmodule
