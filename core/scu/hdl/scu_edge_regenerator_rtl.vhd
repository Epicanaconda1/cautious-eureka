
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of scu_edge_regenerator is

  signal ena_level      : std_logic;
  signal ena_level_s1   : std_logic;
  signal ena_level_s2   : std_logic;
  signal ena_level_next : std_logic;
  
begin

  P_FAST_DOMAIN: process(rst_fast, clk_fast) is
  begin

    -- OPPGAVE 2
    if (rst_fast = '1') then
      ena_level <= '0';
    elsif rising_edge(clk_fast) then
      if (ena_fastclk_str = '1') then
        ena_level <= not ena_level;
      end if;
    end if;
  end process P_FAST_DOMAIN;


  P_SLOW_DOMAIN: process(rst_slow, clk_slow) is
  begin

    -- OPPGAVE 2
    if (rst_slow = '1') then
      ena_level_s1 <= '0';
      ena_level_s2 <= '0';
      ena_level_next <= ena_level_s2;
    elsif rising_edge(clk_slow) then
      ena_level_s1 <= ena_level;
      ena_level_s2 <= ena_level_s1;
      ena_level_next <= ena_level_s2;
    end if;
    
  end process P_SLOW_DOMAIN;

  -- Concurrent signal assignment
  -- NOTE: Slow clock domain
  ena_slowclk_str <= ena_level_next xor ena_level_s2;  

end rtl;
