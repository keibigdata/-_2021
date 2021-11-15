%LET dir=C:\Users\user\Desktop\2021_KEI\SAS_code_dataset;
LIBNAME C "&dir";

/* 국가 자료 */
PROC IMPORT DATAFILE="&dir\NGGIR_Local.xlsx" DBMS=xlsx OUT=NATION REPLACE;
	SHEET="Nation" ;
	GETNAMES=YES;
RUN;

/* 오염물질원별 국가 자료*/
PROC IMPORT DATAFILE="&dir\NGGIR_Nation(pollutant).xlsx" DBMS=xlsx OUT=NATION_pollutant REPLACE;	
	GETNAMES=YES;
RUN;


/*--------분석---------*/;
/*------ 국가 분석------*/;
/*- 온실가스 배출량 분석-*/;

ods graphics / attrpriority=none;

PROC SGPLOT DATA=Nation;
	TITLE " 대한민국 온실가스 배출량 추세";
	LABEL CVAR1="총배출량" CVAR2="순배출량";
	SERIES X=YEAR Y=CVAR1 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2) ;
	SERIES X=YEAR Y=CVAR2 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE " 분야별 온실가스 배출량 추세";
	LABEL EVAR1="에너지" IVAR1="산업공정" AVAR1="농업" LVAR1="LULUCF" WVAR1="폐기물" SVAR1="간접배출량" ;
	SERIES X=YEAR Y=EVAR1 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2 ) ;
	SERIES X=YEAR Y=IVAR1 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=AVAR1 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=LVAR1 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=WVAR1 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=2 PATTERN=LONGDASH);
	SERIES X=YEAR Y=SVAR1 /SMOOTHCONNECT lineattrs=(color='#F29724' thickness=2 PATTERN=SHORTDASH);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE " 분야별 온실가스 배출량 추세(에너지, 간접배출량 제외)";
	LABEL IVAR1="산업공정" AVAR1="농업" LVAR1="LULUCF" WVAR1="폐기물" ;
	SERIES X=YEAR Y=IVAR1 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=AVAR1 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=LVAR1 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=WVAR1 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=2 PATTERN=LONGDASH);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE " 에너지 산업 : 분야별 온실가스 배출량 추세";
	LABEL EVAR4="공공전기 및 열 생산" EVAR5="석유정제" EVAR6="고체연료 제조 및 기타 에너지 산업" ;
	SERIES X=YEAR Y=EVAR4 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=EVAR5 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=EVAR6 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;


DATA Nation;
	SET Nation;
	R_CVAR1=DIF(CVAR1)/LAG(CVAR1)*100;
	R_CVAR2=DIF(CVAR2)/LAG(CVAR2)*100;
	R_EVAR1=DIF(EVAR1)/LAG(EVAR1)*100;
	R_IVAR1=DIF(IVAR1)/LAG(IVAR1)*100;
	R_AVAR1=DIF(AVAR1)/LAG(AVAR1)*100;
	R_LVAR1=DIF(LVAR1)/LAG(LVAR1)*100;
	R_WVAR1=DIF(WVAR1)/LAG(WVAR1)*100;
	R_SVAR1=DIF(SVAR1)/LAG(SVAR1)*100;
RUN;

%macro TREND(Type, Rate, numcnt, name);
ods graphics / width=4in height=3in;
ods layout gridded columns=3 advance=table;
%DO i=1 %to &numcnt;
%let Type1=%qscan(%bquote(&Type),&i);
%let Type2=%qscan(%bquote(&Rate),&i);
%let cntname=%qscan(%bquote(&name),&i);

PROC SGPLOT DATA=Nation NOAUTOLEGEND;
	TITLE "&cntname";
	SERIES X=Year Y=&Type1/SMOOTHCONNECT LINEATTRS=(COLOR=RED);
	SERIES X=YEAR Y=&Type2/SMOOTHCONNECT LINEATTRS=(COLOR=BLUE PATTERN=DASH) Y2AXIS;
	Y2AXIS LABEL="증감률(%)" labelattrs=(size=9);
	YAXIS LABEL="총배출량 (Gg CO2 eq.)" labelattrs=(size=9);
	XAXIS GRID LABEL="연도" labelattrs=(size=9);
	REFLINE 0 / AXIS=Y2;
run;
TITLE; FOOTNOTE;
%end;
ODS LAYOUT END;
ODS GRAPHICS/RESET;
%mend;
%trend(Type=EVAR1 IVAR1 AVAR1 LVAR1 WVAR1 SVAR1, Rate=R_EVAR1 R_IVAR1 R_AVAR1 R_LVAR1 R_WVAR1 R_SVAR1, name=에너지 산업공정 농업 LULUCF 폐기물 간접배출량, numcnt=6);

PROC SGPLOT DATA=Nation;
	TITLE " 대한민국 온실가스 배출량 증감율";
	LABEL R_CVAR1="총배출량" R_CVAR2="순배출량 ";
	SERIES X=YEAR Y=R_CVAR1 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2) ;
	SERIES X=YEAR Y=R_CVAR2 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2);
	YAXIS LABEL="증감률 (%)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
	REFLINE 1998 / AXIS=X LABEL="1998년";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE " 대한민국 온실가스 배출량 증감율";
	LABEL R_CVAR1="증감률" CVAR1="총배출량(Gg CO2 eq.) ";
	SERIES X=YEAR Y=CVAR1 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2) ;
	SERIES X=YEAR Y=R_CVAR1 /Y2AXIS SMOOTHCONNECT lineattrs=(color='BLUE' thickness=2 PATTERN=DASH) TRANSPARENCY=0.5;
	Y2AXIS LABEL="증감률 (%)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	REFLINE 0 / AXIS=Y2;
	FOOTNOTE J=L "Source : 2020 NIR";
	REFLINE 1998 / AXIS=X LABEL="1998년";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE " 분야별 온실가스 배출량 증감율";
	LABEL R_EVAR1="에너지" R_IVAR1="산업공정" R_AVAR1="농업" R_LVAR1="LULUCF" R_WVAR1="폐기물" R_SVAR1="간접배출량" ;
	SERIES X=YEAR Y=R_EVAR1 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=1 ) ;
	SERIES X=YEAR Y=R_IVAR1 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=1 PATTERN=DASH);
	SERIES X=YEAR Y=R_AVAR1 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=1 PATTERN=DOT);
	SERIES X=YEAR Y=R_LVAR1 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=1 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=R_WVAR1 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=1 PATTERN=LONGDASH);
	SERIES X=YEAR Y=R_SVAR1 /SMOOTHCONNECT lineattrs=(color='#F29724' thickness=1 PATTERN=SHORTDASH);
	YAXIS LABEL="증감율 (%)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	REFLINE 0 / AXIS=Y;
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE " 분야별 온실가스 배출량 증감율";
	LABEL R_EVAR1="에너지" R_IVAR1="산업공정" R_AVAR1="농업" R_LVAR1="LULUCF" R_WVAR1="폐기물" R_SVAR1="간접배출량" ;
	REG X=YEAR Y=R_EVAR1 / degree=2 lineattrs=(color='BLACK' thickness=2) NOMARKERS;
	REG X=YEAR Y=R_IVAR1 / degree=2 lineattrs=(color='#2B6A6C' thickness=2) NOMARKERS;
	REG X=YEAR Y=R_AVAR1 / degree=2 lineattrs=(color='#801411' thickness=2) NOMARKERS;
	REG X=YEAR Y=R_LVAR1 / degree=2 lineattrs=(color='#B80D48' thickness=2) NOMARKERS;
	REG X=YEAR Y=R_WVAR1 / degree=2 lineattrs=(color='#1429B3' thickness=2) NOMARKERS;
	REG X=YEAR Y=R_SVAR1 / degree=2 lineattrs=(color='#F29724' thickness=2) NOMARKERS;

	SCATTER X=YEAR Y=R_EVAR1 / MARKERATTRS=(color='BLACK');
	SCATTER X=YEAR Y=R_IVAR1 / MARKERATTRS=(color='#2B6A6C') ;
	SCATTER X=YEAR Y=R_AVAR1 / MARKERATTRS=(color='#801411') ;
	SCATTER X=YEAR Y=R_LVAR1 / MARKERATTRS=(color='#B80D48') ;
	SCATTER X=YEAR Y=R_WVAR1 / MARKERATTRS=(color='#1429B3');
	SCATTER X=YEAR Y=R_SVAR1 / MARKERATTRS=(color='#F29724');

	YAXIS LABEL="증감율 (%)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);

	legenditem type=markerline name="R_EVAR1" / label="에너지" lineattrs=(color='BLACK') markerattrs=(color='BLACK') labelattrs=(size=10.5pt); 
	legenditem type=markerline name="R_IVAR1" / label="산업공정" lineattrs=(color='#2B6A6C') markerattrs=(color='#2B6A6C') labelattrs=(size=10.5pt); 
	legenditem type=markerline name="R_AVAR1" / label="농업" lineattrs=(color='#801411') markerattrs=(color='#801411') labelattrs=(size=10.5pt); 
	legenditem type=markerline name="R_LVAR1" / label="LULUCF" lineattrs=(color='#B80D48') markerattrs=(color='#B80D48') labelattrs=(size=10.5pt); 
	legenditem type=markerline name="R_WVAR1" / label="폐기물" lineattrs=(color='#1429B3') markerattrs=(color='#1429B3') labelattrs=(size=10.5pt); 
	legenditem type=markerline name="R_SVAR1" / label="간접배출량" lineattrs=(color='#F29724') markerattrs=(color='#F29724') labelattrs=(size=10.5pt); 
	REFLINE 0 / AXIS=Y;
	KEYLEGEND "R_EVAR1" "R_IVAR1" "R_AVAR1" "R_LVAR1" "R_WVAR1" "R_SVAR1";
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;


/*--구체적 산업별 분석--*/

PROC SGPLOT DATA=Nation;
	TITLE "에너지 : 연료연소";
	LABEL YEAR="연도" EVAR3="에너지산업" EVAR7="제조업 및 건설업" EVAR20="수송" EVAR26="기타" ;
	SERIES X=YEAR Y=EVAR3 /SMOOTHCONNECT  lineattrs=(color='#F29724' thickness=1 ) ;;
	SERIES X=YEAR Y=EVAR7 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=1 PATTERN=DASH);
	SERIES X=YEAR Y=EVAR20 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=1 PATTERN=DOT);
	SERIES X=YEAR Y=EVAR26 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=1 PATTERN=DASHDASHDOT);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
RUN;

PROC SGPLOT DATA=Nation;
	TITLE "에너지 : 탈루";
	LABEL YEAR="연도" EVAR32="고체연료" EVAR33="석유 및 천연가스" ;
	SERIES X=YEAR Y=EVAR32 /SMOOTHCONNECT  lineattrs=(color='#F29724' thickness=1 ) ;;
	SERIES X=YEAR Y=EVAR33 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=1 PATTERN=DASH);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
RUN;

PROC SGPLOT DATA=Nation;
	TITLE "산업공정";
	LABEL IVAR2="광물산업" IVAR9="화학산업" IVAR10="금속산업" IVAR15="기타산업" IVAR16="할로카본 및 육불화황 생산" IVAR19="할로카본 및 육불화황 생산" ;
	SERIES X=YEAR Y=IVAR2 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2 ) ;
	SERIES X=YEAR Y=IVAR9 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=IVAR10 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=IVAR15 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=IVAR16 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=2 PATTERN=LONGDASH);
	SERIES X=YEAR Y=IVAR19 /SMOOTHCONNECT lineattrs=(color='#F29724' thickness=2 PATTERN=SHORTDASH);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE "농업";
	LABEL AVAR2="장내발효" AVAR13="가축분뇨처리" AVAR24="벼재배" AVAR27="농경지토양" AVAR31="사바나 소각" AVAR32="작물잔사소각" ;
	SERIES X=YEAR Y=AVAR2 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2 ) ;
	SERIES X=YEAR Y=AVAR13 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=AVAR24 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=AVAR27 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=AVAR31 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=2 PATTERN=LONGDASH);
	SERIES X=YEAR Y=AVAR32 /SMOOTHCONNECT lineattrs=(color='#F29724' thickness=2 PATTERN=SHORTDASH);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE "LULUCF(토지이용·토지전용·산림분야)";
	LABEL LVAR2="산림지" LVAR8="농경지" LVAR14="초지" LVAR19="습지" LVAR24="정주지" LVAR25="기타토지" ;
	SERIES X=YEAR Y=LVAR2 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2 ) ;
	SERIES X=YEAR Y=LVAR8 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=LVAR14 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=LVAR19 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=LVAR24 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=2 PATTERN=LONGDASH);
	SERIES X=YEAR Y=LVAR25 /SMOOTHCONNECT lineattrs=(color='#F29724' thickness=2 PATTERN=SHORTDASH);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE "폐기물";
	LABEL WVAR2="폐기물매립" WVAR5="하폐수처리" WVAR8="폐기물소각" WVAR9="기타" ;
	SERIES X=YEAR Y=WVAR2 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2 ) ;
	SERIES X=YEAR Y=WVAR5 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=WVAR8 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=WVAR9 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE "간접배출량(전기 및 열 사용) : 연료연소";
	LABEL SVAR3="에너지산업" SVAR7="제조업 및 건설업" SVAR14="수송" SVAR20="기타" SVAR24="미분류" ;
	SERIES X=YEAR Y=SVAR3 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=2 ) ;
	SERIES X=YEAR Y=SVAR7 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2 PATTERN=DASH);
	SERIES X=YEAR Y=SVAR14 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=2 PATTERN=DOT);
	SERIES X=YEAR Y=SVAR20 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=2 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=SVAR24 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=2 PATTERN=LONGDASH);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;
TITLE;

PROC SGPLOT DATA=Nation;
	TITLE "간접배출량(전기 및 열 사용) : 기타";
	LABEL YEAR="연도" SVAR21="상업/공공" SVAR22="가정" SVAR23="농업/임업/어업";
	SERIES X=YEAR Y=SVAR21 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=1 ) ;;
	SERIES X=YEAR Y=SVAR22 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=1 PATTERN=DASH);
	SERIES X=YEAR Y=SVAR23 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=1 PATTERN=DOT);
	YAXIS LABEL="배출량 (Gg CO2 eq.)" labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
RUN;
TITLE;


/*-----국가 : 오염물질별 분석-----*/
/*오염물질원별 총배출량 (1990-2018)*/
%macro TREND(Pollutant, numcnt, name);
ods graphics / width=4in height=3in;
ods layout gridded columns=3 advance=table;
%DO i=1 %to &numcnt;
%let pollutant1=%qscan(%bquote(&Pollutant),&i);
%let cntname=%qscan(%bquote(&name),&i);

PROC SGPLOT DATA=Nation_pollutant NOAUTOLEGEND;
	TITLE "&cntname";
	where Pollutant="&pollutant1";
	SERIES X=Year Y=CVAR1/SMOOTHCONNECT LINEATTRS=(COLOR=RED);
	YAXIS LABEL="총배출량 (Gg CO2 eq.)" labelattrs=(size=9);
	XAXIS GRID LABEL="연도" labelattrs=(size=9);
run;
TITLE; FOOTNOTE;
%end;
ODS LAYOUT END;
ODS GRAPHICS/RESET;
%mend;
%trend(Pollutant=CO2 CH4 N2O HFCs PFCs SF6, name=CO2 CH4 N2O HFCs PFCs SF6, numcnt=6);


/* 오염물질원별 총배출량 & 증감률 (1991-2018)*/
DATA Nation_pollutant1;
	SET Nation_pollutant;
	R_CVAR1=DIF(CVAR1)/LAG(CVAR1)*100;
	IF Year=1990 THEN R_CVAR1=.;	
RUN;

%macro TREND(Pollutant, numcnt, name);
ods graphics / width=4in height=3in;
ods layout gridded columns=3 advance=table;
%DO i=1 %to &numcnt;
%let pollutant1=%qscan(%bquote(&Pollutant),&i);
%let cntname=%qscan(%bquote(&name),&i);

PROC SGPLOT DATA=Nation_pollutant1 NOAUTOLEGEND;
	TITLE "&cntname";
	where Pollutant="&pollutant1";
	SERIES X=Year Y=CVAR1/SMOOTHCONNECT LINEATTRS=(COLOR=RED);
	SERIES X=Year Y=R_CVAR1/SMOOTHCONNECT LINEATTRS=(COLOR=BLUE PATTERN=DASH) TRANSPARENCY=0.3 Y2AXIS;
	YAXIS LABEL="총배출량 (Gg CO2 eq.)" labelattrs=(size=9);
	Y2AXIS LABEL="증감률(%) " labelattrs=(size=9);
	XAXIS GRID LABEL="연도" labelattrs=(size=9);
	REFLINE 0 / AXIS=Y2;
run;
TITLE; FOOTNOTE;
%end;
ODS LAYOUT END;
ODS GRAPHICS/RESET;
%mend;
%trend(Pollutant=CO2 CH4 N2O HFCs PFCs SF6, name=CO2 CH4 N2O HFCs PFCs SF6, numcnt=6);

/* 오염물질, 산업별 배출량 추세 */
%macro TREND(Pollutant, numcnt, name);
ods graphics / width=5in height=4in;
ods layout gridded columns=3 advance=table;
%DO i=1 %to &numcnt;
%let pollutant1=%qscan(%bquote(&Pollutant),&i);
%let cntname=%qscan(%bquote(&name),&i);

PROC SGPLOT DATA=Nation_pollutant;
	TITLE "&cntname";
	where Pollutant="&pollutant1";
	LABEL EVAR1="에너지" IVAR1="산업공정" AVAR1="농업" LVAR1="LULUCF" WVAR1="폐기물" BVAR1="국제벙커링 및 다국적작전" ;
	SERIES X=YEAR Y=EVAR1 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=1 ) ;
	SERIES X=YEAR Y=IVAR1 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=1 PATTERN=DASH);
	SERIES X=YEAR Y=AVAR1 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=1 PATTERN=DOT);
	SERIES X=YEAR Y=LVAR1 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=1 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=WVAR1 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=1 PATTERN=LONGDASH);
	SERIES X=YEAR Y=BVAR1 /SMOOTHCONNECT lineattrs=(color='#F29724' thickness=1 PATTERN=SHORTDASH);
	YAXIS LABEL="총배출량 (Gg CO2 eq.)" labelattrs=(size=9);
	XAXIS GRID LABEL="연도" labelattrs=(size=9);
run;
TITLE; FOOTNOTE;
%end;
ODS LAYOUT END;
ODS GRAPHICS/RESET;
%mend;
%trend(Pollutant=CO2 CH4 N2O , name=CO2 CH4 N2O , numcnt=3); /* 다른 물질은 산업공정만 있음*/


/* 집약도 : 1인당 온실가스 배출량, 실질 국내총생산(GDP) 대비 */
/* 1인당 온실가스 배출량 추세 */
DATA NATION;
	SET NATION;
	POVAR4_1=POVAR4*1;
RUN;

PROC SGPLOT DATA=Nation;
	Title "1인당 온실가스 배출량 추세";
	WHERE YEAR>1990;
	LABEL POVAR3="1인당 배출량(톤 CO2eq./인)" POVAR4_1="1인당 배출량 증감률(%)";
	SERIES X=YEAR Y=POVAR3/SMOOTHCONNECT  lineattrs=(color='#2B6A6C' thickness=2) ;
	SERIES X=YEAR Y=POVAR4_1/SMOOTHCONNECT Y2AXIS lineattrs=(color='#801411' thickness=2 PATTERN=DASH) TRANSPARENCY=0.5;
	YAXIS labelattrs=(size=11);
	Y2AXIS labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
	REFLINE 0 / AXIS=Y2;
RUN;

/* GDP당 배출량 증감률 추세 */
DATA NATION;
	SET NATION;
	ECVAR4_1=ECVAR4*1;
RUN;

PROC SGPLOT DATA=Nation;
	Title "GDP당 온실가스 배출량 추세";
	WHERE YEAR>1990;
	LABEL ECVAR3="GDP당 배출량(톤 CO2eq./10억원)" ECVAR4_1="GDP당 배출량 증감률(%)";
	SERIES X=YEAR Y=ECVAR3/SMOOTHCONNECT  lineattrs=(color='#2B6A6C' thickness=2) ;
	SERIES X=YEAR Y=ECVAR4_1/SMOOTHCONNECT Y2AXIS lineattrs=(color='#801411' thickness=2 PATTERN=DASH) TRANSPARENCY=0.5;
	YAXIS labelattrs=(size=11);
	Y2AXIS labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
	REFLINE 0 / AXIS=Y2;
RUN;

PROC SGPLOT DATA=Nation;
	TITLE "1인당 온실가스 배출량과 추계인구";
	LABEL POVAR1="추계인구(천명)" POVAR3="1인당 배출량(톤 CO2eq./인)";
	SERIES X=YEAR Y=POVAR3/SMOOTHCONNECT  lineattrs=(color='#2B6A6C' thickness=2);
	SERIES X=YEAR Y=POVAR1/SMOOTHCONNECT Y2AXIS lineattrs=(color='#801411' thickness=2) ;
	YAXIS labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;

PROC SGPLOT DATA=Nation;
	TITLE "실질 GDP와 GDP당 배출량";
	LABEL ECVAR1="실질 GDP(10억 원)" ECVAR3="GDP당 배출량(톤 CO2eq./10억 원)";
	SERIES X=YEAR Y=ECVAR1/SMOOTHCONNECT  lineattrs=(color='#2B6A6C' thickness=2);
	SERIES X=YEAR Y=ECVAR3/SMOOTHCONNECT Y2AXIS lineattrs=(color='#801411' thickness=2);
	YAXIS labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;

/* 1인당 GDP와 1인당 배출량*/
DATA Nation;
	SET Nation;
	GDP_Capita=(ECVAR1*100000)/(POVAR1*1000);
RUN;

PROC CORR DATA=Nation;
	VAR GDP_Capita POVAR3;
RUN;

PROC GLM DATA=Nation;
	MODEL POVAR3= GDP_Capita GDP_Capita*GDP_Capita;
RUN;

PROC SGPLOT DATA=Nation;
	TITLE "1인당 GDP와 1인당 배출량";
	LABEL GDP_Capita="1인당 GDP(만 원)" POVAR3="1인당 배출량(톤 CO2eq./인)";
	SERIES X=YEAR Y=GDP_Capita/SMOOTHCONNECT  lineattrs=(color='#2B6A6C' thickness=2);
	SERIES X=YEAR Y=POVAR3/SMOOTHCONNECT Y2AXIS lineattrs=(color='#801411' thickness=2);
	YAXIS labelattrs=(size=11);
	XAXIS GRID LABEL="연도" labelattrs=(size=11);
	FOOTNOTE J=L "Source : 2020 NIR";
RUN;


/*-----지역별 분석-----*/
PROC SORT DATA=C.Local_final OUT=Local;
	BY Region;
RUN;

DATA Local1;
	SET Local;
	R_CVAR1=DIF(CVAR1)/LAG(CVAR1)*100;
	IF Year=1990 THEN R_CVAR1=.;	
RUN;

%macro TREND(Region, numcnt);
ods graphics / width=2.5in height=2in NOBORDER;
ods layout gridded columns=4 advance=table;
%DO i=1 %to &numcnt;
%let Region1=%qscan(%bquote(&Region),&i);
%let cntname=%qscan(%bquote(&Region),&i);
PROC SGPLOT DATA=Local1 NOAUTOLEGEND;
	TITLE "&cntname"  height=30pt;
	where Region="&Region1"  AND YEAR>1999;
	SERIES X=Year Y=CVAR1/SMOOTHCONNECT LINEATTRS=(COLOR=RED);
	YAXIS DISPLAY=(NOLABEL) LABEL="총배출량 (Gg CO2 eq.)" labelattrs=(size=12) valueattrs=(size=12pt);
	XAXIS GRID DISPLAY=NONE labelattrs=(size=9);
	REFLINE 0 / AXIS=Y2;
RUN;
TITLE; FOOTNOTE;
%end;
ODS LAYOUT END;
ODS GRAPHICS/RESET;
%mend;
%trend(Region=인천광역시 전라남도 경상북도 경기도 충청남도 광주광역시 경상남도 강원도 충청북도 전라북도 대전광역시 부산광역시 서울특별시 울산광역시 대구광역시, numcnt=15);

ods graphics on/width=800 height=500 attrpriority=none;
PROC SGPLOT DATA=LOCAL1(WHERE=(YEAR=2018 or YEAR=1990));
	VBAR REGION/RESPONSE=CVAR1  GROUP=YEAR groupdisplay=cluster;
	XAXIS LABEL="지역" labelattrs=(size=12) valueattrs=(size=11pt);;
	YAXIS LABEL="총배출량" GRID  labelattrs=(size=12) valueattrs=(size=11pt);;
RUN;

/*RPS의 효과가 있는 지역 신재생에너지 발전량 추세 시각화*/;
%macro TREND(Region, numcnt);
ods graphics / width=4in height=3in;
ods layout gridded columns=3 advance=table;
%DO i=1 %to &numcnt;
%let Region1=%qscan(%bquote(&Region),&i);
%let cntname=%qscan(%bquote(&Region),&i);

PROC SGPLOT DATA=Local1(WHERE=(YEAR>2004)) NOAUTOLEGEND;
	TITLE "&cntname";
	where Region="&Region1";
	SERIES X=Year Y=CEVAR1_1/SMOOTHCONNECT ;
	SERIES X=Year Y=CEVAR1_2/SMOOTHCONNECT ;
	SERIES X=Year Y=CEVAR1_3 /SMOOTHCONNECT;
	SERIES X=Year Y=CEVAR1_4 /SMOOTHCONNECT;
	SERIES X=Year Y=CEVAR1_6 /SMOOTHCONNECT;
	YAXIS LABEL="신재생에너지 발전량" labelattrs=(size=9);
	XAXIS GRID LABEL="연도" labelattrs=(size=9);
	REFLINE 2012 / AXIS=X LABEL="2012년" LINEATTRS=(COLOR=RED);
RUN;
TITLE; FOOTNOTE;
%end;
ODS LAYOUT END;
ODS GRAPHICS/RESET;
%mend;
%trend(Region=강원도 경상남도 대전광역시 전라북도 제주특별자치도, numcnt=5);


/*지역 & 산업별 분석*/
%macro TREND(Region, numcnt);
ods graphics / width=4in height=3in;
ods layout gridded columns=3 advance=table;
%DO i=1 %to &numcnt;
%let Region1=%qscan(%bquote(&Region),&i);
%let cntname=%qscan(%bquote(&Region),&i);

PROC SGPLOT DATA=Local1;
	TITLE "&cntname";
	where Region="&Region1";
	LABEL EVAR1="에너지" IVAR1="산업공정" AVAR1="농업" LVAR1="LULUCF" WVAR1="폐기물" SVAR1="간접배출량" ;
	SERIES X=YEAR Y=EVAR1 /SMOOTHCONNECT  lineattrs=(color='RED' thickness=1 ) ;
	SERIES X=YEAR Y=IVAR1 /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=1 PATTERN=DASH);
	SERIES X=YEAR Y=AVAR1 /SMOOTHCONNECT lineattrs=(color='#801411' thickness=1 PATTERN=DOT);
	SERIES X=YEAR Y=LVAR1 /SMOOTHCONNECT lineattrs=(color='#B80D48' thickness=1 PATTERN=DASHDASHDOT);
	SERIES X=YEAR Y=WVAR1 /SMOOTHCONNECT lineattrs=(color='#1429B3' thickness=1 PATTERN=LONGDASH);
	SERIES X=YEAR Y=SVAR1 /SMOOTHCONNECT lineattrs=(color='#F29724' thickness=1 PATTERN=SHORTDASH);
	YAXIS LABEL="총배출량 (Gg CO2 eq.)" labelattrs=(size=9);
	XAXIS GRID LABEL="연도" labelattrs=(size=9);
run;
TITLE; FOOTNOTE;
%end;
ODS LAYOUT END;
ODS GRAPHICS/RESET;
%mend;
%trend(Region=인천광역시 전라남도 경기도 충청남도 경상북도 광주광역시 강원도 충청북도 경상남도 울산광역시 대전광역시 부산광역시 전라북도 대구광역시, numcnt=15);


/* 지역별 온실가스 배출량 추세 유사도 : DTW */
DATA Local_eng;
   SET Local1;
   LENGTH ENG $30.;
   IF REGION="서울특별시" THEN ENG="Seoul";
   IF REGION="부산광역시" THEN ENG="Busan";
   IF REGION="대구광역시" THEN ENG="Daegu";
   IF REGION="인천광역시" THEN ENG="Incheon";
   IF REGION="광주광역시" THEN ENG="Gwangju";
   IF REGION="대전광역시" THEN ENG="Daejeon";   
   IF REGION="울산광역시" THEN ENG="Ulsan";
   IF REGION="경기도" THEN ENG="Gyeonggi";
   IF REGION="강원도" THEN ENG="Gangwon";
   IF REGION="충청북도" THEN ENG="Chungbuk";
   IF REGION="충청남도" THEN ENG="Chungnam";
   IF REGION="전라북도" THEN ENG="Jeonbuk";
   IF REGION="전라남도" THEN ENG="Jeonnam";
   IF REGION="경상북도" THEN ENG="Gyeongbuk";
   IF REGION="경상남도" THEN ENG="Gyeongnam";
   IF REGION="제주도" THEN ENG="Jeju";
   IF REGION="세종특별자치시" THEN DELETE;
   IF YEAR>1999;
RUN;

PROC SORT DATA=Local_eng;
   BY YEAR;
RUN;

PROC TRANSPOSE DATA=Local_eng OUT=TRANS;
   BY YEAR;
   ID ENG;
   VAR CVAR1;
RUN;

PROC SIMILARITY DATA=TRANS OUT=OUTDT3 OUTSUM=SIM2 ;   
   TARGET Gangwon--Chungbuk/ measure=mabsdev normalize=absolute;
RUN; 

ods graphics on/width=500 height=350 attrpriority=none;
PROC CLUSTER DATA=SIM2 (DROP=_STATUS_) outtree=tree method=ward plots=dendrogram;
   ID _INPUT_;
RUN;

DATA A;
	SET C.LOCAL_FINAL;
	KEEP EFVAR_1 EFVAR_2 EFVAR_3 EFVAR_4 EFVAR_5 EFVAR_6 INH_1C81T2Z10 INH_1DA7014S_01T200 CVAR1 REGION YEAR;
	IF 2006<YEAR<2018; 
	IF REGION="세종특별자치시" THEN DELETE;
RUN;

/* 지역별 최종에너지소비량 시각화 */
PROC SORT DATA=A;
	BY REGION;
RUN;

PROC TIMEDATA DATA=A
	OUT=A2 PLOTS=ALL;	
	BY REGION;
	SETMISS=MISSING;
	VAR EFVAR_1;
	CYCLETYPE=BOL;
RUN;

PROC SORT DATA=A2;
	BY REGION;
RUN;

PROC SGPANEL DATA=A;
	PANELBY REGION /COLUMNS=4 ROWS=4 HEADERATTRS=(family="Gulim") ;
	SERIES X=YEAR Y=EFVAR_1/SMOOTHCONNECT;
	SCATTER X=YEAR Y=EFVAR_1;
	COLAXIS DISPLAY=(NOLABEL) ;
	ROWAXIS LABEL="최종에너지소비량(1,000toe)" labelattrs=(FAMILY='Gulim' size=9)  VALUEATTRS=(FAMILY='Gulim' size=9);
	LABEL Region="지역";
	LABEL EFVAR_1="최종에너지소비량";
RUN;

/* 탈동조화 현상 분석 */

DATA DI;
	SET C.LOCAL_FINAL;
	KEEP REGION YEAR CVAR1 INH_1C81T2Z10 EFVAR_1;
	IF YEAR=2019 THEN DELETE;
RUN;

PROC SORT DATA=DI;
	BY REGION YEAR;
RUN;

DATA DI2;
	SET DI;
	R_CVAR1=DIF(CVAR1)/LAG(CVAR1);
	R_GRDP=DIF(INH_1C81T2Z10)/LAG(INH_1C81T2Z10);
	R_EFVAR_1=DIF(EFVAR_1)/LAG(EFVAR_1);
	IF YEAR=1990 THEN R_CVAR1=. AND R_GRDP=.;
	DI=R_CVAR1/R_GRDP;
	DI2=R_EFVAR_1/R_GRDP;
	IF REGION="세종특별자치시" THEN DELETE;
	IF YEAR>2009;
RUN;

PROC PRINT DATA=DI2;
	WHERE R_GRDP<0;
RUN;

/*GRDP-온실가스 배출량*/
PROC SORT DATA=DI2;
	BY REGION;
RUN;

PROC TIMEDATA DATA=DI2
	OUT=DI3 PLOTS=ALL;	
	WHERE REGION IN ("강원도" "경기도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "인천광역시" "충청북도");
	BY REGION;
	SETMISS=MISSING;
	VAR DI;
	CYCLETYPE=BOL;
RUN;

PROC SGPANEL DATA=DI3;
	WHERE REGION IN ("강원도" "경기도" "광주광역시" "대전광역시" "부산광역시" "서울특별시" "인천광역시" "충청북도");
	PANELBY REGION /COLUMNS=4 ROWS=2 HEADERATTRS=(family="Gulim") ;
	SERIES X=TIME Y=DI/SMOOTHCONNECT;
	SCATTER X=TIME Y=DI;
	REFLINE 1 /LINEATTRS=(COLOR=RED);
	REFLINE 0 /LINEATTRS=(COLOR=RED);
	COLAXIS DISPLAY=(NOLABEL) ;
	ROWAXIS LABEL="Decoupling Index" labelattrs=(FAMILY='Gulim' size=9)  VALUEATTRS=(FAMILY='Gulim' size=9);
	LABEL Region="지역";
	LABEL DI="Decoupling Index";
RUN;


/*----국가 간 비교----*/

DATA WB;
	SET C.World;
RUN;

PROC FREQ DATA=WB;
	TABLE idname;
RUN;

ods graphics on/width=800 height=500 attrpriority=none;

data cont;
length value $30;
 infile datalines dsd;
retain id "myid";
input value $  fillcolor $ linecolor $ markercolor $ markersymbol $ markerTransparency;
datalines;
KOR,  #B80D48, #B80D48, #B80D48, square, 0,
USA, #2B6A6C, #2B6A6C, #2B6A6C, circle, 0.8,
JPN, #404040, #404040, #404040, triangle, 0.8,
CHN, #C44114,  #C44114, #C44114, asterisk, 0.8,
GBR, #2931CC,  #2931CC, #2931CC, diamond, 0.8,
DEU, #F29724,  #F29724, #F29724, plus, 0.8
;
run;

/*CO2 emissions (metric tons per capita)*/
PROC SGPLOT DATA=WB;
	TITLE "1인당 CO2 배출량 (세계)";
	WHERE IDNAME IN ('World');
	SERIES X=YEAR Y=WVAR11  /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2);
	YAXIS LABEL="1인당 CO2 배출량";
	XAXIS GRID LABEL="연도" labelattrs=(size=9);
	FOOTNOTE J=L "Source : World Bank";
	REFLINE 2008 / AXIS=X LABEL="Finanical crisis";
	REFLINE 1997 / AXIS=X LABEL="Asian financial crisis";
	REFLINE 1973 / AXIS=X LABEL="1st oil shock";
RUN;

PROC SGPLOT DATA=WB dattrmap=cont;
	TITLE "1인당 CO2배출량 비교";
	WHERE ISO3 IN ('KOR' 'USA' 'JPN' 'CHN' 'GBR' 'DEU');
	VLINE YEAR/RESPONSE=WVAR11 stat=mean  GROUP=ISO3 attrid=myid LINEATTRS=(THICHNESS=2);;
	YAXIS LABEL="1인당 CO2 배출량"  labelattrs=(size=11) valueattrs=(size=11);
	XAXIS GRID LABEL="연도" TYPE=TIME INTERVAL=YEAR  labelattrs=(size=11) valueattrs=(size=11);
	FOOTNOTE J=L "Source : World Bank";
	keylegend / titleattrs=(size=10pt) valueattrs=(size=10pt) ;
	LABEL iso3="ISO3";
RUN;


/*Total greenhouse gas emissions (% change from 1990)*/
PROC SGPLOT DATA=WB;
	TITLE "Total Greenhouse Gas Emissions (% change from 1990))";
	WHERE IDNAME IN ('World');
	SERIES X=YEAR Y=WVAR12  /SMOOTHCONNECT lineattrs=(color='#2B6A6C' thickness=2);
	YAXIS LABEL="온실가스 배출 증감률(%)";
	XAXIS GRID VALUES=(1990 TO 2012) LABEL="연도" TYPE=TIME INTERVAL=YEAR; 
	FOOTNOTE J=L "Source : World Bank";
	REFLINE 2008 / AXIS=X LABEL="Finanical crisis";
	REFLINE 1997 / AXIS=X LABEL="Asian financial crisis";
	REFLINE 1973 / AXIS=X LABEL="1st oil shock";
RUN;

PROC SGPLOT DATA=WB dattrmap=cont;
	TITLE "Total Greenhouse Gas Emissions (% change from 1990)";
	WHERE ISO3 IN ('KOR' 'USA' 'JPN' 'CHN' 'GBR' 'DEU');
	VLINE YEAR/RESPONSE=WVAR12 stat=mean  GROUP=ISO3 attrid=myid ;
	YAXIS LABEL="온실가스 배출 변화율(%)";
	XAXIS GRID VALUES=(1990 TO 2012) LABEL="연도" TYPE=TIME INTERVAL=YEAR; 
	FOOTNOTE J=L "Source : World Bank";
RUN;


/* CO2 emissions - GDP 관계 분석 */
DATA WB;
	SET WB;
	LABEL=ISO3;
	IF ISO3 NOT IN ("KOR") THEN 
	LABEL=" " ;
RUN;
TITLE;

PROC GLM DATA=WB(WHERE=(YEAR=1990 AND cont_un^=" " )) ;
	MODEL WVAR11=WVAR9;
RUN;

PROC GLM DATA=WB(WHERE=(YEAR=1990 AND cont_un^=" " )) ;
	MODEL WVAR11=WVAR9 WVAR9*WVAR9;
RUN;

PROC SGPLOT DATA=WB(WHERE=(YEAR=1990 AND cont_un^=" " )) ;
	TITLE "1인당 GDP와 1인당 CO2 배출량 (1990)";
	LABEL WVAR9="1인당 GDP" WVAR11="1인당 CO2 배출량(mt)" cont_un="대륙";
	SCATTER X=WVAR9 Y=WVAR11 / DATALABEL=LABEL GROUP=cont_un ;
	REG X=WVAR9 Y=WVAR11 /  lineattrs=(color='#2B6A6C' thickness=1) NOMARKERS CURVELABEL="R-Sqaure=0.43";
	REG X=WVAR9 Y=WVAR11 / DEGREE=2 NOMARKERS  lineattrs=(color='#801411' thickness=1) CURVELABEL="R-Sqaure=0.51";
	FOOTNOTE J=L "Source : World Bank";
	XAXIS GRID MIN=0 MAX=40000;
RUN;

PROC GLM DATA=WB(WHERE=(YEAR=2000 AND cont_un^=" " )) ;
	MODEL WVAR11=WVAR9;
RUN;

PROC GLM DATA=WB(WHERE=(YEAR=2000 AND cont_un^=" " )) ;
	MODEL WVAR11=WVAR9 WVAR9*WVAR9;
RUN;

PROC SGPLOT DATA=WB(WHERE=(YEAR=2000)) ;
	TITLE "1인당 GDP와 1인당 CO2 배출량 (2000)";
	LABEL WVAR9="1인당 GDP" WVAR11="1인당 CO2 배출량(mt)" cont_un="대륙";
	SCATTER X=WVAR9 Y=WVAR11 / DATALABEL=LABEL GROUP=cont_un ;
	REG X=WVAR9 Y=WVAR11 /  lineattrs=(color='#2B6A6C' thickness=1) NOMARKERS CURVELABEL="R-Sqaure=0.43";;
	REG X=WVAR9 Y=WVAR11 / DEGREE=2 NOMARKERS   lineattrs=(color='#801411' thickness=1) CURVELABEL="R-Sqaure=0.47";;
	FOOTNOTE J=L "Source : World Bank";
	XAXIS GRID MIN=0 MAX=60000;
RUN;

PROC GLM DATA=WB(WHERE=(YEAR=2016 AND cont_un^=" " )) ;
	MODEL WVAR11=WVAR9;
	OUTPUT OUT=REG2019 RESIDUAL=RESIDUAL;
RUN;
QUIT;

DATA REG2019_re;
	SET REG2019;
	IF RESIDUAL>0 THEN A='+';
	IF RESIDUAL<0 THEN A='-';
RUN;

PROC FREQ DATA=REG2019_re;
	TABLE cont_un*A;
RUN;

PROC GLM DATA=WB(WHERE=(YEAR=2016 AND cont_un^=" " )) ;
	MODEL WVAR11=WVAR9 WVAR9*WVAR9;
RUN;
QUIT;

PROC SGPLOT DATA=WB(WHERE=(YEAR=2016 AND cont_un^=" " ));
	TITLE "1인당 GDP와 1인당 CO2 배출량 (2016)";
	LABEL WVAR9="1인당 GDP" WVAR11="1인당 CO2 배출량(mt)" cont_un="대륙";
	SCATTER X=WVAR9 Y=WVAR11 / DATALABEL=LABEL GROUP=cont_un ;
	REG X=WVAR9 Y=WVAR11 /  lineattrs=(color='#2B6A6C' thickness=1) NOMARKERS CURVELABEL="R-Sqaure=0.32";
	REG X=WVAR9 Y=WVAR11 / DEGREE=2 NOMARKERS   lineattrs=(color='#801411' thickness=1) CURVELABEL="R-Sqaure=0.40";;
	FOOTNOTE J=L "Source : World Bank";
	YAXIS MIN=0 MAX=40;
	XAXIS GRID;
RUN;

/*인구와 1인당 배출량*/
PROC SGPLOT DATA=WB(WHERE=(YEAR=2016));
	TITLE "추계 인구와 1인당 CO2 배출량 (2016)";
	LABEL WVAR15="인구" WVAR11="1인당 CO2 배출량(mt)";
	SCATTER X=WVAR15 Y=WVAR11 / DATALABEL=LABEL;
RUN;

PROC SGPLOT DATA=WB(WHERE=(YEAR=2016 AND WVAR15<100000000));
	TITLE "추계 인구와 1인당 CO2 배출량 (2016)";
	LABEL WVAR15="인구" WVAR11="1인당 CO2 배출량(mt)";
	SCATTER X=WVAR15 Y=WVAR11 / DATALABEL=LABEL;
	REG  X=WVAR15 Y=WVAR11 /  lineattrs=(color='#2B6A6C' thickness=1) ;
RUN;

PROC SGPLOT DATA=WB(WHERE=(YEAR=2000 AND WVAR15<100000000));
	TITLE "추계 인구와 1인당 CO2 배출량 (2000)";
	LABEL WVAR15="인구" WVAR11="1인당 CO2 배출량(mt)";
	SCATTER X=WVAR15 Y=WVAR11 / DATALABEL=LABEL;
	REG  X=WVAR15 Y=WVAR11 /  lineattrs=(color='#2B6A6C' thickness=1) ;
RUN;

PROC SGPLOT DATA=WB(WHERE=(YEAR=1990 AND WVAR15<100000000));
	TITLE "추계 인구와 1인당 CO2 배출량 (1990)";
	LABEL WVAR15="인구" WVAR11="1인당 CO2 배출량(mt)";
	SCATTER X=WVAR15 Y=WVAR11 / DATALABEL=LABEL;
	REG  X=WVAR15 Y=WVAR11 /  lineattrs=(color='#2B6A6C' thickness=1) ;
RUN;


/* 1인당 CO2 배출량 추세 유사도 분석 : DTW */

PROC SORT DATA=WB OUT=SORT;
	BY YEAR;
RUN;

PROC TRANSPOSE DATA=SORT OUT=TRANS;
	BY YEAR;
	ID ISO3;
	VAR WVAR11;
RUN;

OPTIONS VALIDVARNAME=ANY;

PROC SIMILARITY DATA=TRANS OUT=OUTDT3 OUTSUM=SIM2 ;
	TARGET AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC
		ISL IRL 	ISR ITA JPN KOR LUX MEX NLD NZL POL PRT SVK SVN
		ESP 	SWE CHE TUR GBR USA / NORMALIZE=ABSOLUTE MEASURE=MABSDEV;
RUN; 

ods graphics on/width=400 height=800 attrpriority=none;
PROC CLUSTER DATA=SIM2 (DROP=_STATUS_) OUTTREE=TREE METHOD=WARD PLOTS=DENDOGRAM;
	ID _INPUT_;
RUN;

ods graphics on/width=800 height=600 attrpriority=none;
PROC SGPLOT DATA=WB dattrmap=cont;
	TITLE "1인당 CO2배출량 비교";
	WHERE ISO3 IN ('KOR' 'TUR' 'JPN' 'MEX');
	VLINE YEAR/RESPONSE=WVAR11 stat=mean  GROUP=ISO3 attrid=myid;;
	YAXIS LABEL="1인당 CO2 배출량";
	XAXIS GRID LABEL="연도" TYPE=TIME INTERVAL=YEAR; 
	FOOTNOTE J=L "Source : World Bank";
RUN;

ods graphics on/width=800 height=600 attrpriority=none;
PROC SGPLOT DATA=WB dattrmap=cont;
	TITLE "1인당 CO2배출량 비교";
	WHERE ISO3 IN ('FRA' 'SWE' 'DNK' );
	VLINE YEAR/RESPONSE=WVAR11 stat=mean  GROUP=ISO3 attrid=myid;;
	YAXIS LABEL="Total greenhouse gas emissions (% change from 1990)";
	XAXIS GRID VALUES=(1990 TO 2012) LABEL="연도" TYPE=TIME INTERVAL=YEAR; 
	FOOTNOTE J=L "Source : World Bank";
RUN;


/* 유사도 분석 DTW : Total greenhouse gas emissions (% change from 1990) */

PROC TRANSPOSE DATA=SORT OUT=TRANS;
	BY YEAR;
	ID ISO3;
	VAR WVAR12;
RUN;

OPTIONS VALIDVARNAME=ANY;

PROC SIMILARITY DATA=TRANS OUT=OUTDT3 OUTSUM=SIM2 ;
	TARGET AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC
		ISL IRL 	ISR ITA JPN KOR LUX MEX NLD NZL POL PRT SVK SVN
		ESP 	SWE CHE TUR GBR USA / NORMALIZE=ABSOLUTE MEASURE=MABSDEV;
RUN; 

ods graphics on/width=400 height=800 attrpriority=none;
PROC CLUSTER DATA=SIM2 (DROP=_STATUS_) METHOD=CENTROID;
	ID _INPUT_;
RUN;

ods graphics on/width=800 height=600 attrpriority=none;
PROC SGPLOT DATA=WB dattrmap=cont;
	TITLE "Total Greenhouse Gas Emissions (% change from 1990)";
	WHERE ISO3 IN ('KOR' 'ISR' 'CHL' 'TUR');
	VLINE YEAR/RESPONSE=WVAR12 stat=mean  GROUP=ISO3 attrid=myid;;
	YAXIS LABEL="Total greenhouse gas emissions (% change from 1990)";
	XAXIS GRID VALUES=(1990 TO 2012) LABEL="연도" TYPE=TIME INTERVAL=YEAR; 
	FOOTNOTE J=L "Source : World Bank";
RUN;


