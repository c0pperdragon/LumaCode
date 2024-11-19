def calc(target):
    bestf = 0
    bestvco = 0
    bestd1 = 0
    bestdivider = 0    
    for d1 in range(24,65,1):
        vco = 12.5*d1
        for divider in range(1,129,1):
            f = vco/divider
            if abs(f-target) < abs(bestf-target):
                bestf = f
                bestvco = vco
                bestd1 = d1
                bestdivider = divider
    print ("best for ",target,": ",bestvco,"(",bestd1,") ","/",bestdivider,"=", bestvco/bestdivider);
calc(71.5909)   # Atari 8-bit/2600 NTSC
calc(88.67236)  # VIC20 PAL
calc(28.63636)  # 8xNTSC subcarrier (clock generator for VIC 20 PAL)
calc(106.40685) # NES 4xPAL master clock
calc(28.636352) # 2 times C16 master clock NTSC
calc(57.272724) # 4 times EGA clock
