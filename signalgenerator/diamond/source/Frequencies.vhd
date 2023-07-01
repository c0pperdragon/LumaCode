package Frequencies is   

	type t_Frequency is (
		MHZ_15_763,      -- C64 PAL 2x pixel clock = 15.763968
		MHZ_16_363,      -- C64 NTSC 2x pixel clock = 16.363632		
		MHZ_21_281,      -- Atari 8-bit PAL 6x pixel clock = 21.28137
		MHZ_21_477,      -- Atari 8-bit NTSC 6x pixel clock = 21.47727
		MHZ_8_867,       -- VIC 20 PAL 2x pixel clock = 8.867236
		MHZ_8_181,       -- VIC 20 NTSC 2x pixel clock = 8.181817
		MHZ_14_187,      -- Atari 2600 PAL 4x pixel clock = 14.18758
		MHZ_14_318       -- Atari 2600 NTSC 4x pixel clock = 14.31818
	);

end Frequencies;
