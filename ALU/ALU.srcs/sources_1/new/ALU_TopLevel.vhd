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
        Zero:out std_logic;
        FPUOverflow: out std_logic);
end ALU_4bit;

architecture Behavioral of ALU_4bit is
    --5Bit Signal for ADD,SUB,MUL Bit for is for the Overflow
    signal Result: std_logic_vector(4 downto 0);
    --8Bit Signal for MUL(2 4Bit Number = 1 8Bit Number)
    signal ResultMul   : std_logic_vector(7 downto 0);
    
    --Fixed Point Signal
    signal FPUData1: std_logic_vector(4 downto 0);
    signal FPUData2: std_logic_vector(4 downto 0);
    
    --Floating Point Output
    signal FPUOutput: std_logic_vector(3 downto 0);
    signal FPUResult: std_logic_vector(9 downto 0);
    
    --Signal after Floting Point Multiplication
    signal FPUMulResult: std_logic_vector(9 downto 0);
    
    --Signal with inverse Value
    signal FPUInverse: std_logic_vector(3 downto 0);

    --Floating Point Encoder
    component FPU_Encoder is
        port(
            DATA:in std_logic_vector(4 downto 0);
            OutputData:out std_logic_vector(3 downto 0);
            OVF:out std_logic
        );
    end component;
    
    --Floating Point Decoder
    component FPU_decoder is
        port(
            DATA:in std_logic_vector(3 downto 0);
            OutputData:out std_logic_vector(4 downto 0)
        );
    end component;
    
    begin
    
    --2 Decoder for 2 Inputs
    decoderData1: FPU_decoder port map(DATA => DATA1, OutputData => FPUData1);
    decoderData2: FPU_decoder port map(DATA => DATA2, OutputData => FPUData2);
    
    -- Encoder for Output
    encoderOutput: FPU_Encoder port map(DATA => FPUResult(4 downto 0), OutputData => FPUOutput, OVF => FPUOverflow );
    
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
        --Multiplication
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
        
    --FP ADD
    when "1000" =>
        -- Addition of Fixedpoint
        FPUResult(5 downto 0) <= std_logic_vector(unsigned("0"&FPUData1) + unsigned(FPUData2));
        
        --Check Overflow
        if(FPUResult(9 downto 5) > "00000") then
            Overflow <= '1';
        end if;
        OUTPUT <= FPUOutput;
        
     --FP SUB
    when "1001" =>
         -- Substraction of Fixedpoint
        FPUResult(4 downto 0) <= std_logic_vector(unsigned(FPUData1) - unsigned(FPUData2));
        OUTPUT <= FPUOutput;
        
     --FP DIV
    when "1010" =>
        --Check Divison with Zero
        if(FPUData2 = "00000") then
            OUTPUT <= "0000";
            Zero <= '1';
        else
            --Check if Divisor smaller 1
            if(FPUData2 <= "00111") then
                -- Build Inverse of Divisor
                FPUInverse <= FPUData2(0) & FPUData2(1)& FPUData2(2) & "0";
                --Multiplikation with Divisor
                FPUResult(8 downto 0) <= std_logic_vector(unsigned(FPUData1) * unsigned(FPUInverse));
                --Check Overflow
                if(FPUResult(9 downto 5) > "00000") then
                    Overflow <= '1';
                end if;
            else
                --Division of Fixed Point
                FPUResult(4 downto 0) <= std_logic_vector(unsigned(FPUData1) / unsigned(FPUData2));
            end if;
            OUTPUT <= FPUOutput;
        end if;
    when "1011" =>
        --Check if one Parameter equal Zero
        if(FPUData1 = "00000") or(FPUData2 = "00000") then
            OUTPUT <= "0000";
        else
            --Multiplikation with Fixedpoint
            FPUMulResult(9 downto 0) <= std_logic_vector(unsigned(FPUData1) * unsigned(FPUData2));
            
            --Check overflow in both directions
            if((FPUMulResult(9 downto 8) > "00") or(FPUMulResult(2 downto 0) > "000")) then
                Overflow <= '1';
            end if;
            
            --Shift result with 3 to left
            FPUResult(4 downto 0) <=FPUMulResult(7 downto 3);
            OUTPUT <= FPUOutput;
        end if;
        
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
