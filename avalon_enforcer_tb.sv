//////////////////////////////////////////////////////////////////
///
/// Project Name: 	unknown_project
///
/// File Name: 		unknown_module_tb.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Yael Karisi
///
/// Date Created: 	19.3.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	?????
///
//////////////////////////////////////////////////////////////////

module avalon_enforced_tb();

	localparam int DATA_WIDTH_IN_BYTES = 16;

	logic clk;
	logic rst;

	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) untrusted_msg();
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) enforced_msg();

	logic missing_sop_error;
	logic double_sop_error;
	
	avalon_enforced #(

		.clk(clk),
		.rst(rst),

		.untrusted_msg(untrusted_msg.slave),
		.enforced_msg(enforced_msg.master),

		.missing_sop_error(missing_sop_error),
		.double_sop_error(double_sop_error)
	) avalon_enforced_inst();

	always #5 clk = ~clk;

	initial begin 
		clk 				= 1'b0;
		rst 				= 1'b0;
		start 				= 1'b0;

		// untrusted_msg.CLEAR_MASTER();
		untrusted_msg.data 	    = '0;
		untrusted_msg.valid 	= 1'b0;
		untrusted_msg.sop 	    = 1'b0;
		untrusted_msg.eop 	    = 1'b0;
		untrusted_msg.empty 	= 0;

		// enforced_msg.CLEAR_SLAVE();
		untrusted_msg.rdy 	    = 1'b1;


		#50;
		rst 				= 1'b1;

		@(posedge clk);
		untrusted_msg.valid     = 1'b1;
		untrusted_msg.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		untrusted_msg.sop 		= 1'b1;
		//@(posedge clk);
		//@(posedge clk);
		//untrusted_msg.sop       = 1'b0;
		@(posedge clk);
		@(posedge clk);
		untrusted_msg.eop       = 1'b0;
		@(posedge clk);

		//untrusted_msg.CLEAR_MASTER();
		untrusted_msg.data 	    = '0;
		untrusted_msg.valid 	= 1'b0;
		untrusted_msg.sop 	    = 1'b0;
		untrusted_msg.eop 	    = 1'b0;
		untrusted_msg.empty 	= 0;

		#15;

		$finish();

	end

endmodule