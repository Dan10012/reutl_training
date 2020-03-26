//////////////////////////////////////////////////////////////////
///
/// Project Name: 	avalon_enforced
///
/// File Name: 		avalon_st_if.sv
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
/// Description: 	Defines Avalon Stream interface 
///
//////////////////////////////////////////////////////////////////

import general_pack::*;

interface avalon_st_if #(parameter DATA_WIDTH_IN_BYTES = 16);
	logic 	[(DATA_WIDTH_IN_BYTES*$bits(byte)) - 1 : 0] data;
	logic 												valid;
	logic 												ready;
	logic 												sop;
	logic 												eop;
	logic 	[log2up_func(DATA_WIDTH_IN_BYTES) - 1 : 0] 	empty;

	modport slave 	(input data, input valid, output ready, input sop, input eop, input empty);

	modport master 	(output data, output valid, input ready, output sop, output eop, output empty);

endinterface