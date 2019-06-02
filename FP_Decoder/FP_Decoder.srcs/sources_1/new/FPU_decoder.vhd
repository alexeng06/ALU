library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FPU_decoder is
port(
    DATA:in std_logic_vector(3 downto 0);
    OutputData:out std_logic_vector(4 downto 0)
);
end FPU_decoder;

architecture Behavioral of FPU_decoder is

signal Decoded: std_logic_vector(4 downto 0);
signal Exponent: std_logic_vector(1 downto 0);

begin
    process(DATA) is
    begin
        
        Decoded(3 downto 2) <= Data(3 downto 2);
        Exponent <= Data(1 downto 0);
        
        case Exponent is
        
        when "00"=>
            OutputData <= Decoded;
        when "01"=>
            OutputData <= Decoded(3 downto 0) & "0";
        when "10"=>
            OutputData <= "00" & Decoded(4 downto 2);
        when "11"=>
            OutputData <= "0" & Decoded(4 downto 1);
        when others =>
            OutputData <= "00000";
        end case;
    end process;
end Behavioral;
