# generating dates for 2nd timestamp 
x = []
for i in range(1, 10):
    dateJanuary1 = ("2021-" + "01-0" + str(i))
    x.append(dateJanuary1)

for i in range(10, 32):
    dateJanuary2 = ("2021-" + "01-" + str(i))
    x.append(dateJanuary2)

for i in range(1, 10):
    dateFebruary1 = ("2021-" + "02-0" + str(i))
    x.append(dateFebruary1)

for i in range(10, 29):
    dateFebruary2 = ("2021-" + "02-" + str(i))
    x.append(dateFebruary2)

for i in range(1, 10):
    dateMarch = ("2021-" + "03-0" + str(i))
    x.append(dateMarch)

for i in range(10, 32):
    dateMarch = ("2021-" + "03-" + str(i))
    x.append(dateMarch)

for i in range(1, 10):
    dateApril1 = ("2021-" + "04-0" + str(i))
    x.append(dateApril1)

for i in range(10, 31):
    dateApril2 = ("2021-" + "04-" + str(i))
    x.append(dateApril2)

for i in range(1, 10):
    dateMay1 = ("2021-" + "05-0" + str(i))
    x.append(dateMay1)

for i in range(10, 32):
    dateMay2 = ("2021-" + "05-" + str(i))
    x.append(dateMay2)

for i in range(1, 10):
    dateJune1 = ("2021-" + "06-0" + str(i))
    x.append(dateJune1)

for i in range(10, 31):
    dateJune2 = ("2021-" + "06-" + str(i))
    x.append(dateJune2)

for i in range(1, 10):
    dateJuly1 = ("2021-" + "07-0" + str(i))
    x.append(dateJuly1)

for i in range(10, 32):
    dateJuly2 = ("2021-" + "07-" + str(i))
    x.append(dateJuly2)

for i in range(1, 10):
    dateAugust1 = ("2021-" + "08-0" + str(i))
    x.append(dateAugust1)

for i in range(10, 32):
    dateAugust2 = ("2021-" + "08-" + str(i))
    x.append(dateAugust2)

y = ('\n'.join(x))

