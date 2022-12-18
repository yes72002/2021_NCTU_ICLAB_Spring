

module farm(input clk, INF.farm_inf inf);
import usertype::*;

Land_Information Land_data;

logic [31:0] deposit;
logic [7:0] id_store;
// logic [3:0] action_store;
Action action_store;
// logic [3:0] crop_store;
Crop_cat crop_store;
logic [15:0] amnt_store;
logic flag_rst;
logic flag_s_deposit;
logic flag_s_id;
logic flag_s_write_dram;
logic flag_id;
logic flag_action;
logic flag_cat;
logic flag_amnt;
logic test;
always_comb test = (id_store == 8'hF6);

Farm_state curr_state;
Farm_state next_state;

// inf.C_in_valid
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		inf.C_in_valid <= 0;
	else if ((curr_state == S_DEPOSIT) && (flag_s_deposit == 0))
		inf.C_in_valid <= 1;
	else if ((curr_state == S_ID) && (flag_s_id == 0))
		inf.C_in_valid <= 1;
	else if ((curr_state == S_WRITE_DRAM) && (flag_s_write_dram == 0))
		inf.C_in_valid <= 1;
	else
		inf.C_in_valid <= 0;
end
// inf.C_addr
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		inf.C_addr <= 0;
	else if (curr_state == S_DEPOSIT)
		inf.C_addr <= 8'd255;
	else if (curr_state == S_ID)
		inf.C_addr <= id_store;
	else
		inf.C_addr <= inf.C_addr;
end
// inf.C_r_wb
always_ff@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)
		inf.C_r_wb <= 0;
	else if(curr_state == S_DEPOSIT)
		inf.C_r_wb <= 1;
	else if(curr_state == S_ID)
		inf.C_r_wb <= 1;
	else
		inf.C_r_wb <= 0;
end
// inf.C_data_w
always_ff@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)
		inf.C_data_w <= 0;
	else
		inf.C_data_w <= {Land_data[7:0],Land_data[15:8],Land_data[23:16],Land_data[31:24]};
end

// deposit
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		deposit <= 0;
	else if ((curr_state == S_DEPOSIT) && (inf.C_out_valid))
		deposit <= {inf.C_data_r[7:0],inf.C_data_r[15:8],inf.C_data_r[23:16],inf.C_data_r[31:24]};
	else if (curr_state == S_SEED) begin
		if (Land_data.land_status == No_sta) begin
			case (crop_store)
				Potato: deposit <= deposit - 'd5 ;
				Corn  : deposit <= deposit - 'd10;
				Tomato: deposit <= deposit - 'd15;
				Wheat : deposit <= deposit - 'd20;
				default: deposit <= deposit;
			endcase
		end
		else
			deposit <= deposit;
	end
	else if (curr_state == S_REAP) begin
		if (Land_data.land_status == Fst_sta) begin
			case (Land_data.land_crop)
				Potato: deposit <= deposit + 'd10;
				Corn  : deposit <= deposit + 'd20;
				Tomato: deposit <= deposit + 'd30;
				Wheat : deposit <= deposit + 'd40;
				default: deposit <= deposit;
			endcase
		end
		else if (Land_data.land_status == Snd_sta) begin
			case (Land_data.land_crop)
				Potato: deposit <= deposit + 'd25;
				Corn  : deposit <= deposit + 'd50;
				Tomato: deposit <= deposit + 'd75;
				Wheat : deposit <= deposit + 'd100;
				default: deposit <= deposit;
			endcase
		end
		else
			deposit <= deposit;
	end
	else
		deposit <= deposit;
end
// id_store
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		id_store <= 0;
	else if (inf.id_valid)
		id_store <= inf.D.d_id[0];
	else
		id_store <= id_store;
end
// action_store
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		action_store <= No_action;
	else if (inf.act_valid)
		action_store <= inf.D.d_act[0];
	else
		action_store <= action_store;
end
// crop_store
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		crop_store <= No_cat;
	else if (inf.cat_valid)
		crop_store <= inf.D.d_cat[0];
	else
		crop_store <= crop_store;
end
// amnt_store
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		amnt_store <= 0;
	else if (inf.amnt_valid)
		amnt_store <= inf.D;
	else
		amnt_store <= amnt_store;
end
// Land_data
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		Land_data <= 0;
	else if ((curr_state == S_ID) && (inf.C_out_valid)) begin
		Land_data.land_id     <= inf.C_data_r[7:0];
		Land_data.land_status <= inf.C_data_r[15:12];
		Land_data.land_crop   <= inf.C_data_r[11:8];
		Land_data.water_amnt  <= {inf.C_data_r[23:16],inf.C_data_r[31:24]};
	end
	else if (curr_state == S_SEED) begin
		if (Land_data.land_status == No_sta) begin
			Land_data.land_status <= Zer_sta;
			Land_data.land_crop <= crop_store;
		end
		else
			Land_data <= Land_data;
	end
	else if (curr_state == S_WATER) begin
		if ((inf.complete) && ((Land_data.land_status == Zer_sta) || (Land_data.land_status == Fst_sta))) // be careful of overflow
			Land_data.water_amnt <= Land_data.water_amnt + amnt_store;
		else
			Land_data <= Land_data;
	end
	else if (curr_state == S_CALC) begin
		case (Land_data.land_crop)
			Potato: begin
				if (Land_data.water_amnt >= 16'h0080)
					Land_data.land_status <= Snd_sta;
				else if (Land_data.water_amnt >= 16'h0010)
					Land_data.land_status <= Fst_sta;
				else
					Land_data <= Land_data;
			end
			Corn  : begin
				if (Land_data.water_amnt >= 16'h0200)
					Land_data.land_status <= Snd_sta;
				else if (Land_data.water_amnt >= 16'h0040)
					Land_data.land_status <= Fst_sta;
				else
					Land_data <= Land_data;
			end
			Tomato: begin
				if (Land_data.water_amnt >= 16'h0800)
					Land_data.land_status <= Snd_sta;
				else if (Land_data.water_amnt >= 16'h0100)
					Land_data.land_status <= Fst_sta;
				else
					Land_data <= Land_data;
			end
			Wheat : begin
				if (Land_data.water_amnt >= 16'h2000)
					Land_data.land_status <= Snd_sta;
				else if (Land_data.water_amnt >= 16'h0400)
					Land_data.land_status <= Fst_sta;
				else
					Land_data <= Land_data;
			end
			default: Land_data <= Land_data;
		endcase	
	end
	else if ((curr_state == S_REAP) || (curr_state == S_STEAL)) begin
		if ((Land_data.land_status == Fst_sta) || (Land_data.land_status == Snd_sta)) begin
			Land_data.land_status <= No_sta;
			Land_data.water_amnt <= 0;
		end
		else
			Land_data <= Land_data;
	end
	else
		Land_data <= Land_data;
end
// flag_rst
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_rst <= 0;
	else if (curr_state == S_DEPOSIT)
		flag_rst <= 1;
	else
		flag_rst <= flag_rst;
end
// flag_s_deposit
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_s_deposit <= 0;
	else if (curr_state == S_DEPOSIT)
		flag_s_deposit <= 1;
	else
		flag_s_deposit <= 0;
end
// flag_s_id
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_s_id <= 0;
	else if (curr_state == S_ID)
		flag_s_id <= 1;
	else
		flag_s_id <= 0;
end
// flag_s_write_dram
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_s_write_dram <= 0;
	else if (curr_state == S_WRITE_DRAM)
		flag_s_write_dram <= 1;
	else
		flag_s_write_dram <= 0;
end
// flag_id
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_id <= 0;
	else if (inf.id_valid)
		flag_id <= 1;
	else if (curr_state == S_DONE)
		flag_id <= 0;
	else
		flag_id <= flag_id;
end
// flag_action
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_action <= 0;
	else if (inf.act_valid)
		flag_action <= 1;
	else if ((curr_state == S_CHECK_DEPO) || (curr_state == S_DONE) || (curr_state == S_REAP) || (curr_state == S_STEAL))
		flag_action <= 0;
	else
		flag_action <= flag_action;
end
// flag_cat
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_cat <= 0;
	else if (inf.cat_valid)
		flag_cat <= 1;
	else if (curr_state == S_DONE)
		flag_cat <= 0;
	else
		flag_cat <= flag_cat;
end
// flag_amnt
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		flag_amnt <= 0;
	else if (inf.amnt_valid)
		flag_amnt <= 1;
	else if (curr_state == S_DONE)
		flag_amnt <= 0;
	else
		flag_amnt <= flag_amnt;
end


// inf.out_valid
always_ff@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)
		inf.out_valid <= 0;
	else if(curr_state == S_CHECK_DEPO)
		inf.out_valid <= 1;
	else if((curr_state == S_DONE) || (curr_state == S_REAP) || (curr_state == S_STEAL))
		inf.out_valid <= 1;
	else
		inf.out_valid <= 0;
end
// inf.complete
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		inf.complete <= 0;
	else if (curr_state == S_IDLE) begin
		if ((action_store == Seed) && (Land_data.land_status != No_sta))
			inf.complete <= 0;
		else if ((action_store == Water) && (Land_data.land_status == No_sta))
			inf.complete <= 0;
		else if ((action_store == Water) && (Land_data.land_status == Snd_sta))
			inf.complete <= 0;
		else if (((action_store == Reap) || (action_store == Steal)) && (Land_data.land_status == No_sta))
			inf.complete <= 0;
		else if (((action_store == Reap) || (action_store == Steal)) && (Land_data.land_status == Zer_sta))
			inf.complete <= 0;
		else
			inf.complete <= 1;
	end
	else
		inf.complete <= inf.complete;
end
// inf.err_msg
always_ff@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)
		inf.err_msg <= No_Err;
	else if (curr_state == S_IDLE) begin
		if ((action_store == Seed) && (Land_data.land_status != No_sta))
			inf.err_msg <= Not_Empty;
		else if ((action_store == Water) && (Land_data.land_status == No_sta))
			inf.err_msg <= Is_Empty;
		else if ((action_store == Water) && (Land_data.land_status == Snd_sta))
			inf.err_msg <= Has_Grown;
		else if (((action_store == Reap) || (action_store == Steal)) && (Land_data.land_status == No_sta))
			inf.err_msg <= Is_Empty;
		else if (((action_store == Reap) || (action_store == Steal)) && (Land_data.land_status == Zer_sta))
			inf.err_msg <= Not_Grown;
		else
			inf.err_msg <= No_Err;
	end
	else
		inf.err_msg <= inf.err_msg;
end
// inf.out_info
always_ff@(posedge clk or negedge inf.rst_n) begin
	if (!inf.rst_n)
		inf.out_info <= 0;
	else if (!inf.complete)
		inf.out_info <= 0;
	else if ((curr_state == S_DONE) || (curr_state == S_REAP) || (curr_state == S_STEAL))
		inf.out_info <= Land_data;
	else
		inf.out_info <= 0;
end
// inf.out_deposit
always_ff@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)
		inf.out_deposit <= 0;
	else if(curr_state == S_CHECK_DEPO)
		inf.out_deposit <= deposit;
	else
		inf.out_deposit <= 0;
end

// curr_state
always_ff@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)
		curr_state <= S_IDLE;
	else
		curr_state <= next_state;
end
// next_state
always_comb begin
	case(curr_state)
		S_IDLE: begin
			if (flag_rst == 0)
				next_state = S_DEPOSIT;
			else if (inf.id_valid)
				next_state = S_WRITE_DRAM;
			else if ((flag_action) && (action_store == Seed) && (flag_cat) && (flag_amnt))
				next_state = S_SEED;
			else if ((flag_action) && (action_store == Water) && (flag_amnt))
				next_state = S_WATER;
			else if ((flag_action) && (action_store == Reap))
				next_state = S_REAP;
			else if ((flag_action) && (action_store == Steal))
				next_state = S_STEAL;
			else if ((flag_action) && (action_store == Check_dep))
				next_state = S_CHECK_DEPO;
			else
				next_state = S_IDLE;
		end
		S_DEPOSIT: begin // id_valid will high early
			if (inf.C_out_valid) next_state = S_ID;
			else                 next_state = S_DEPOSIT;
		end
		S_ID: begin
			if (inf.C_out_valid) next_state = S_IDLE;
			else                 next_state = S_ID;
		end
		S_SEED:  next_state = S_WATER;
		S_WATER: next_state = S_CALC;
		S_REAP:  next_state = S_IDLE;
		S_STEAL: next_state = S_IDLE;
		S_CHECK_DEPO: next_state = S_IDLE;
		S_WRITE_DRAM: begin
			if (inf.C_out_valid) next_state = S_ID;
			else                 next_state = S_WRITE_DRAM;
		end
		S_CALC:  next_state = S_DONE;
		S_DONE:  next_state = S_IDLE;
		default: next_state = S_IDLE;
	endcase	
end

endmodule