// Round-Robin Arbiter with variable time-slice

module round_robin_arbiter_variable_time_slice #(
    parameter [1:0] TIME_SLICE = 2'b00 // make slice = TIME_SLICE+1 cycles; default 1 cycle
) (
    input         clk,
    input         rst_n,
    input  [3:0]  REQ,
  output reg [3:0] GNT 
);

    localparam [3:0] S_ideal = 4'b0000, S_0 = 4'b0001, S_1 = 4'b0010, S_2 = 4'b0100, S_3 = 4'b1000;

    reg [3:0] present_state, next_state;
    reg [1:0] count, next_count;
  reg [1:0] pointer;

    // sequential update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            present_state <= S_ideal;
            count         <= 2'b00;
            pointer       <= 2'b00;
        end else begin
            present_state <= next_state;
            count         <= next_count;

            // update pointer when leaving a grant state
            if (present_state == S_0 && next_state != S_0) pointer <= 2'd1;
            else if (present_state == S_1 && next_state != S_1) pointer <= 2'd2;
            else if (present_state == S_2 && next_state != S_2) pointer <= 2'd3;
            else if (present_state == S_3 && next_state != S_3) pointer <= 2'd0;
            // otherwise keep pointer
        end
    end
	
	
	

    // combinational next-state / next-count
    always @* begin
        next_state = present_state;
        next_count = count;

        // S_ideal: rotated selection based on pointer
        if (present_state == S_ideal) begin
            // Very simple explicit rotation 
            case (pointer)
                2'd0: begin
                    if (REQ[0]) begin next_state = S_0; next_count = 2'b00; end
                    else if (REQ[1]) begin next_state = S_1; next_count = 2'b00; end
                    else if (REQ[2]) begin next_state = S_2; next_count = 2'b00; end
                    else if (REQ[3]) begin next_state = S_3; next_count = 2'b00; end
                    else begin next_state = S_ideal; next_count = 2'b00; end
                end
                2'd1: begin
                    if (REQ[1]) begin next_state = S_1; next_count = 2'b00; end
                    else if (REQ[2]) begin next_state = S_2; next_count = 2'b00; end
                    else if (REQ[3]) begin next_state = S_3; next_count = 2'b00; end
                    else if (REQ[0]) begin next_state = S_0; next_count = 2'b00; end
                    else begin next_state = S_ideal; next_count = 2'b00; end
                end
                2'd2: begin
                    if (REQ[2]) begin next_state = S_2; next_count = 2'b00; end
                    else if (REQ[3]) begin next_state = S_3; next_count = 2'b00; end
                    else if (REQ[0]) begin next_state = S_0; next_count = 2'b00; end
                    else if (REQ[1]) begin next_state = S_1; next_count = 2'b00; end
                    else begin next_state = S_ideal; next_count = 2'b00; end
                end
                2'd3: begin
                    if (REQ[3]) begin next_state = S_3; next_count = 2'b00; end
                    else if (REQ[0]) begin next_state = S_0; next_count = 2'b00; end
                    else if (REQ[1]) begin next_state = S_1; next_count = 2'b00; end
                    else if (REQ[2]) begin next_state = S_2; next_count = 2'b00; end
                    else begin next_state = S_ideal; next_count = 2'b00; end
                end
            endcase
        end
		
		

        // S_0..S_3 behavior: grant until slice expires, or drop if REQ deasserted
        else if (present_state == S_0) begin
            if (REQ[0]) begin
                if (count == TIME_SLICE) begin
                    // handoff in 0->1->2->3 order
                    if (REQ[1]) begin next_state = S_1; next_count = 2'b00; end
                    else if (REQ[2]) begin next_state = S_2; next_count = 2'b00; end
                    else if (REQ[3]) begin next_state = S_3; next_count = 2'b00; end
                    else begin next_state = S_0; next_count = 2'b00; end
                end else begin
                    next_state = S_0; next_count = count + 1'b1;
                end
            end else begin
                // requester dropped -> pick next or idle
                next_count = 2'b00;
                if (REQ[1]) next_state = S_1;
                else if (REQ[2]) next_state = S_2;
                else if (REQ[3]) next_state = S_3;
                else next_state = S_ideal;
            end
        end
		
		
        else if (present_state == S_1) begin
            if (REQ[1]) begin
                if (count == TIME_SLICE) begin
                    if (REQ[2]) begin next_state = S_2; next_count = 2'b00; end
                    else if (REQ[3]) begin next_state = S_3; next_count = 2'b00; end
                    else if (REQ[0]) begin next_state = S_0; next_count = 2'b00; end
                    else begin next_state = S_1; next_count = 2'b00; end
                end else begin next_state = S_1; next_count = count + 1'b1; end
            end else begin
                next_count = 2'b00;
                if (REQ[2]) next_state = S_2;
                else if (REQ[3]) next_state = S_3;
                else if (REQ[0]) next_state = S_0;
                else next_state = S_ideal;
            end
        end
		
		
        else if (present_state == S_2) begin
            if (REQ[2]) begin
                if (count == TIME_SLICE) begin
                    if (REQ[3]) begin next_state = S_3; next_count = 2'b00; end
                    else if (REQ[0]) begin next_state = S_0; next_count = 2'b00; end
                    else if (REQ[1]) begin next_state = S_1; next_count = 2'b00; end
                    else begin next_state = S_2; next_count = 2'b00; end
                end else begin next_state = S_2; next_count = count + 1'b1; end
            end else begin
                next_count = 2'b00;
                if (REQ[3]) next_state = S_3;
                else if (REQ[0]) next_state = S_0;
                else if (REQ[1]) next_state = S_1;
                else next_state = S_ideal;
            end
        end
		
        else if (present_state == S_3) begin
            if (REQ[3]) begin
                if (count == TIME_SLICE) begin
                    if (REQ[0]) begin next_state = S_0; next_count = 2'b00; end
                    else if (REQ[1]) begin next_state = S_1; next_count = 2'b00; end
                    else if (REQ[2]) begin next_state = S_2; next_count = 2'b00; end
                    else begin next_state = S_3; next_count = 2'b00; end
                end else begin next_state = S_3; next_count = count + 1'b1; end
            end else begin
                next_count = 2'b00;
                if (REQ[0]) next_state = S_0;
                else if (REQ[1]) next_state = S_1;
                else if (REQ[2]) next_state = S_2;
                else next_state = S_ideal;
            end
        end
    end

    // registered GNT from present_state (glitch-free)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) GNT <= 4'b0000;
        else begin
            case (present_state)
                S_0: GNT <= 4'b0001;
                S_1: GNT <= 4'b0010;
                S_2: GNT <= 4'b0100;
                S_3: GNT <= 4'b1000;
                default: GNT <= 4'b0000;
            endcase
        end
    end

endmodule



