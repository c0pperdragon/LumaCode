def calc(target):
    bestf = 0
    bestvco = 0
    vestdivider = 0
    for vco in range(400,800,10):
        for divider in range(15,100,1):
            f = vco/divider
            if abs(f-target) < abs(bestf-target):
                bestf = f
                bestvco = vco
                bestdivider = divider
    print ("best for ",target,": ",bestvco,"/",bestdivider,"=", bestvco/bestdivider);
calc(15.763968)
calc(16.363632)
calc(21.28137)
calc(21.47727)
calc(8.867236)
calc(8.181817)
calc(14.18758)
calc(14.31818)
