import math

def conv(source, target):
    file1 = open(source,"rb")
    file1.read(54);
    data = file1.read(3*192*256)
    file1.close()
    
    file2 = open(target,'w')   
    for y in range(256):
        accu=0
        for x in range(192):
            bit = x % 4;
            i = 3*((191-x)+192*(255-y))
            l = math.floor( (data[i] + data[i+1] + data[i+2]) / (3*64))             
            accu = (accu<<2) | l
            if bit==3:
                print(accu,end="",file=file2)
                if y<255 or x<191:
                    print(",",end="",file=file2)
                accu=0
        print(file=file2)
    file2.close()    

conv("lumacode_logo.bmp", "example_270p/picture.h")
