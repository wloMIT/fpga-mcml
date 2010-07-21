library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--	Note: No input because JTAG is implicit
entity mcml_hw is port(
	OSC1_50 : in std_logic
	);
end mcml_hw;

architecture rtl of mcml_hw is
	
component tmj_portmux
	port(
	   result		:	in std_logic_vector(31 downto 0);
	   result_ready		:	in std_logic;
	   want_result		:	out std_logic;
	   constants		:	out std_logic_vector(31 downto 0);
	   want_constants	:	in std_logic;
	   constants_ready	:	out std_logic;
	   reset		:	out std_logic_vector(0 downto 0);
	   done		:	in std_logic_vector(0 downto 0);
	   clk : in std_logic);
end component;

component pll_50_to_x

	port(
	   inclk0		:	in std_logic;
	   c0			:	out std_logic);
end component;


-- Skeleton Module (../Skeleton/Skeleton.v) 
component Skeleton
port ( 	clk: in std_logic; 
	reset: in std_logic; 
	constants : in std_logic_vector (31 downto 0);
	read_constants: in std_logic;
	result: out std_logic_vector (31 downto 0);
	inc_result: in std_logic;
	calc_in_progress: out std_logic); 
end component;

type skeleton_states is (	reset_circuit,
				idle, 
				get_constants,
				wait_for_lowered_constants_ready,
				read_or_calc,
				wait_for_mcml_done,
				send_result,
				wait_for_want_result,
				wait_for_lowered_want_result);
			
signal tmj_glbclk0 : std_logic;
signal result					:	std_logic_vector(31 downto 0);
signal constants				:	std_logic_vector(31 downto 0);
signal result_ready, want_result		:	std_logic;
signal constants_ready, want_constants		:	std_logic;
signal reset					:	std_logic_vector(0 downto 0);
signal done					:	std_logic_vector(0 downto 0);

signal calc_in_progress				:	std_logic;
signal read_constants				:	std_logic;

signal skeleton_state, next_skeleton_state	:	skeleton_states;
signal reset_bit				:	std_logic;
signal inc_result				:	std_logic; 


begin

-- Set clock frequency using PLL
pll_50_inst: pll_50_to_x port map (
	inclk0 => OSC1_50,
	c0 => tmj_glbclk0);

tmj_portmux_inst: tmj_portmux port map (
	result => result,
	result_ready => result_ready,
	want_result => want_result,
	constants => constants,
	want_constants => want_constants,
	constants_ready => constants_ready,
	reset => reset,
	done => done,
	clk => tmj_glbclk0);

	
	
skeleton_inst: Skeleton port map (
		
	clk		=>		tmj_glbclk0,
	reset		=>		reset_bit,
	constants	=>		constants,
	read_constants	=>		read_constants,
	result		=>		result,
	inc_result	=>		inc_result,
	calc_in_progress	=>		calc_in_progress);

proc0: process(want_result, result_ready, skeleton_state) begin
	if(skeleton_state = wait_for_lowered_want_result) then
		inc_result <= not (want_result or result_ready);
	else
		inc_result <= '0';
	end if;
end process;

proc1: process(skeleton_state, calc_in_progress, want_result, constants_ready, constants) begin

	case(skeleton_state) is
		when reset_circuit =>
			want_constants	<= '0';
			result_ready	<= '0';

			read_constants <= '0';

			next_skeleton_state <= idle;
			
		when idle =>
			want_constants	<= '1';
			result_ready	<= '0';

			read_constants <= '0';
			
			if (constants_ready = '1') then
				next_skeleton_state <= get_constants;
			else
				next_skeleton_state <= idle;
			end if;
		when get_constants => 
			want_constants 	<= '1';
			result_ready	<= '0';

			read_constants <= '1';
			
			next_skeleton_state <= wait_for_lowered_constants_ready;
		
		when wait_for_lowered_constants_ready =>
			want_constants	<= '0';
			result_ready	<= '0';

			read_constants <= '0';
			
			if (constants_ready = '1') then
				next_skeleton_state <= wait_for_lowered_constants_ready;
			else
				next_skeleton_state <= read_or_calc;
			end if;
		when read_or_calc =>
			want_constants	<= '0';
			result_ready	<= '0';

			read_constants <= '0';
			
			if (calc_in_progress = '0') then
				next_skeleton_state <= idle;
			else
				next_skeleton_state <= wait_for_mcml_done;
			end if;
		when wait_for_mcml_done =>
			want_constants	<= '0';
			result_ready	<= '0';

			read_constants <= '0';

			if (calc_in_progress = '0') then
				next_skeleton_state <= send_result;
			else
				next_skeleton_state <= wait_for_mcml_done;
			end if;
		when send_result =>
			want_constants	<= '0';
			result_ready	<= '1';

			read_constants <= '0';
			
			next_skeleton_state <= wait_for_want_result;
		when wait_for_want_result =>
			want_constants	<= '0';
			result_ready	<= '1';

			read_constants <= '0';
			
			if (want_result = '1') then
				next_skeleton_state <= wait_for_lowered_want_result;
			else
				next_skeleton_state <= wait_for_want_result;
			end if;
		when wait_for_lowered_want_result =>
			want_constants	<= '0';
			result_ready	<= '0';

			read_constants <= '0';
			
			if (want_result = '0') then
				next_skeleton_state <= send_result;
			else
				next_skeleton_state <= wait_for_lowered_want_result;
			end if;
		when others =>
			want_constants	<= '0';
			result_ready	<= '0';

			read_constants <= '0';

			next_skeleton_state <= reset_circuit;
	end case;
end process;

latchdone: process(tmj_glbclk0) begin
	if tmj_glbclk0'event and tmj_glbclk0 = '1'
	then
		case(skeleton_state) is
			when reset_circuit =>
				done	<= "0";
			when idle =>
				done	<= "0";
			when get_constants => 
				done	<= "0";
			when wait_for_lowered_constants_ready =>
				done	<= "0";
			when read_or_calc =>
				done	<= "0";
			when wait_for_mcml_done =>
				done	<= "0";
			when send_result =>
				done	<= "1";
			when wait_for_want_result =>
				done	<= "1";
			when wait_for_lowered_want_result =>
				done	<= "1";
			when others =>
				done	<= "0";
		end case;
	end if;
end process;

latch: process(reset,tmj_glbclk0) begin
	if tmj_glbclk0'event and tmj_glbclk0 = '1'
	then
		if reset = "1" then
			reset_bit <= '1';
			skeleton_state	<= reset_circuit;
		else
			reset_bit <= '0';
			skeleton_state <= next_skeleton_state;
		end if;
	end if;
end process;

end rtl;

