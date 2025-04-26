package Frequencies is   

	type t_Frequency is (
	    MHZ_7_080,       -- G7000 2x pixel clock = 7.080000
	    MHZ_7_159,       -- NTSC Intellivion 2x pixel clock = 7.159088
	    MHZ_8_000,       -- PAL Intellivion 2x pixel clock = 8.000000
		MHZ_8_181,       -- NTSC VIC 20 2x pixel clock = 8.181817
		MHZ_8_867,       -- PAL VIC 20 2x pixel clock = 8.867236
		MHZ_10_738,      -- PAL/NTSC TMS99xxA 2x pixel clock = 10.738635
		MHZ_14_000,      -- PAL ZX Spectrum 2x pixel clock = 14.000000
		MHZ_14_110,      -- NTSC ZX Spectrum 2x pixel clock = 14.110000
		MHZ_14_187,      -- PAL Atari 2600 4x pixel clock = 14.18758
		MHZ_14_318,      -- NTSC Atari 2600 4x pixel clock = 14.31818				
		MHZ_15_763,      -- PAL C64/C128 2x pixel clock = 15.763968
		MHZ_15_961,      -- PAL Master System 3x pixel = 15.961023
		MHZ_16_000,      -- C128 VDC
		MHZ_16_108,      -- NTSC Master System 3x pixel = 16.1079525
		MHZ_16_363,      -- NTSC C64 2x pixel clock = 16.363632		
		MHZ_21_281,      -- PAL Atari 8-bit 6x pixel clock = 21.28137
		MHZ_21_477,      -- NTSC Atari 8-bit 6x pixel clock = 21.47727
		MHZ_24_000,      -- Lumacode270p
		MHZ_31_922,      -- PAL NES 6x pixel clock = 31.9220544 
		MHZ_32_000,      -- Atari ST highres pixel clock
		MHZ_32_216       -- NTSC NES 6x pixel clock = 32.215908		
	);

end Frequencies;
