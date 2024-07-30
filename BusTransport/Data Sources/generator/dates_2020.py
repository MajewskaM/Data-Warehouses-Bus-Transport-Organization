# generating dates for 1st timestamp 
x = []
for i in range(1, 10):
    dateApril1 = ("2020-" + "04-0" + str(i))
    x.append(dateApril1)

for i in range(10, 31):
    dateApril2 = ("2020-" + "04-" + str(i))
    x.append(dateApril2)

for i in range(1, 10):
    dateMay1 = ("2020-" + "05-0" + str(i))
    x.append(dateMay1)

for i in range(10, 32):
    dateMay2 = ("2020-" + "05-" + str(i))
    x.append(dateMay2)

for i in range(1, 10):
    dateJune1 = ("2020-" + "06-0" + str(i))
    x.append(dateJune1)

for i in range(10, 31):
    dateJune2 = ("2020-" + "06-" + str(i))
    x.append(dateJune2)
    
for i in range(1, 10):
    dateJuly1 = ("2020-" + "07-0" + str(i))
    x.append(dateJuly1)

for i in range(10, 32):
    dateJuly2 = ("2020-" + "07-" + str(i))
    x.append(dateJuly2)

for i in range(1, 10):
    dateAugust1 = ("2020-" + "08-0" + str(i))
    x.append(dateAugust1)

for i in range(10, 32):
    dateAugust2 = ("2020-" + "08-" + str(i))
    x.append(dateAugust2)
    
for i in range(1, 10):
    dateSeptember1 = ("2020-" + "09-0" + str(i))
    x.append(dateSeptember1)

for i in range(10, 31):
    dateSeptember2 = ("2020-" + "09-" + str(i))
    x.append(dateSeptember2)
    
for i in range(1, 10):
    dateOctober1 = ("2020-" + "10-0" + str(i))
    x.append(dateOctober1)

for i in range(10, 32):
    dateOctober2 = ("2020-" + "10-" + str(i))
    x.append(dateOctober2)
    
for i in range(1, 10):
    dateNovember1 = ("2020-" + "11-0" + str(i))
    x.append(dateNovember1)

for i in range(10, 31):
    dateNovember2 = ("2020-" + "11-" + str(i))
    x.append(dateNovember2)   
    
for i in range(1, 10):
    dateDecember1 = ("2020-" + "12-0" + str(i))
    x.append(dateDecember1)

for i in range(10, 32):
    dateDecember2 = ("2020-" + "12-" + str(i))
    x.append(dateDecember2)        
y = ('\n'.join(x))


