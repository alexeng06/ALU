library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_4bit is
port( 	DATA1:in std_logic_vector(3 downto 0);
        DATA2:in std_logic_vector(3 downto 0);
        CMD:in std_logic_vector(3 downto 0);
        Change: in std_logic;
        OUTPUT:out std_logic_vector(3 downto 0);
        Overflow:out std_logic;
        Negativ:out std_logic;
        Zero:out std_logic);
end ALU_4bit;

architecture Behavioral of ALU_4bit is
    --5Bit Signal for ADD,SUB,MUL Bit for is for the Overflow
    signal Result: std_logic_vector(4 downto 0);
    --8Bit Signal for MUL(2 4Bit Number = 1 8Bit Number)
    signal ResultMul   : std_logic_vector(7 downto 0);
    
    begin
    process(Change,DATA1,DATA2,CMD) is
    begin
    --Möglichkeit die Schalter zu Verändern ohne das undefinierte Werte erreicht werden 
    if(Change = '1') then
    Overflow <= '0';
    Negativ <= '0';
    Zero <= '0';
    --Aufteilung nach der Gewünschten Funktion
    case CMD is
    --ADD
    when "0001"=>
        --Einfache Addtion in ein 5bit Vektor
        --Ist der Bit4 High ist ein  Overflow erreicht
        Result <= std_logic_vector(("0"&unsigned(DATA1) + unsigned(DATA2)));
        --OUTPUT
        OUTPUT <= Result(3 downto 0);
        --OVERFLOW
        Overflow <= Result(4);
        
    --SUB
    when "0010"=>
        Result <= std_logic_vector(("0"&unsigned(DATA1) - unsigned(DATA2)));
        --Flag Negativ and Negativ Result
        --Unsigned kann nicht kleiner 0 werden deshalb muss DATA1 von DATA2 abgezogen werden und der Negativ Flag muss auf HIGH gesetzt werden 
        if(DATA2 > DATA1)then
            Result <= std_logic_vector(("0"&unsigned(DATA2) - unsigned(DATA1)));
            Negativ <= '1';
        end if;
        --OUTPUT
        OUTPUT <= Result(3 downto 0);
        
    --DIV
    when "0011"=>
        if(DATA2 > "00000000") then
           Result <= std_logic_vector("0"&unsigned(DATA1) / unsigned(DATA2));
           OUTPUT <= Result(3 downto 0); 
        else
            OUTPUT <= "0000";
            Zero <= '1';
        end if;
      
    --MUL
    when "0100"=>
        --Multiplikation
        ResultMul <= std_logic_vector(unsigned(DATA1) * unsigned(DATA2));
        --if greater 15 Overflow
        if(ResultMul > "00001111") then
            Overflow <= '1';
        end if;
        --Set Output
        OUTPUT <= ResultMul(3 downto 0);
        
    --AND
    when "0101"=>
        OUTPUT <= DATA1 AND DATA2;
        
    --OR
    when "0110"=>
        OUTPUT <= DATA1 OR DATA2;
        
    --NOT DATA1
    when "0111"=>
        OUTPUT <= NOT DATA1;
        
    --DEFALUT
    when others =>
    --Default DATA1 OUTPUT and Flags
        OUTPUT <= DATA1;
        Overflow <= '1';
        Negativ <= '1';
        Zero <= '1';
    end case;
    end if;
    end process;

end Behavioral;
