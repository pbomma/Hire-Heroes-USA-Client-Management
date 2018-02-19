PROC IMPORT 
        DATAFILE= "C:\Users\VenksUV\Desktop\HHUSA-Project\Contact_new.csv"
OUT=contact dbms=csv  
      REPLACE;
    GETNAMES= YES;
    RUN;
/*contact_1 will only have the entries that satisfied the condition*/
data contact_1; set contact;
if(Date_Turned_Blue__c>0 & Date_Turned_green__c>0) then output;
data contact_2; set contact_1;
/*contact_2 will have the entries with calculations been done*/
/*To Calculate Days_To_Get_Hired*/
New_Date_Turned_green__c=datepart(Date_Turned_green__c);
put New_Date_Turned_green__c = date9.;
New_Date_Turned_Blue__c=datepart(Date_Turned_Blue__c);
put New_Date_Turned_Blue__c = date9.;
Days_To_Get_Hired=intck( 'day', New_Date_Turned_green__c,New_Date_Turned_Blue__c);

/*To Calculate Bus_Days_between_Assigned_and_Assessed__c*/
Assessment_Date = datepart(Dat_Initial_Assessment__c);
put Assessment_Date = date9.;
Assigned_Date = datepart(Date_assigned_to_staff__c);
put Assigned_Date = date9.;
Assessment_Time_inDAYS = intck('day',Assigned_Date,Assessment_Date);

/*To Calculate Bus_Days_between_Assessment_and_Resume__c*/
Resume_Date = datepart(Date_Resume_Completed__c);
put Resume_Date = date9.;
Resume_Time_inDAYS = intck('day',Assessment_Date, Resume_Date);

proc surveyselect data=contact_2 samprate= 0.59 seed=49201 out=contact_3 outall method=srs;
/*contact_3 will have TRAINING DATA SET*/
data contact_3; set contact_3;
if (selected =1) then output;run;


---------------------------------------------------------------------------------------------------------------
PROC IMPORT 
        DATAFILE= "C:\Users\VenksUV\Desktop\HHUSA-Project\Contact_Log.csv"
OUT=contact dbms=csv  
      REPLACE;
    GETNAMES= YES;
    RUN;
/*contact_1 will only have the entries that satisfied the condition*/
data contact_1; set contact;
if(Date_Turned_Blue__c>0 & Date_Turned_green__c>0) then output;
data contact_2; set contact_1;
/*contact_2 will have the entries with calculations been done*/
/*To Calculate Days_To_Get_Hired*/
New_Date_Turned_green__c=datepart(Date_Turned_green__c);
put New_Date_Turned_green__c = date9.;
New_Date_Turned_Blue__c=datepart(Date_Turned_Blue__c);
put New_Date_Turned_Blue__c = date9.;
Days_To_Get_Hired=intck( 'day', New_Date_Turned_green__c,New_Date_Turned_Blue__c);

/*To Calculate Bus_Days_between_Assigned_and_Assessed__c*/
Assessment_Date = datepart(Dat_Initial_Assessment__c);
put Assessment_Date = date9.;
Assigned_Date = datepart(Date_assigned_to_staff__c);
put Assigned_Date = date9.;
Assessment_Time_inDAYS = intck('day',Assigned_Date,Assessment_Date);

/*To Calculate Bus_Days_between_Assessment_and_Resume__c*/
Resume_Date = datepart(Date_Resume_Completed__c);
put Resume_Date = date9.;
Resume_Time_inDAYS = intck('day',Assessment_Date, Resume_Date);

proc surveyselect data=contact_2 samprate= 0.59 seed=49201 out=contact_3 outall method=srs;
/*contact_3 will have TRAINING DATA SET*/
data contact_3; set contact_3;
if (selected =1) then output;run;


log=0;
if(Attended_Day_1__c ^='' & Attended_Day_1__c ^='0') then log=log+1;
if(Attended_Day_2__c ^='' & Attended_Day_2__c ^='0') then log=log+1;
if(Compass_Participant__c ^='' & Compass_Participant__c ^='0') then log=log+1;
if(Career_Counseling__c ^='' & Career_Counseling__c ^='0') then log=log+1;
if(Date_Attended_HHUSA_Workshop__c ^='' & Date_Attended_HHUSA_Workshop__c ^='0') then log=log+1;
if(Career_Day_Participant__c ^='' & Career_Day_Participant__c ^='0') then log=log+1;
if(Created_LinkedIn_account__c ^='' & Created_LinkedIn_account__c ^='0') then log=log+1;
run;
proc sort data=contact_3 out=contact_3;
by Id;
run;

data contact_3;
   set contact_3;
   by Id;
   if First.Id then logged_act = 0;
   logged_act + log;
   if Last.Id;
run;

ods graphics on;
proc reg data=contact_3;
model  Days_To_Get_Hired = Resume_Time_inDAYS Assessment_Time_inDAYS logged_act ;
plot r.*p.;
run;
