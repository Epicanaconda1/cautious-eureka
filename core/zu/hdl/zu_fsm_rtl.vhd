library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.zu_pck.all;

architecture rtl of zu_fsm is
    type state is (idle, encrypting);
    signal present_state, next_state : state;

    signal r_count, next_count       : unsigned(7 downto 0) := (others => '0');
    signal r_cnt_done                : std_logic;

begin

    REG_ASSIGNMENT: process(mclk) is
    begin
        if rst = '1' then
            present_state         <= idle;
            r_count               <= (others => '0');
            inv_chiper_rst_n      <= '0';
            zu_tdata_cnt_str      <= '0';

        elsif rising_edge(mclk) then
            present_state         <= next_state;
            r_count               <= next_count;
            inv_chiper_rst_n      <= '1';
            zu_tdata_cnt_str      <= r_cnt_done;
        
        end if;
    end process;

    zu_tdata_cnt          <= std_logic_vector(r_count);

    UPDATE_STATE: process(all) is
    begin
        next_state <= present_state;
        
        case present_state is

            when idle =>
                next_state  <= encrypting  when start_str;
            when encrypting =>
                next_state  <= idle        when inv_chiper_done_str;

        end case;
    end process;

    OUTPUT_STATE: process(all) is
    begin
        next_count                <= r_count;
        r_cnt_done                <= '0';
        done                      <= '1';


        case present_state is
            when idle =>
                inv_chiper_start_str     <= '0';
                
                if start_str = '1' then
                    inv_chiper_start_str <= '1';
                    next_count           <= (others => '0');
                end if;
            when encrypting =>
                done                     <= '0';
                if inv_chiper_done_str = '1' then
                    r_cnt_done           <= '1';
                end if;

                if inv_chiper_tvalid and inv_chiper_tready then
                    next_count           <= r_count + 1;
                end if;

                inv_chiper_start_str     <= '0';
        end case;

    end process;

end rtl;





