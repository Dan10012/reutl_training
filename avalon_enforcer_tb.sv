//////////////////////////////////////////////////////////////////
///
/// Project Name: 	avalon enforced
///
/// File Name: 		unknown_module_tb.sv
///
//////////////////////////////////////////////////////////////////
///
/// Author: 		Reut Lev
///
/// Date Created: 	26.3.2020
///
/// Company: 		----
///
//////////////////////////////////////////////////////////////////
///
/// Description: 	Gets untrusted message, check if its valid protocol, 
///                 change message accordingly   
///
//////////////////////////////////////////////////////////////////

module avalon_enforced_tb();

	localparam int DATA_WIDTH_IN_BYTES = 8;

	logic clk;
	logic rst;

	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) untrusted_msg();
	avalon_st_if #(.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES)) enforced_msg();

	logic missing_sop_error;
	logic double_sop_error;
	
	avalon_enforced 
	#()
	avalon_enforced_inst(
		.clk(clk),
		.rst(rst),

		.untrusted_msg(untrusted_msg.slave),
		.enforced_msg(enforced_msg.master),

		.missing_sop_error(missing_sop_error),
		.double_sop_error(double_sop_error)
	);

	always #5 clk = ~clk;
  	always #5 untrusted_msg.valid = ~untrusted_msg.valid;
      

	initial begin 
      	$dumpfile("dump.vcd");
      	$dumpvars(2);
		clk 				= 1'b0;
		rst 				= 1'b0;

		// untrusted_msg.CLEAR_MASTER();
		untrusted_msg.data 	    = '0;
		untrusted_msg.valid 	= 1'b0;
		untrusted_msg.sop 	    = 1'b0;
		untrusted_msg.eop 	    = 1'b0;
		untrusted_msg.empty 	= 0;

		// enforced_msg.CLEAR_SLAVE();
		untrusted_msg.ready 	= 1'b0;


		#10;
		rst 				    = 1'b1;

		@(posedge clk);
      	#0
		//untrusted_msg.valid     = 1'b1;
		untrusted_msg.data 		= {DATA_WIDTH_IN_BYTES{8'd34}};
		untrusted_msg.sop 		= 1'b1;
      	untrusted_msg.ready 	= 1'b0;
		@(posedge clk);
    	#0
      	untrusted_msg.sop 		= 1'b0;
     	untrusted_msg.ready 	= 1'b0;
		@(posedge clk);
      	#0
     	untrusted_msg.ready 	= 1'b0;
		//untrusted_msg.sop       = 1'b0;
		@(posedge clk);
      	#0
      	untrusted_msg.sop 		= 1'b0;
      	untrusted_msg.ready 	= 1'b0;
		//@(posedge clk);
      	@(posedge clk);
      	#0
		untrusted_msg.eop       = 1'b1;
      	untrusted_msg.ready 	= 1'b0;
		@(posedge clk);
		#0
		//untrusted_msg.CLEAR_MASTER();
		untrusted_msg.data 	    = '0;
		untrusted_msg.sop 	    = 1'b0;
		untrusted_msg.eop 	    = 1'b0;
		untrusted_msg.empty 	= 0;

		#15;

		$finish();

	end

endmodule