library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab4 is
    Port (
        clk : in STD_LOGIC;

        l_marc : in STD_LOGIC;
        l_res : in STD_LOGIC;
        v_marc : in STD_LOGIC;
        v_res : in STD_LOGIC;
        t_res : in STD_LOGIC;

        dis : out STD_LOGIC_VECTOR(7 downto 0);
        seg : out STD_LOGIC_VECTOR(6 downto 0);

        FIN : out STD_LOGIC
    );
end lab4;

architecture Behavioral of lab4 is
    signal counter_clk : STD_LOGIC := '0';
    signal disp_clk : STD_LOGIC := '0';
    signal aux_counter_Hz : integer := 0;
    signal aux_display_Hz : integer := 0;

    constant counter_Hz : integer := 50_000_000;
    constant display_Hz : integer := 10_000;

    signal l_puntos : integer := 0;
    signal v_puntos : integer := 0;
    signal segundos : integer := 720;

    signal display_counter : integer range 0 to 7 := 0;
    
    function decodificador (numero : integer) return STD_LOGIC_VECTOR is
    begin
        case numero is
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when others => return "1111111";
       end case;
    end function;        

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if aux_counter_Hz = counter_Hz then
                counter_clk <= not counter_clk;
                aux_counter_Hz <= 0;
            else
                aux_counter_Hz <= aux_counter_Hz + 1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if aux_display_Hz = display_Hz then
                disp_clk <= not disp_clk;
                aux_display_Hz <= 0;
            else
                aux_display_Hz <= aux_display_Hz + 1;
            end if;
        end if;
    end process;

    process(counter_clk, t_res)
    begin
        if t_res = '1' then
            segundos <= 720;
            FIN <= '0';
        elsif rising_edge(counter_clk) then
            if segundos > 0 then
                segundos <= segundos - 1;
                FIN <= '0';
            elsif segundos = 0 then
                FIN <= '1';
            end if;
        end if;
    end process;

    process(l_marc, l_res, v_marc, v_res)
    begin
        if l_res = '1' then
            l_puntos <= 0;
        elsif rising_edge(l_marc) then
            
            l_puntos <= l_puntos + 1;
            if l_puntos = 99 then
                l_puntos <=0;
            end if;
        end if;

        if v_res = '1' then
            v_puntos <= 0;
        elsif rising_edge(v_marc) then
            v_puntos <= v_puntos + 1;
            if v_puntos = 99 then
                v_puntos <=0;
            end if;
        end if;
    end process;

    process(disp_clk)
        variable decenas, unidades : integer;
    begin
        if rising_edge(disp_clk) then
            case display_counter is
           
                when 0 =>
                    dis <= "01111111";
                    decenas := l_puntos / 10;
                    seg <= decodificador(decenas);
                when 1 =>
                    dis <= "10111111";
                    unidades := l_puntos mod 10;
                    seg <= decodificador(unidades);

                when 2 =>
                    dis <= "11011111";
                    decenas := (segundos / 60) / 10;
                    seg <= decodificador(decenas);
                when 3 =>
                    dis <= "11101111";
                    unidades := (segundos / 60) mod 10;
                    seg <= decodificador(unidades);
                when 4 =>
                    dis <= "11110111";
                    decenas := (segundos mod 60) / 10;
                    seg <= decodificador(decenas);
                when 5 =>
                    dis <= "11111011";
                    unidades := (segundos mod 60) mod 10;
                    seg <= decodificador(unidades);

                when 6 =>
                    dis <= "11111101";
                    decenas := v_puntos / 10;
                    seg <= decodificador(decenas);
                when 7 =>
                    dis <= "11111110";
                    unidades := v_puntos mod 10;
                    seg <= decodificador(unidades);

                when others =>
                    dis <= "11111111";
            end case;
            display_counter <= (display_counter + 1);
            if display_counter = 8 then
                display_counter <= 0;
            end if;
            
        end if;
    end process;

end Behavioral;