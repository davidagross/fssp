# we'll practice by doing simple cellular automata first

A = []
numCell = 5
A.append([0, 0, 1, 0, 0])
n = 10

for iTime in range(0,n):
    nextGen = [];
    for iCell in range(0,numCell):
        nextGen.insert(iCell,iCell*iTime)
    A.append(nextGen)
        
print A,