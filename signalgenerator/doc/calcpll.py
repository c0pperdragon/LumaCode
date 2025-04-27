def calc(target):
    bestf = 0
    bestvco = 0
    vestdivider = 0
    for multiplier in range(50,100,1):
        vco = 8*multiplier;
        for divider in range(15,100,1):
            f = vco/divider
            if abs(f-target) < abs(bestf-target):
                bestf = f
                bestvco = vco
                bestdivider = divider
    print ("best for ",target,": ",bestvco/8,":",bestdivider,"=", bestvco/bestdivider);

calc(7.080000)
calc(7.159088)
calc(8.000000)
calc(8.181817)
calc(8.867236)
calc(10.738635)
calc(14.000000)
calc(14.11000)
calc(14.18758)
calc(14.31818)
calc(15.763968)
calc(15.961023)
calc(16.00000)
calc(16.1079525)
calc(16.363632)
calc(21.28137)
calc(21.47727)
calc(24.0000)
calc(28.63636)
calc(31.9220544)
calc(32.215908)
