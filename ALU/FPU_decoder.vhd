library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FPU_decoder is
port(
    --Input Data 4 Bit Floating Point
    DATA:in std_logic_vector(3 downto 0);
    --Output Data 5 Bit Fixed Point
    OutputData:out std_logic_vector(5 downto 0)
);
end FPU_decoder;

architecture Behavioral of FPU_decoder is

-- Signal for Decoded Value
signal Decoded: std_logic_vector(5 downto 0);

-- Exponent of the Floating Point
signal Exponent: std_logic_vector(1 downto 0);

begin
    process(DATA) is
    begin
        
        --Load Matize
        Decoded(4 downto 2) <= "1" & Data(3 downto 2);
        
        --Load Exponent
        Exponent <= Data(1 downto 0);
        
        --Check Exponent and change Value with Matize * 2^Exponent
        case Exponent is
        
        when "00"=>
            OutputData <= Decoded;
        when "01"=>
            OutputData <= Decoded(4 downto 0) & "0";
        when "10"=>
            OutputData <= "000" & Decoded(4 downto 2);
        when "11"=>
            OutputData <= "00" & Decoded(4 downto 1);
        when others =>
            OutputData <= "00000";
        end case;
    end process;
end Behavioral;
