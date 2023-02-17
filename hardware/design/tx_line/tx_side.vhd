library ieee;
use ieee.std_logic_1164.all;

entity tx_side is
    port (
        ws:     in  std_logic;
        bclk:   in  std_logic;
        lrck:   in  std_logic;
        tx_l:   in  std_logic_vector(23 downto 0);
        tx_r:   in  std_logic_vector(23 downto 0);
        dout:   out std_logic
    );
end tx_side;

architecture Behavioral of tx_side is
    signal s_data: std_logic_vector(47 downto 0); -- Serijalizirani podaci
    signal s_count: integer range 0 to 63;      -- Brojač bitova
    signal s_latch: std_logic;                  -- Latch signal
    
begin
    -- Serijalizacijski modul
    dout <= s_data(s_count);
    
    -- Generiranje podataka za serijalizaciju
    process (bclk, lrck)
    begin
        if rising_edge(bclk) then
            -- Dohvaćanje podataka iz bafera i prebacivanje u serijalizacijski registar
            if s_count = 0 then
                s_data(23 downto 0) <= tx_l;
                s_data(47 downto 24) <= tx_r;
            end if;
            
            -- Brojanje bitova
            s_count <= (s_count + 1) mod 64;
            
            -- Upravljanje sa LRCK signalom za sinkronizaciju
            if lrck /= s_latch then
                s_latch <= lrck;
                if lrck = '1' then
                    s_count <= 0;
                end if;
            end if;
        end if;
    end process;
end Behavioral;