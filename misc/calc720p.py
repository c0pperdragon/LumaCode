target=50
best=0
for w in range(500,600):
    for h in range(280,312):
        f = 8000000/(w*h)
        if abs(f-target)<abs(best-target):
            best=f
            print ("",w,"x",h," : ",8000000/(w*h),"Hz")

