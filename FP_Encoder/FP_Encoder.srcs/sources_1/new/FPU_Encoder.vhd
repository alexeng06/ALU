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
    DATA:in std_logic_vector(4 downto 0);
    OutputData:out std_logic_vector(3 downto 0);
    OVF:out std_logic
);
end FPU_Encoder;

architecture Behavioral of FPU_Encoder is
begin
    process(DATA) is
    begin
        OVF <= '0';
        if (DATA >= "10000") then
            OutputData(3 downto 2) <= DATA(4 downto 3);
            OutputData(1 downto 0) <= "01";
            if (DATA(2 downto 0) > "000") then
                OVF <= '1';
            end if;
        elsif(DATA >= "01000") then
            OutputData(3 downto 2) <= DATA(3 downto 2);
            OutputData(1 downto 0) <= "00";
            if (DATA(1 downto 0) > "00") then
                OVF <= '1';
            end if;
        elsif(DATA >= "00100") then
            OutputData(3 downto 2) <= DATA(2 downto 1);
            OutputData(1 downto 0) <= "11";
            if (DATA(0) > '0') then
                OVF <= '1';
            end if;
        elsif(DATA >= "00001") then
            OutputData(3 downto 2) <= DATA(1 downto 0);
            OutputData(1 downto 0) <= "10";
        else
            OutputData <= "0000";
        end if;
    end process;
end Behavioral;
