library ieee;
use ieee.std_logic_1164.all;

entity top is port(
	OSC1_50 : in std_logic
	);
end;

architecture arch_top of top is
	signal count_ready : std_logic;
	signal result : std_logic_vector(31 downto 0);
	signal want_count : std_logic;

component tmj_portmux
	port(
	result : in std_logic_vector(31 downto 0);
	count_ready : in std_logic;
	want_count : out std_logic;
	clk : in std_logic);
end component;


component counter
	port(
	clk : in std_logic;
	count_ready : out std_logic;
	want_count : in std_logic;
	result : out std_logic_vector(31 downto 0)
	);
end component;

begin


tmj_portmux_inst: tmj_portmux port map (
	result,
	count_ready,
	want_count,
	OSC1_50);

counter_inst: counter port map (
	OSC1_50,
	count_ready,
	want_count,
	result
	);

end arch_top;
