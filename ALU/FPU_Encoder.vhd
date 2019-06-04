----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.06.2019 16:24:19
-- Design Name: 
-- Module Name: FPU_Encoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FPU_Encoder is
port(
    --Input Data 5 Bit Fixed Point
    DATA:in std_logic_vector(5 downto 0);
    --Output Data 4 Bit Floating Point
    OutputData:out std_logic_vector(3 downto 0);
    --Flag if Data is cutted
    OVF:out std_logic
);
end FPU_Encoder;

architecture Behavioral of FPU_Encoder is
begin
    process(DATA) is
    begin
        --Reset Flag
        OVF <= '0';
        --Check for Exponent and the MSB and MSB-1
        if (DATA >= "100000") then
            OutputData(3 downto 2) <= DATA(4 downto 3);
            OutputData(1 downto 0) <= "01";
            --If Data Cutted rise Flag
            if (DATA(2 downto 0) > "000") then
                OVF <= '1';
            end if;
        elsif(DATA >= "010000") then
            OutputData(3 downto 2) <= DATA(3 downto 2);
            OutputData(1 downto 0) <= "00";
            --If Data Cutted rise Flag
            if (DATA(1 downto 0) > "00") then
                OVF <= '1';
            end if;
        elsif(DATA >= "001000") then
            OutputData(3 downto 2) <= DATA(2 downto 1);
            OutputData(1 downto 0) <= "11";
            --If Data Cutted rise Flag
            if (DATA(0) > '0') then
                OVF <= '1';
            end if;
        elsif(DATA >= "000100") then
            OutputData(3 downto 2) <= DATA(1 downto 0);
            OutputData(1 downto 0) <= "10";
            --If Data Cutted rise Flag
        --Else give Zero
        else
            OutputData <= "0000";
        end if;
    end process;
end Behavioral;
