-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    audioCodecController
--
-- description:
--
--  This unit is controller for the Wolfson WM8731 audio codec.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2022 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2022 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------

-- Controller for the Wolfson audio codec
-- Uses I2C to initialize and send data to the codec
-- Data is stored in a 24x10 bit ROM component.

library ieee;
use ieee.std_logic_1164.all;

entity audioCodecController is
  port(
    clock50MHz_i        : in  std_logic;
    reset_i             : in  std_logic;
    I2C_SCLK_Internal_o : out std_logic;
    I2C_SDAT_Internal_o : out std_logic;
    SDAT_Control_o      : out std_logic;
    -- for testing
    clock50KHz_o        : out std_logic
  );
end audioCodecController;

architecture arch of audioCodecController is
  -- 50kHz SCLK
  component clock50KHz is
    port(
      clock_i      : in  std_logic;
      reset_i      : in  std_logic;
      clock50KHz_o : out std_logic
    );
  end component;
  -- counts the number of data bits sent
  component dataBitCounter is
    port(
      -- active high count enable
      countEnable_i      : in  std_logic;
      -- active high reset
      reset_i            : in  std_logic;
      clock_i            : in  std_logic;
      currentBitCount_o  : out integer;
      currentWordCount_o : out integer
    );
  end component;
  -- ROM storing codec initialization data
  -- 10 words, 24 bits each
  component ROMcontroller is
    port(
      -- asynch active-high reset
      reset_i      : in  std_logic;
      increment_i  : in  std_logic;
      clock50KHz_i : in  std_logic;
      clock50MHz_i : in  std_logic;
      ROMword_o    : out std_logic_vector(23 downto 0)
    );
  end component;

  -- 50KHz clock used for SCLK
  signal clock50KHz_Internal : std_logic;
  -- internal signals
  signal SDAT_Temp,SCLK_Temp : std_logic;
  -- starts/stops the data bit counter
  signal bitCountEnable      : std_logic;
  -- start incrementing the ROM each clock cycle
  signal incrementROM        : std_logic;
  -- the 24 bits of data to be sent
  signal ROM_data_vector_24  : std_logic_vector(23 downto 0);
  -- track bit in current set of data (0 -> 23)
  signal currentDataBit      : integer;
  -- trach current 24-bit word in ROM
  signal currentDataWord     : integer;

  -- each state places one bit on the SDAT wire
  type t_I2CState is (resetState, startCondition, sendData, acknowledge, prepForStop, stopCondition);
  signal I2C_state           : t_I2CState;
begin

  clock50KHzInstance : clock50KHz port map(clock50MHz_i, reset_i, clock50KHz_Internal);

  dataBitCounterInstance : dataBitCounter port map(bitCountEnable, reset_i, clock50KHz_Internal, currentDataBit, currentDataWord);

  ROMcontrollerInstance : ROMcontroller port map(reset_i     => reset_i,
                                                increment_i  => incrementROM,
                                                clock50KHz_i => clock50KHz_Internal,
                                                clock50MHz_i => clock50MHz_i,
                                                ROMword_o    => ROM_data_vector_24);

  -- FSM that sends start condition, address, write bit = 0,
  -- then waits for ack from the codec
  i2c : process(clock50KHz_Internal,reset_i)
  begin
    -- asynchronous active-high reset
    if reset_i = '0' then
      if rising_edge(clock50KHz_Internal) then
        case I2C_state is
          when resetState =>
            -- place both wires high to prepare for the start condition
            SDAT_Temp <= '1';
            SCLK_Temp <= '1';
            I2C_state <= startCondition;
            incrementROM <= '0';
          when startCondition =>
            -- pull the SDAT line low -> the start condition
            SDAT_Temp <= '0';
            I2C_state <= sendData;
            -- start counting data bits on the next clock cycle
            bitCountEnable <= '1';
          when sendData =>
            -- release the clock
            SCLK_Temp <= '0';
            SDAT_Control_o <= '1';
            -- send the next data bit
            SDAT_Temp <= ROM_data_vector_24(currentDataBit);
            -- is it time for the ack bit?
            if (currentDataBit = 16) or (currentDataBit = 8) or (currentDataBit = 0) then
              I2C_state <= acknowledge;
              bitCountEnable <= '0';
            else
              I2C_state <= sendData;
            end if;
          when acknowledge =>
            -- To allow the codec to pull SDAT low, SDAT must be set to Z
            SDAT_Control_o <= '0';
            -- if all 24 bits sent, end the transmission
            if currentDataBit = 23 then
              I2C_state <= prepForStop;
            else
              I2C_state <= sendData;
              bitCountEnable <= '1';
            end if;
          when prepForStop =>
            -- take control of SDAT line again
            SDAT_Control_o <= '1';
            -- pull SCLK high, and set SDAT low to prep for stop condition
            SCLK_Temp <= '1';
            SDAT_Temp <= '0';
            I2C_state <= stopCondition;
          when stopCondition =>
            -- keep SCLK high, and pull SDAT high as stop condition
            SDAT_TEMP <= '1';
            -- more data words to send?
            if currentDataWord < 10 then
              incrementROM <= '1';
              I2C_state <= resetState;
            else
              incrementROM <= '0';
            end if;
        end case;
      end if;
    else
      SDAT_Temp <= '1';
      SCLK_Temp <= '1';
      SDAT_Control_o <= '1';
      bitCountEnable <= '0';
      incrementROM <= '0';
      I2C_state <= resetState;
    end if;
  end process i2c;
  I2C_SDAT_Internal_o <= SDAT_Temp;
  -- use the 50KHz clock to drive the state machine, and the (not 50KHz) clock to drive the
  -- codec. The Half-period delay allows the SDAT data to stabilize on the line before
  -- being read by the codec
  I2C_SCLK_Internal_o <= SCLK_Temp or (not clock50KHz_Internal);

  -- for testing purposes
  clock50KHz_o <= clock50KHz_Internal;
end arch;
