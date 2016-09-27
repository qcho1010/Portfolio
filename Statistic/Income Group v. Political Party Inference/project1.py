# -*- coding: utf-8 -*-
"""
Created on Fri Oct 23 23:06:16 2015

@author: Kyu
"""
import pandas
import numpy

data = pandas.read_csv('data.csv', low_memory=False)
print(len(data))
print(len(data.columns))

# Make upper case for all
data.columns = map(str.lower, data.columns)

# Avoid runtime error
pandas.set_option('display.float_format', lambda x:'%f' %x)


# normalize=True = probability distribution
print ("For which candidate did R vote in Presidential primary or caucus")
c1 = data["prevote_primvwho"].value_counts(sort=False, dropna=False)
print(c1)
p1 = data["prevote_primvwho"].value_counts(sort=False, dropna=False, normalize=True) 
print(p1)

print ("U.S. economy better or worse than 1 year ago")
c2 = data["econ_ecpast_x"].value_counts(sort=False, dropna=False)
print(c2)
p2 = data["econ_ecpast_x"].value_counts(sort=False, dropna=False, normalize=True)
print(p2)

print ("U.S. economy better or worse 1 year from now")
c3 = data["econ_ecnext_x"].value_counts(sort=False, dropna=False)
print(c3)
p3 = data["econ_ecnext_x"].value_counts(sort=False, dropna=False, normalize=True)
print(p3)

print ("Unemployment better or worse than 1 year ago")
c4 = data["econ_unpast_x"].value_counts(sort=False, dropna=False)
print(c4)
p4 = data["econ_unpast_x"].value_counts(sort=False, dropna=False, normalize=True)
print(p4)

print ("How much is President to blame for poor econ conditions")
c4 = data["ecblame_pres"].value_counts(sort=False, dropna=False)
print(c4)
p4 = data["ecblame_pres"].value_counts(sort=False, dropna=False, normalize=True)
print(p4)

print ("How much former President to blame for poor econ conds")
c5 = data["ecblame_fmpr"].value_counts(sort=False, dropna=False)
print(c5)
p5 = data["ecblame_fmpr"].value_counts(sort=False, dropna=False, normalize=True)
print(p5)

print ("How much Dems in Congress to blame for poor econ conds")
c6 = data["ecblame_dem"].value_counts(sort=False, dropna=False)
print(c6)
p6 = data["ecblame_dem"].value_counts(sort=False, dropna=False, normalize=True)
print(p6)

print ("How much Reps in Congress to blame for poor econ conds")
c7 = data["ecblame_rep"].value_counts(sort=False, dropna=False)
print(c7)
p7 = data["ecblame_rep"].value_counts(sort=False, dropna=False, normalize=True)
print(p7)

print ("Family income")
c8 = data["incgroup_prepost"].value_counts(sort=False, dropna=False)
print(c8)
p8 = data["incgroup_prepost"].value_counts(sort=False, dropna=False, normalize=True)
print(p8)

# ----------------------------------------------------------------------------#
import pandas
import numpy

data = pandas.read_csv('data.csv', low_memory=False)
print(len(data))
print(len(data.columns))

# Make upper case for all
data.columns = map(str.lower, data.columns)

# Avoid runtime error
pandas.set_option('display.float_format', lambda x:'%f' %x)


def obamaORomney(row):
    if type(row) == float and numpy.isnan(row):
        return float('NaN')
    elif row == "02. Barack Obama":
        return 1
    elif row == "01. Mitt Romney":
        return 2
    else:
        return 3

s1 = data["prevote_primvwho"].apply(lambda row: obamaORomney(row))
s1 = pandas.DataFrame(s1)
print ("For which candidate did R vote in Presidential primary or caucus")
sc1 = s1["prevote_primvwho"].value_counts(sort=False, dropna=False)
print(sc1)
sp1 = s1["prevote_primvwho"].value_counts(sort=False, dropna=False, normalize=True) 
print(sp1)

# ----------------------------------------------------------------------------#

def betterORworse(row):
    if type(row) == float and numpy.isnan(row):
        return float('NaN')
    elif row == "Somewhat Better" or row == "Much Better":
        return 1
    elif row == "Somewhat Worse" or row == "Much Worse":
        return 2
    elif row == "Stayed About The Same" or row == "About The Same" or row == "Stay About The Same":
        return 3
        
s2 = data["econ_ecpast_x"].apply(lambda row: betterORworse(row))
s2 = pandas.DataFrame(s2)
print ("U.S. economy better or worse than 1 year ago")
sc2 = s2["econ_ecpast_x"].value_counts(sort=False, dropna=False)
print(sc2)
sp2 = s2["econ_ecpast_x"].value_counts(sort=False, dropna=False, normalize=True)
print(sp2)

s3 = data["econ_ecnext_x"].apply(lambda row: betterORworse(row))
s3 = pandas.DataFrame(s3)
print ("U.S. economy better or worse 1 year from now")
sc3 = s3["econ_ecnext_x"].value_counts(sort=False, dropna=False)
print(sc3)
sp3 = s3["econ_ecnext_x"].value_counts(sort=False, dropna=False, normalize=True)
print(sp3)

s4 = data["econ_unpast_x"].apply(lambda row: betterORworse(row))
s4 = pandas.DataFrame(s4)
print ("Unemployment better or worse than 1 year ago")
sc4 = s4["econ_unpast_x"].value_counts(sort=False, dropna=False)
print(sc4)
sp4 = s4["econ_unpast_x"].value_counts(sort=False, dropna=False, normalize=True)
print(sp4)


print ("Combined variables")
combined1 = sc2 + sc3 + sc4
print(combined1)
# ----------------------------------------------------------------------------#

def blameORnot(row):
    if type(row) == float and numpy.isnan(row):
        return float('NaN')
    elif row == "A Moderate Amount" or row == "A Great Deal" or row == "A Little" or row == "A Lot":
        return 1
    elif row == "Not At All":
        return 2

s5 = data["ecblame_pres"].apply(lambda row: blameORnot(row))
s5 = pandas.DataFrame(s5)
print ("How much is President to blame for poor econ conditions")
sc5 = s5["ecblame_pres"].value_counts(sort=False, dropna=False)
print(sc5)
sp5 = s5["ecblame_pres"].value_counts(sort=False, dropna=False, normalize=True)
print(sp5)

s6 = data["ecblame_fmpr"].apply(lambda row: blameORnot(row))
s6 = pandas.DataFrame(s6)
print ("How much former President to blame for poor econ conds")
sc6 = s6["ecblame_fmpr"].value_counts(sort=False, dropna=False)
print(sc6)
sp6 = s6["ecblame_fmpr"].value_counts(sort=False, dropna=False, normalize=True)
print(sp6)

s7 = data["ecblame_dem"].apply(lambda row: blameORnot(row))
s7 = pandas.DataFrame(s7)
print ("How much Dems in Congress to blame for poor econ conds")
sc7 = s7["ecblame_dem"].value_counts(sort=False, dropna=False)
print(sc7)
sp7 = s7["ecblame_dem"].value_counts(sort=False, dropna=False, normalize=True)
print(sp7)

s8 = data["ecblame_rep"].apply(lambda row: blameORnot(row))
s8 = pandas.DataFrame(s8)
print ("How much Reps in Congress to blame for poor econ conds")
sc8 = s8["ecblame_rep"].value_counts(sort=False, dropna=False)
print(sc8)
sp8 = s8["ecblame_rep"].value_counts(sort=False, dropna=False, normalize=True)
print(sp8)

print ("Combined variables")
combined2 = sc5 + sc6 + sc7 + sc8
print(combined2)

# ----------------------------------------------------------------------------#
def income(row):
    if type(row) == float and numpy.isnan(row):
        return float('NaN')
    elif row == "$15,000-$17,499" or row == "$10,000-$12,499" or row == "$5,000-$9,999" or row == "$17,500-$19,999" or row == "Under $5,000":
        return 10000
    elif row == "$27,500-$29,999" or row == "$25,000-$27,499" or row == "$20,000-$22,499" or row == "$22,500-$24,999":
        return 20000
    elif row == "$35,000-$39,999" or row == "$30,000-$34,999":
        return 30000
    elif row == "$45,000-$49,999" or row == "$40,000-$44,999":
        return 40000
    elif row == "$50,000-$54,999" or row == "$55,000-$59,999":
        return 50000
    elif row == "$60,000-$64,999" or row == "$65,000-$69,999":
        return 60000
    elif row == "$70,000-$74,999" or row == "$75,000-$79,999":
        return 70000
    elif row == "$80,000-$89,999":
        return 80000
    elif row == "$90,000-$99,999":
        return 90000
    elif row == "$100,000-$109,999":
        return 100000
    elif row == "$110,000-$124,999" or row == "$125,000-$149,999":
        return 110000
    elif row == "$150,000-$174,999" or row == "$175,000-$249,999":
        return 150000
    elif row == "$250,000 Or More":
        return 250000
        
s9 = data["incgroup_prepost"].apply(lambda row: income(row))
s9 = pandas.DataFrame(s9)
print ("Family income")
sc9 = s9["incgroup_prepost"].value_counts(sort=False, dropna=False)
print(sc9)
sp9 = s9["incgroup_prepost"].value_counts(sort=False, dropna=False, normalize=True)
print(sp9)

# quartile split (use qcut function & ask for 4 groups - gives you quartile split)
print ('Family income - 4 categories - quartiles')
s9['incgroup_prepostUP4'] = pandas.qcut(s9.incgroup_prepost, 4, labels=["1=0%tile","2=25%tile","3=50%tile","4=75%tile"])
qc10 = s9['incgroup_prepostUP4'].value_counts(sort=False, dropna=True)
print(qc10)

print ('percentages for incgroup_prepostUP4')
qc11 = s9['incgroup_prepostUP4'].value_counts(sort=False, normalize=True)
print (qc11)

# categorize quantitative variable based on customized splits using cut function
s9['incgroup_prepostUP3'] = pandas.cut(s9.incgroup_prepost, [10000, 40000, 80000, 250000])
qc12 = s9['incgroup_prepostUP3'].value_counts(sort=False, dropna=True)
print(qc12)

print ('percentages for incgroup_prepostUP3')
qc13 = s9['incgroup_prepostUP3'].value_counts(sort=False, normalize=True)
print (qc13)

# Crosstabs evaluating which incgroup_prepost were put into which incgroup_prepostUP3
print ('Crosstabs evaluating')
print (pandas.crosstab(s9['incgroup_prepostUP3'], s9['incgroup_prepost']))

# ----------------------------------------------------------------------------#
import numpy
import pandas
from scipy import stats, integrate
import matplotlib.pyplot as plt
import seaborn as sns

data = pandas.read_csv('data.csv', low_memory=False)

def obamaORomney2(row):
    if type(row) == float and numpy.isnan(row):
        return float('NaN')
    elif row == "02. Barack Obama":
        return 1
    elif row == "01. Mitt Romney":
        return 2
    else:
        return float('NaN')
        
s1 = data["prevote_primvwho"].apply(lambda row: obamaORomney2(row))
s1 = pandas.DataFrame(s1)

sns.set(color_codes=True)
s1["prevote_primvwho"] = s1["prevote_primvwho"].astype('category')
sns.countplot(x="prevote_primvwho", data=s1)
plt.xlabel('President')
plt.title("For which candidate did R vote in Presidential primary or caucus")


def betterORworse2(row):
    if type(row) == float and numpy.isnan(row):
        return float('NaN')
    elif row == "Somewhat Better" or row == "Much Better":
        return 1
    elif row == "Somewhat Worse" or row == "Much Worse":
        return -1
    elif row == "Stayed About The Same" or row == "About The Same" or row == "Stay About The Same":
        return 0
        
s2 = data["econ_ecpast_x"].apply(lambda row: betterORworse2(row))
s2 = pandas.DataFrame(s2)

s4 = data["econ_unpast_x"].apply(lambda row: betterORworse2(row))
s4 = pandas.DataFrame(s4)

# str into numeric
s2['econ_ecpast_x'] = s2['econ_ecpast_x'].convert_objects(convert_numeric=True)
s4['econ_unpast_x'] = s4['econ_unpast_x'].convert_objects(convert_numeric=True)

# combined numeric values from each columns
combined4 = s2['econ_ecpast_x'] + s4['econ_unpast_x']
combined4 = pandas.DataFrame(dict(econ_opnion = combined4))

# build final dataframe combined with two
result = pandas.concat([combined4, s1], axis=1)

# visualization
sns.barplot(x="prevote_primvwho", y="econ_opnion", data=result, ci=None);
plt.title('President vs Economic Experience')
plt.xlabel('President')
plt.ylabel('Previous Econ. Experience')


# ---------------------------------------------------------------------------#
def income2(row):
    if type(row) == float and numpy.isnan(row):
        return float('NaN')
    elif row == "$15,000-$17,499" or row == "$10,000-$12,499" or row == "$5,000-$9,999" or row == "$17,500-$19,999" or row == "Under $5,000":
        return 10
    elif row == "$27,500-$29,999" or row == "$25,000-$27,499" or row == "$20,000-$22,499" or row == "$22,500-$24,999":
        return 20
    elif row == "$35,000-$39,999" or row == "$30,000-$34,999":
        return 30
    elif row == "$45,000-$49,999" or row == "$40,000-$44,999":
        return 40
    elif row == "$50,000-$54,999" or row == "$55,000-$59,999":
        return 50
    elif row == "$60,000-$64,999" or row == "$65,000-$69,999":
        return 60
    elif row == "$70,000-$74,999" or row == "$75,000-$79,999":
        return 70
    elif row == "$80,000-$89,999":
        return 80
    elif row == "$90,000-$99,999":
        return 90
    elif row == "$100,000-$109,999":
        return 100
    elif row == "$110,000-$124,999" or row == "$125,000-$149,999":
        return 110
    elif row == "$150,000-$174,999" or row == "$175,000-$249,999":
        return 150
    elif row == "$250,000 Or More":
        return 250


s9 = data["incgroup_prepost"].apply(lambda row: income2(row))
s9 = pandas.DataFrame(s9)

# build final dataframe combined with two
result2 = pandas.concat([s9, combined4, s1], axis=1).dropna()
result2_sorted = result2.sort(columns="incgroup_prepost", ascending=True, inplace=False, kind='quicksort', na_position='last')

# visualization
sns.factorplot(x='incgroup_prepost', y='econ_opnion', data=result2_sorted, kind="bar", ci=None, size=7)
plt.title('Income Group vs Economic Experience')
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')


sns.barplot(x='incgroup_prepost', y='econ_opnion', hue="prevote_primvwho", data=result2_sorted, ci=None)
plt.title('Income Group vs Economic Experience')
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')

sns.lmplot(x="incgroup_prepost", y="econ_opnion", hue="prevote_primvwho", data=result2_sorted, size=6)
plt.title('Income Group vs Economic Experience')
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')


# ----------------------------------------------------------------------------#
import statsmodels.formula.api as smf
import statsmodels.stats.multicomp as multi 

# ANOVA explanatory variables with two levels
model1 = smf.ols(formula='econ_opnion ~ C(prevote_primvwho)', data=result2_sorted).fit()
print (model1.summary())
print ("")

print ('means for previous economy score by each candidate supporters')
m1= result2_sorted.groupby('prevote_primvwho').mean()
print (m1)
print ("")

print ('standard deviations for previous economy score by each candidate supporters')
sd1 = result2_sorted.groupby('prevote_primvwho').std()
print (sd1)


# ANOVA explanatory variables with more than two levels
model2 = smf.ols(formula='econ_opnion ~ C(incgroup_prepost)', data=result2_sorted).fit()
print (model2.summary())
print ("")

print ('means for previous economy by income group')
m2= result2_sorted.groupby('incgroup_prepost').mean()
print (m2)
print ("")

print ('standard deviations for previous economy by income group')
sd2 = result2_sorted.groupby('incgroup_prepost').std()
print (sd2)


# ANOVA Post hoc tests
mc1 = multi.MultiComparison(result2_sorted['econ_opnion'], result2_sorted['incgroup_prepost'])
res1 = mc1.tukeyhsd()
print(res1.summary())

# ----------------------------------------------------------------------------#
import pandas
import numpy
import scipy.stats
import seaborn
import matplotlib.pyplot as plt


# contingency table of observed counts
ct1 = pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['econ_opnion'])
print (ct1)

# column percentages
colsum = ct1.sum(axis=0)
colpct = ct1/colsum
print(colpct)

# chi-square
print ('chi-square value, p value, expected counts')
cs1= scipy.stats.chi2_contingency(ct1)
print (cs1)


# set variable types 
result2_sorted["econ_opnion"] = result2_sorted["econ_opnion"].astype('category')
# new code for setting variables to numeric:
result2_sorted['prevote_primvwho'] = pandas.to_numeric(result2_sorted['prevote_primvwho'], errors='coerce')


# graph percent with nicotine dependence within each smoking frequency group 
seaborn.factorplot(x="econ_opnion", y="prevote_primvwho", data=result2_sorted, kind="bar", ci=None)
plt.xlabel('Prev. Econ. Exp. Score')
plt.ylabel('Proportion Candidate Supporters')

# ----------------------------------------------------------------------------#
recode2 = {-2: -2, -1: -1}
result2_sorted['COMP-2v-1']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP-2v-1'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {-2: -2, 0: 0}
result2_sorted['COMP-2v0']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP-2v0'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {-2: -2, 1: 1}
result2_sorted['COMP-2v-1']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP-2v-1'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {-2: -2, 2: 2}
result2_sorted['COMP-2v-2']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP-2v-2'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {-1: -1, 0: 0}
result2_sorted['COMP-1v0']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP-1v0'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {-1: -1, 1: 1}
result2_sorted['COMP-1v1']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP-1v1'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {-1: -1, 2: 2}
result2_sorted['COMP-1v2']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP-1v2'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {0: 0, 1: 1}
result2_sorted['COMP0v1']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP0v1'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {0: 0, 2: 2}
result2_sorted['COMP0v2']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP0v2'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)
# -------------------------------#
recode2 = {1: 1, 2: 2}
result2_sorted['COMP1v2']= result2_sorted['econ_opnion'].map(recode2)

# contingency table of observed counts
ct2=pandas.crosstab(result2_sorted['prevote_primvwho'], result2_sorted['COMP1v2'])
print (ct2)

# column percentages
colsum=ct2.sum(axis=0)
colpct=ct2/colsum
print(colpct)

print ('chi-square value, p value, expected counts')
cs2= scipy.stats.chi2_contingency(ct2)
print (cs2)

# ----------------------------------------------------------------------------#
import scipy
import matplotlib.pyplot as plt
import seaborn as sns


sns.regplot(x="incgroup_prepost", y="econ_opnion", fit_reg=True, data=result2_sorted)
plt.title('Income Group vs Economic Experience')
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')

print ('[Without Moderator] Association between Income Group vs Economic Experience')
print (scipy.stats.pearsonr(result2_sorted['incgroup_prepost'], result2_sorted['econ_opnion']))
print ("")


## Subs
Sub1_Obama = result2_sorted[(result2_sorted['prevote_primvwho'] == 1)] 
Sub2_Rommey = result2_sorted[(result2_sorted['prevote_primvwho'] == 2)] 

sns.regplot(x="incgroup_prepost", y="econ_opnion", fit_reg=True, data=Sub1_Obama)

plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')

print ('[With Moderator Obama value] Association between Income Group vs Economic Experience')
print (scipy.stats.pearsonr(Sub1_Obama['incgroup_prepost'], Sub1_Obama['econ_opnion']))
print ("")


sns.regplot(x="incgroup_prepost", y="econ_opnion", fit_reg=True, data=Sub2_Rommey)
plt.title('Income Group vs Economic Experience')
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')

print ('[With Moderator Rommey value] Association between Income Group vs Economic Experience')
print (scipy.stats.pearsonr(Sub2_Rommey['incgroup_prepost'], Sub2_Rommey['econ_opnion']))


# ----------------------------------------------------------------------------#
import numpy as numpyp
import pandas as pandas
import statsmodels.api
import statsmodels.formula.api as smf
import statsmodels.api as sm
# bug fix for display formats to avoid run time errors
pandas.set_option('display.float_format', lambda x:'%.2f'%x)

# convert variables to numeric format using convert_objects function
result2_sorted['incgroup_prepost'] = pandas.to_numeric(result2_sorted['incgroup_prepost'], errors='coerce')
result2_sorted['econ_opnion'] = pandas.to_numeric(result2_sorted['econ_opnion'], errors='coerce')

###############################################################################
# BASIC LINEAR REGRESSION
###############################################################################
scat1 = seaborn.regplot(x="incgroup_prepost", y="econ_opnion", scatter=True, data=result2_sorted)
plt.title('Income Group vs Economic Experience')
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')
print(scat1)

print ("OLS regression model for the association between Income Group and Previous Econ. Experience")
reg1 = smf.ols('econ_opnion ~ incgroup_prepost', data=result2_sorted).fit()
print (reg1.summary())


###############################################################################
# POLYNOMIAL REGRESSION
###############################################################################

# first order (linear) scatterplot
scat1 = seaborn.regplot(x="incgroup_prepost", y="econ_opnion", scatter=True, data=result2_sorted)
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')

# fit second order polynomial
# run the 2 scatterplots together to get both linear and second order fit lines
scat1 = seaborn.regplot(x="incgroup_prepost", y="econ_opnion", scatter=True, order=2, data=result2_sorted)
plt.xlabel('Income (10=10000)')
plt.ylabel('Previous Econ. Experience')

# center quantitative IVs for regression analysis
result2_sorted['incgroup_prepost_c'] = (result2_sorted['incgroup_prepost'] - result2_sorted['incgroup_prepost'].mean())
result2_sorted['econ_opnion_c'] = (result2_sorted['econ_opnion'] - result2_sorted['econ_opnion'].mean())
result2_sorted[["incgroup_prepost_c", "econ_opnion_c"]].describe()

# linear regression analysis
reg1 = smf.ols('econ_opnion_c ~ incgroup_prepost_c', data=result2_sorted).fit()
print (reg1.summary())

# quadratic (polynomial) regression analysis

# run following line of code if you get PatsyError 'ImaginaryUnit' object is not callable
reg2 = smf.ols('econ_opnion_c ~ incgroup_prepost_c + I(incgroup_prepost_c**2)', data=result2_sorted).fit()
print (reg2.summary())

####################################################################################
# EVALUATING MODEL FIT
####################################################################################

#Q-Q plot for normality
fig4=sm.qqplot(reg2.resid, line='r')

# simple plot of residuals
stdres=pandas.DataFrame(reg2.resid_pearson)
plt.plot(stdres, 'o', ls='None')
l = plt.axhline(y=0, color='r')
plt.ylabel('Standardized Residual')
plt.xlabel('Observation Number')


# leverage plot
fig3=sm.graphics.influence_plot(reg2, size=8)
print(fig3)


##############################################################################
# LOGISTIC REGRESSION
##############################################################################

# binary nicotine dependence
def obamaORomney3(x):
   if x == 1:
      return 1
   else: 
      return 0
result2_sorted['prevote_primvwho'] = result2_sorted["prevote_primvwho"].apply (lambda x: obamaORomney3 (x))

# logistic regression with social phobia
lreg1 = smf.logit(formula = 'prevote_primvwho ~ econ_opnion_c + incgroup_prepost_c', data = result2_sorted).fit()
print (lreg1.summary())
# odds ratios
print ("Odds Ratios")
print (numpy.exp(lreg1.params))

# odd ratios with 95% confidence intervals
params = lreg1.params
conf = lreg1.conf_int()
conf['OR'] = params
conf.columns = ['Lower CI', 'Upper CI', 'OR']
print (numpy.exp(conf))
# ----------------------------------------------------------------------------#
# Decision Tree

from pandas import Series, DataFrame
import pandas as pd
import numpy as np
import os
import matplotlib.pylab as plt
from sklearn.cross_validation import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import classification_report
import sklearn.metrics

data = pandas.read_csv('data.csv', low_memory=False)

data.describe()
data.head()
data.shape[0]
data.dtypes

data_clean = data.dropna()
data_clean.shape[0]

data["gender_respondent"].head()


data.gender_respondent.value_counts()
data.incgroup_prepost.value_counts()
data.sample_state.value_counts()
data.interest_attention.value_counts()
data.interest_following.value_counts()
data.gender_respondent.value_counts()































