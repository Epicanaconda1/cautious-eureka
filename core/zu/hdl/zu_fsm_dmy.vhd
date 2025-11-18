library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.zu_pck.all;

architecture rtl of zu_fsm is

  type state_type is (IDLE, START_AES, RUN_AES, DONE_AES);
  signal r_state, next_state : state_type;

  signal r_cnt, next_cnt : unsigned(7 downto 0) := (others => '0');


  signal r_done                 : std_logic := '0';
  signal r_zu_tdata_cnt_str     : std_logic := '0';
  signal r_zu_tdata_cnt         : std_logic_vector(7 downto 0) := (others => '0');
  signal r_inv_chiper_rst_n     : std_logic := '0';
  signal r_inv_chiper_start_str : std_logic := '0';


  signal next_done                 : std_logic;
  signal next_zu_tdata_cnt_str     : std_logic;
  signal next_zu_tdata_cnt         : std_logic_vector(7 downto 0);
  signal next_inv_chiper_rst_n     : std_logic;
  signal next_inv_chiper_start_str : std_logic;

begin


  REG_PROC : process(mclk)
  begin
    if rising_edge(mclk) then
      if rst = '1' or fsm_rst = '1' then
        r_state               <= IDLE;
        r_cnt                 <= (others => '0');
        r_done                <= '1';
        r_zu_tdata_cnt_str    <= '0';
        r_zu_tdata_cnt        <= (others => '0');
        r_inv_chiper_rst_n    <= '0';
        r_inv_chiper_start_str <= '0';
      else
        r_state               <= next_state;
        r_cnt                 <= next_cnt;
        r_done                <= next_done;
        r_zu_tdata_cnt_str    <= next_zu_tdata_cnt_str;
        r_zu_tdata_cnt        <= next_zu_tdata_cnt;
        r_inv_chiper_rst_n    <= next_inv_chiper_rst_n;
        r_inv_chiper_start_str <= next_inv_chiper_start_str;
      end if;
    end if;
  end process;


  process(all)
  begin

    next_state              <= r_state;
    next_cnt                <= r_cnt;
    next_done               <= '1';
    next_zu_tdata_cnt_str   <= '0';
    next_zu_tdata_cnt       <= std_logic_vector(r_cnt);
    next_inv_chiper_rst_n   <= '1';
    next_inv_chiper_start_str <= '0';

    case r_state is

      when IDLE =>
        if start_str = '1' then
          next_state <= START_AES;
        end if;

      when START_AES =>
        next_cnt <= (others => '0');
        next_done <= '0';
        next_inv_chiper_start_str <= '1'; 
        next_state <= RUN_AES;

      when RUN_AES =>
        
        

        if inv_chiper_tvalid = '1' and inv_chiper_tready = '1' then
          next_cnt <= r_cnt + 1;
        end if;

        if inv_chiper_done_str = '1' then
          next_state <= DONE_AES;
        end if;

      when DONE_AES =>
        next_done             <= '1';
        next_zu_tdata_cnt     <= std_logic_vector(r_cnt);
        next_zu_tdata_cnt_str <= '1';
        next_state            <= IDLE;

    end case;
  end process;


  done                 <= r_done;
  zu_tdata_cnt_str     <= r_zu_tdata_cnt_str;
  zu_tdata_cnt         <= r_zu_tdata_cnt;
  inv_chiper_rst_n     <= r_inv_chiper_rst_n;
  inv_chiper_start_str <= r_inv_chiper_start_str;

end rtl;