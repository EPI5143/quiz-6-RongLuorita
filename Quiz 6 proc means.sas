libname epi "C:\Users\SEPHPM\Desktop\EPI5143";
libname ex "C:\Users\SEPHPM\Desktop\EPI5143\exercise\data";

data ex.encounter;
set epi.nencounter;
run;

proc contents data=ex.encounter varnum;
run;

data encounter2013;
set ex.encounter;
where year(datepart(encStartDtm))=2003;
run;

*examine no duplicate encounters;
proc sort data=encounter2013 nodupkey;
by EncWID;
run;

*sort by patient ID;
proc sort data=encounter2013 out=encounter;
by encPatWID;
run;


*Q1: at least 1 inpatient encounter in 2003;
data encounteri;
set encounter;
inpt=0;*create a new variable for inpatient encounters;
if EncVisitTypeCd="INPT" then inpt=1;*flag for inpt if patient has inpatient encounter;
run;

proc means data=encounteri noprint;
class encPatWID;
types encPatWID;
output out=inptflat n(inpt)=count sum(inpt)=inpt_count max(inpt)=inpt;
run;

proc freq data=inptflat;
tables inpt count inpt_count;
run;

***Results: Out of 2891, 1074 (37.15%) patients had at least 1 inpatinet encounter that started in 2003;


*Q2: at least 1 emergency room encounter in 2003;
data encountere;
set encounter;
emerg=0;*create a new variable for emergency room encounters; 
if EncVisitTypeCd="EMERG" then emerg=1;*flag for emerge if patient has 1 emergency encounter;
run;

proc means data=encountere noprint;
class encPatWID;
types encPatWID;
output out=emergflat n(emerg)=count sum(emerg)=emerg_count max(emerg)=emerg;
run;

proc freq data=emergflat;
tables emerg count emerg_count;
run;

***Results:Out of 2891, 1978(68.42%) patients had at least 1 emergenecy room encounter in 2003;


*Q3:at least 1 visit of either type (inpatient or emergency room encounter) that 
started in 2003;
proc transpose data=encounter out=encountert;
by encPatWID;
var EncVisitTypeCd;
run;
proc contents data=encountert;
run;

***Results: 2891 patients had at least 1 visit of either type (inpatient or emergency room encounter) that started in 2003;


*Q4:in patients from c) who had at least 1 visit of either type,
create a variable that counts the total number encounters (of either type);
ods listing;
options formchar="|----|+|---+=|-/\<>*";

data final;
merge inptflat(in=a) emergflat(in=b);
by encPatWID;
if a and b;
totalencounter=inpt_count+emerg_count;*create a variable counting for the total number encounters (of either type) per patient;
run;

proc freq data=final;
tables totalencounter inpt_count emerg_count;
run;

*Results:
The frequency table of total encounter numbers (of either type) was presented as below.
                                       The FREQ Procedure

                                                         Cumulative    Cumulative
              totalencounter    Frequency     Percent     Frequency      Percent
              -------------------------------------------------------------------
                           1        2556       88.41          2556        88.41
                           2         270        9.34          2826        97.75
                           3          45        1.56          2871        99.31
                           4          14        0.48          2885        99.79
                           5           3        0.10          2888        99.90
                           6           1        0.03          2889        99.93
                           7           1        0.03          2890        99.97
                          12           1        0.03          2891       100.00




******Alternative options for flatten file by approaches of first. and last.; 
libname epi "C:\Users\SEPHPM\Desktop\EPI5143";
libname ex "C:\Users\SEPHPM\Desktop\EPI5143\exercise\data";

data ex.encounter;
set epi.nencounter;
run;

proc contents data=ex.encounter varnum;
run;

*dataset of encounters in 2013;
data encounter2013;
set ex.encounter;
where year(datepart(encStartDtm))=2003;
run;

*examine no duplicate encounters;
proc sort data=encounter2013 nodupkey;
by EncWID;
run;

*sort by patient ID;
proc sort data=encounter2013 out=encounter;
by encPatWID;
run;

*Flat file by per patient ID;
ods listing;
options formchar="|----|+|---+=|-/\<>*";

data encflat;
set encounter;
by encPatWID;
retain emerg inpt counte counti count;
if first.encPatWID then do;
counte=0;
counti=0;
countotal=0;
emerg=0;
inpt=0;
end;
if EncVisitTypeCd="EMERG" then do;
emerg=1;
counte=counte+1;*set flag for emerg;
end;
if EncVisitTypeCd="INPT" then do;
inpt=1;
counti=counti+1;*set flag for inpt;
end;
countotal=counte+counti;
if last.encPatWID then do;
keep encwid encPatWID emerg inpt counte counti countotal;
output;
end;
run;

proc freq data=encflat;
tables inpt emerg counte counti countotal;
run;

***Results:
**Q1:
                                     The FREQ Procedure

                                                    Cumulative    Cumulative
                   inpt    Frequency     Percent     Frequency      Percent
                   ---------------------------------------------------------
                      0        1817       62.85          1817        62.85
                      1        1074       37.15          2891       100.00

Out of 2891, 1074 (37.15%)Out of 2891, 1074 (37.15%) patients had at least 1 inpatient encounter that started in 2003;


**Q2:
                                    Cumulative    Cumulative
                   emerg    Frequency     Percent     Frequency      Percent
                   ----------------------------------------------------------
                       0         913       31.58           913        31.58
                       1        1978       68.42          2891       100.00

Out of 2891, 1978(68.42%) patients had at least 1 emergency room encounter in 2003;


**Q3 and Q4:
                                       Cumulative    Cumulative
                 countotal    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                         1        2556       88.41          2556        88.41
                         2         270        9.34          2826        97.75
                         3          45        1.56          2871        99.31
                         4          14        0.48          2885        99.79
                         5           3        0.10          2888        99.90
                         6           1        0.03          2889        99.93
                         7           1        0.03          2890        99.97
                        12           1        0.03          2891       100.00



There are 2891 patients had at least 1 visit of either type(inpatient or emergency room encounter) in 2003. The frequency table of total number of encounters (of either type) presented as above.















