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
/// Description: 	Gets untrusted message, checks for valid protocol,
///                 change message accordingly.
///
//////////////////////////////////////////////////////////////////

module avalon_enforced

#()
(
	input logic             clk,
	input logic             rst,

	avalon_st_if.slave      untrusted_msg,
	avalon_st_if.master     enforced_msg,

	// Indication - got valid out of message
	output logic            missing_sop_error,
	// Indication - start new message before ending the last one
	output logic            double_sop_error,
);

//////////////////////////////////////////
//// Typedefs ////////////////////////////
//////////////////////////////////////////

typedef enum logic {
	WAIT_FOR_MESSAGE,
	RECIEVE_MASSAGE
} avalon_enforced_sm_t;

//////////////////////////////////////////
//// Declarations ////////////////////////
//////////////////////////////////////////

avalon_enforced_sm_t 		current_state;

//////////////////////////////////////////
//// Logic ///////////////////////////////
//////////////////////////////////////////

always_ff @(posedge clk or negedge rst) begin : proc_enforcer_sm
	if(~rst) begin
		current_state <= WAIT_FOR_MESSAGE;
	end else begin
		case (current_state)
			WAIT_FOR_MESSAGE: begin
				// wait for sop - the module didn't get a message to sent yet 
             	if (untrusted_msg.valid & untrusted_msg.sop & ~untrusted_msg.eop & untrusted_msg.ready) begin
					current_state <= RECIEVE_MASSAGE;
				end
			end

			RECIEVE_MASSAGE: begin
				// wait for eop - sending message in progress
				if (untrusted_msg.valid & ~untrusted_msg.sop & untrusted_msg.eop & untrusted_msg.ready) begin
					current_state <= WAIT_FOR_MESSAGE;
				end
			end
		endcase // current_state
      end
	end
end

always_comb begin : proc_enforced_message_out
	case (current_state)
		WAIT_FOR_MESSAGE: begin
          	double_sop_error   =  1'b0;          	
			if (untrusted_msg.valid & untrusted_msg.sop) begin
				// valid protocol - start getting a message 
	            enforced_msg.valid  =  untrusted_msg.valid;
	            enforced_msg.sop    =  untrusted_msg.sop;
	            enforced_msg.eop    =  untrusted_msg.eop;
              	
              	missing_sop_error   =  1'b0;      	

			end else begin
				// got invalid inputs (valid not raised) - reset all outputs as 0
	            enforced_msg.valid  =  1'b0;
	            enforced_msg.sop    =  1'b0;
	            enforced_msg.eop    =  1'b0;

                // raise indication!! invalid input (valid before sop)
                missing_sop_error   =  untrusted_msg.valid & ~untrusted_msg.sop & ;
              
			end 
		end

		RECIEVE_MASSAGE: begin
          	missing_sop_error   =  1'b0; // 
			if (untrusted_msg.valid & ~untrusted_msg.sop) begin
				// valid protocol - finished recieving the message 
	            enforced_msg.valid  =  untrusted_msg.valid;
	            enforced_msg.sop    =  untrusted_msg.sop;
	            enforced_msg.eop    =  untrusted_msg.eop;

              	double_sop_error   =  1'b0;

			end else begin
	            // got invalid inputs (valid not raised) - reset all outputs as 0
	            enforced_msg.valid  =  1'b0;
	            enforced_msg.sop    =  1'b0;
	            enforced_msg.eop    =  1'b0;

                // raise indication!! invalid inputs (sop befoer eop)
                double_sop_error    =  untrusted_msg.valid & untrusted_msg.sop;
              
        	end
		end
	endcase

end


assign enforced_msg.empty = enforced_msg.eop   ? untrusted_msg.empty : 0; // empty irrelevant without eop
assign enforced_msg.data  = enforced_msg.valid ? untrusted_msg.data  : 0; // send data only when it's valid
assign enforced_msg.ready =  untrusted_msg.ready; // signal from the protected module, don't need any change

endmodule