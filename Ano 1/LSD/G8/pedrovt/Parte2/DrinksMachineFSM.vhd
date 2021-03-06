library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Done for Drink=1 when value received is at least 0.60

entity DrinksMachineFSM is	
	port(reset   : in  std_logic;
		  clk     : in  std_logic;
		  coin_20 : in  std_logic;
		  coin_50 : in  std_logic;
		  --state 	 : out std_logic_vector(1 downto 0); -- For testing purposes
		  drink   : out std_logic);
end DrinksMachineFSM;

architecture Behavioral of DrinksMachineFSM is

	-- States
	type TState is (S0, S1, S2, S3);
	signal pState, nState : TState;
	
	begin
		sync_proc: process(clk)
		begin
			if (rising_edge(clk)) then
				if (reset = '0') then 			-- reset = 0 since i used key for reset
					pState <= S0;
				else
					pState <= nState;
				end if;
			end if;
		end process;
		
		comb_proc: process(pState, coin_20, coin_50)			
		begin
			drink <= '0';
			case pState is 
				when S0 =>
					if (coin_20 = '1')  then
						nState <= S1;
					elsif (coin_50 = '1' and coin_20 = '0') then
						nState <= S2;
					else 
						nState <= S0;
					end if;
				when S1 =>
					if (coin_20 = '1') then
						nState <= S2;
					elsif (coin_50 = '1' and coin_20 = '0') then
						nState <= S3;
					else 
						nState <= S1;
					end if;
				when S2 =>
					if (coin_20 = '1' or coin_50 = '1') then
						nState <= S3;
					else 
						nState <= S2;
					end if;
				when S3 =>
					drink <= '1';
					nState <= S0;
				when others =>  --catch all
					nState <= S0;
				end case;
			end process;
		
		-- For testing purposes
--		with pState select state <= 
--			"00" when S0, 
--			"01" when S1,
--			"10" when S2,
--			"11" when S3;
--			
				
	end Behavioral;
	