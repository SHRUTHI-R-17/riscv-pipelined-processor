`timescale 1ns/1ps

module branch_predictor (
    input        clk, rst,
    input        branch,
    input        actual_taken,
    input [31:0] pc,
    output reg   predicted_taken,
    output reg [31:0] predicted_target,
    output reg   prediction_correct,
    // Stats
    output reg [31:0] total_predictions,
    output reg [31:0] correct_predictions
);
    // 2-bit saturating counter
    // 00=strongly not taken, 01=weakly not taken
    // 10=weakly taken,       11=strongly taken
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state               <= 2'b01; // weakly not taken
            total_predictions   <= 0;
            correct_predictions <= 0;
            prediction_correct  <= 0;
        end else if (branch) begin
            total_predictions <= total_predictions + 1;

            // Check if prediction was correct
            prediction_correct <= (predicted_taken == actual_taken);
            if (predicted_taken == actual_taken)
                correct_predictions <= correct_predictions + 1;

            // Update state based on actual outcome
            case (state)
                2'b00: state <= actual_taken ? 2'b01 : 2'b00;
                2'b01: state <= actual_taken ? 2'b10 : 2'b00;
                2'b10: state <= actual_taken ? 2'b11 : 2'b01;
                2'b11: state <= actual_taken ? 2'b11 : 2'b10;
            endcase
        end
    end

    // Prediction based on current state
    always @(*) begin
        predicted_taken  = state[1]; // MSB determines prediction
        predicted_target = pc + 4;   // simplified: predict PC+4
    end
endmodule