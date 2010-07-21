library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is port(
	clk : in std_logic;
	count_ready : out std_logic;
	want_count : in std_logic;
	result : out std_logic_vector(31 downto 0)
	);
end;

architecture arch_counter of counter is

	type count_states is (count_null, count_idle, count_count);
	signal counter : std_logic_vector(31 downto 0);
	signal count : std_logic;
	signal count_state, next_count_state : count_states;
	signal count_reset : std_logic;


begin

process(count_state, want_count) begin
	case(count_state) is
		when count_null =>
			count_reset <= '1';
			next_count_state <= count_idle;
			count_ready <= '0';
			count <= '0';
		when count_idle =>
			count_reset <= '0';
			count_ready <= '1';
			count <= '0';
			if want_count = '1' then
				next_count_state <= count_count;
			else
				next_count_state <= count_idle;
			end if;
		when count_count =>
			count_ready <= '0';
			count_reset <= '0';
			if want_count = '1' then
				next_count_state <= count_count;
				count <= '0';
			else
				next_count_state <= count_idle;
				count <= '1';
			end if;
	end case;
end process;

process(count_reset,clk) begin
	if count_reset = '1' then
		counter <= "00000000000000000000000000000000";
		count_state <= count_idle;
	elsif clk'event and clk = '1' then
		if count = '1' then
			counter <= counter + 1;
		end if;
		count_state <= next_count_state;
	end if;
	result <= counter;
end process;

end arch_counter;
