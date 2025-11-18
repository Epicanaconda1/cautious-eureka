library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scu_enable_sync is
    port (
        clk : in std_logic;
        rst : in std_logic;
        ena : in std_logic;
        tdata : in std_logic_vector(7 downto 0);
        tdata_out : out std_logic_vector(7 downto 0)
    );
    attribute direct_enable : string;
    attribute direct_enable of ena : signal is "yes";

end scu_enable_sync;

architecture rtl of scu_enable_sync is
    signal r_data, next_data : std_logic_vector(7 downto 0);

    begin
        process(all) is

        begin

                if (rst = '1') then
                    tdata_out <= (others => '0');
                    r_data <= (others => '0');
                elsif rising_edge(clk) then
                    if ena = '1' then
                        r_data <= tdata;
                        next_data <= r_data;
                    end if;
                end if;

        end process;
        
            tdata_out <= next_data;
end rtl;