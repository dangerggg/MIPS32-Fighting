module alu(leds, switch, clk, rst);
input[31:0] switch;
input clk;
input rst;
output reg[15:0] leds;

parameter ADD=4'b0000;
parameter SUB=4'b0001;
parameter AND=4'b0010;
parameter OR=4'b0011;
parameter XOR=4'b0100;
parameter NOT=4'b0101;
parameter SLL=4'b0110;
parameter SRL=4'b0111;
parameter SRA=4'b1000;
parameter ROL=4'b1001;
reg[3:0] sf;
reg[31:0] adder;
reg[31:0] sub_adder;
reg[31:0] answer;
reg[32:0] expand;
integer base;

parameter[3:0] LOAD_ADDER=2'b00,
               LOAD_SUBADDER=2'b01,
               COMPUTE=2'b10,
               SIGNFLAG=2'b11;
reg[1:0] state_machine=2'b00;

always@(posedge clk or posedge rst)
begin
    if(rst == 1'b1)
    begin
       leds = 32'h0;
       state_machine = LOAD_ADDER;
    end
    else
        begin
            case (state_machine)
                LOAD_ADDER: 
                    begin
                    adder = switch; 
                    state_machine = LOAD_SUBADDER;
                    leds = switch[15:0];
                    end
                LOAD_SUBADDER:
                    begin
                    sub_adder = switch; 
                    state_machine = COMPUTE;
                    leds = switch[15:0];
                    end
                COMPUTE: begin
                    case (switch[3:0])
                    ADD: 
                    begin
                    expand = {0, adder} + {0, sub_adder};
                    answer = expand[31:0];
                    leds = expand[15:0];
                    sf[3] = expand[32];
                    sf[2] = ~(adder[31] ^ sub_adder[31]) & (adder[31] ^ expand[31]);
                    end
                    SUB:
                    begin
                    expand = {0, adder} + (~{sub_adder[31], sub_adder} + 1);
                    answer = expand[31:0];
                    leds = expand[15:0];
                    sf[3] = expand[32];
                    sf[2] = (adder[31] ^ sub_adder[31]) & (adder[31] ^ expand[31]);
                    end
                    AND:
                    begin
                    answer = adder & sub_adder;
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    OR:
                    begin
                    answer = adder | sub_adder;
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    XOR:
                    begin
                    answer = adder ^ sub_adder;
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    NOT:
                    begin
                    answer = ~adder;
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    SLL:
                    begin
                    answer = adder << sub_adder;
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    SRL:
                    begin
                    answer = adder >> sub_adder;
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    SRA:
                    begin
                    base = adder;
                    answer = base >>> sub_adder;   
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    ROL:
                    begin
                    answer = (adder << sub_adder)|(adder >> (32 - sub_adder));
                    leds = answer[15:0];
                    sf[3] = 1'b0;
                    sf[2] = 1'b0;
                    end
                    default: ;
                    endcase
                    if(answer == 32'h0) 
                        sf[0] = 1'b1;
                    else
                    begin
                        sf[0] = 1'b0;
                        sf[1] = answer[31];
                        state_machine = SIGNFLAG;
                    end
                   end
                SIGNFLAG:
                begin
                    leds = 32'h0;
                    leds[3] = sf[3];
                    leds[2] = sf[2];
                    leds[1] = sf[1];
                    leds[0] = sf[0];
                    state_machine = LOAD_ADDER;
                end
            endcase
          end
    end
endmodule
