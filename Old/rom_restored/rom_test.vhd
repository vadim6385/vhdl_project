-- Copyright (C) 1991-2010 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II"
-- VERSION		"Version 9.1 Build 350 03/24/2010 Service Pack 2 SJ Web Edition"
-- CREATED		"Fri Sep 22 17:10:56 2023"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY rom_test IS 
	PORT
	(
		resetN :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		RX :  IN  STD_LOGIC;
		din :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		KEY :  IN  STD_LOGIC_VECTOR(3 TO 3);
		TX :  OUT  STD_LOGIC;
		HEX0S :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1S :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		LEDG :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 8)
	);
END rom_test;

ARCHITECTURE bdf_type OF rom_test IS 

COMPONENT uart
	PORT(resetN : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 write_din : IN STD_LOGIC;
		 rx : IN STD_LOGIC;
		 read_dout : IN STD_LOGIC;
		 din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 tx : OUT STD_LOGIC;
		 tx_ready : OUT STD_LOGIC;
		 rx_ready : OUT STD_LOGIC;
		 dout_ready : OUT STD_LOGIC;
		 dout_new : OUT STD_LOGIC;
		 dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT hexss
	PORT(din : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 ss : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rom
	PORT(clk : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	TFF_inst6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_4 <= '1';



b2v_inst : uart
PORT MAP(resetN => resetN,
		 clk => TFF_inst6,
		 write_din => SYNTHESIZED_WIRE_0,
		 rx => RX,
		 read_dout => SYNTHESIZED_WIRE_1,
		 din => din,
		 tx => TX,
		 rx_ready => SYNTHESIZED_WIRE_2,
		 dout_ready => LEDG(9),
		 dout_new => SYNTHESIZED_WIRE_0,
		 dout => SYNTHESIZED_WIRE_3);


b2v_inst1 : hexss
PORT MAP(din => data(3 DOWNTO 0),
		 ss => HEX0S);


LEDG(8) <= NOT(SYNTHESIZED_WIRE_2);



SYNTHESIZED_WIRE_1 <= NOT(KEY);




b2v_inst2 : hexss
PORT MAP(din => data(7 DOWNTO 4),
		 ss => HEX1S);


b2v_inst3 : rom
PORT MAP(clk => clk,
		 address => SYNTHESIZED_WIRE_3,
		 data => data);


PROCESS(clk)
VARIABLE TFF_inst6_synthesized_var : STD_LOGIC;
BEGIN
IF (RISING_EDGE(clk)) THEN
	TFF_inst6_synthesized_var := TFF_inst6_synthesized_var XOR SYNTHESIZED_WIRE_4;
END IF;
	TFF_inst6 <= TFF_inst6_synthesized_var;
END PROCESS;


END bdf_type;