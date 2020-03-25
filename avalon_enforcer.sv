//////////////////////////////////////////////////////////////////
///
/// Project Name: 	avalon_enforced
///
/// File Name: 		avalon_enforced.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Reut Lev
///
/// Date Created: 	25.3.2020
///
/// Company: 		-----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	The program gets a 
///
//////////////////////////////////////////////////////////////////

package avalon_enforced_pack;
	
	typedef enum {
		WAIT_FOR_MESSAGE,
		RECIEVE_MASSAGE
	} avalon_enforced_sm_t;

endpackage


module avalon_enforced

#(
	parameter int DATA_WIDTH = 8
)
(
	input logic 			clk,
	input logic 			rst,

	avalon_st_if.slave 		untrusted_msg,
	avalon_st_if.master 	enforced_msg,

	output logic 			missing_sop_error,
	output logic 			double_sop_error,
);

import avalon_enforced_pack::*;

avalon_enforced_sm_t 		current_state;

always_ff @(posedge clk or negedge rst) begin
	if(~rst) begin
		current_state <= WAIT_FOR_MESSAGE;
	end else begin
		case (current_state)
			WAIT_FOR_MESSAGE: begin
				if (untrusted_msg.valid & untrusted_msg.sop & ~untrusted_msg.eop) begin
					// valid protocol - start getting a message 
					enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  untrusted_msg.valid;
		            enforced_msg.sop    <=  untrusted_msg.sop;
		            enforced_msg.eop    <=  untrusted_msg.eop;
		            enforced_msg.data   <=  untrusted_msg.data;
		            enforced_msg.empty  <=  untrusted_msg.empty;
		            current_state <= RECIEVE_MASSAGE;

		            missing_sop_error   <=  1'b0;
		            double_sop_error    <=  1'b0;

				end else if (~untrusted_msg.valid) begin
					// raise indication!! invalid input (valid before sop) - reset all outputs to 0
					enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  1'b0;
		            enforced_msg.sop    <=  1'b0;
		            enforced_msg.eop    <=  1'b0;
		            enforced_msg.data   <=  1'b0;
		            enforced_msg.empty  <=  0;

		            missing_sop_error   <=  1'b0;
		            double_sop_error    <=  1'b0;

				end else if (untrusted_msg.valid & ~untrusted_msg.sop) begin 
					// valid information before sop - raise missing_sop_error
		            enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  1'b0;
		            enforced_msg.sop    <=  1'b0;
		            enforced_msg.eop    <=  1'b0;
		            enforced_msg.data   <=  1'b0;
		            enforced_msg.empty  <=  0;

		            missing_sop_error   <=  1'b1;
		            double_sop_error    <=  1'b0;

				end else if (untrusted_msg.valid & untrusted_msg.sop & untrusted_msg.eop) begin 
					// short message (sop and eop raised together)
					enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  untrusted_msg.valid;
		            enforced_msg.sop    <=  untrusted_msg.sop;
		            enforced_msg.eop    <=  untrusted_msg.eop;
		            enforced_msg.data   <=  untrusted_msg.data;
		            enforced_msg.empty  <=  untrusted_msg.empty;

		            missing_sop_error   <=  1'b0;
		            double_sop_error    <=  1'b0;
				end
			end

			RECIEVE_MASSAGE: begin
				if (untrusted_msg.valid & ~untrusted_msg.sop & untrusted_msg.eop) begin
					// valid protocol - finished recieving the message 
					enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  untrusted_msg.valid;
		            enforced_msg.sop    <=  untrusted_msg.sop;
		            enforced_msg.eop    <=  untrusted_msg.eop;
		            enforced_msg.data   <=  untrusted_msg.data;
		            enforced_msg.empty  <=  untrusted_msg.empty;
		            current_state <= WAIT_FOR_MESSAGE;

		            missing_sop_error   <=  1'b0;
		            double_sop_error    <=  1'b0;

				end else if (untrusted_msg.valid & untrusted_msg.sop) begin
					// raise indication!! invalid inputs (sop befoer eop) - reset all outputs as 0
					enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  1'b0;
		            enforced_msg.sop    <=  1'b0;
		            enforced_msg.eop    <=  1'b0;
		            enforced_msg.data   <=  1'b0;
		            enforced_msg.empty  <=  0;

		            missing_sop_error   <=  1'b0;
		            double_sop_error    <=  1'b1;

				end else if (untrusted_msg.valid & ~untrusted_msg.eop & untrusted_msg.empty != 0) begin
					// got empty without eop, irrelevant - reset empty to 0 
					enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  untrusted_msg.valid;
		            enforced_msg.sop    <=  untrusted_msg.sop;
		            enforced_msg.eop    <=  untrusted_msg.eop;
		            enforced_msg.data   <=  untrusted_msg.data;
		            enforced_msg.empty  <=  0;

		            missing_sop_error   <=  1'b0;
		            double_sop_error    <=  1'b0;

				end else if (~untrusted_msg.valid) begin
					// invalid inputs - reset all outputs as 0
					enforced_msg.ready  <=  untrusted_msg.ready;
		            enforced_msg.valid  <=  1'b0;
		            enforced_msg.sop    <=  1'b0;
		            enforced_msg.eop    <=  1'b0;
		            enforced_msg.data   <=  1'b0;
		            enforced_msg.empty  <=  0;

		            missing_sop_error   <=  1'b0;
		            double_sop_error    <=  1'b0;
				end	
			end
		endcase
	end
end

endmodule