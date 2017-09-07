%macro utl_submit_r64(
      pgmx
     ,returnVar=N           /* set to Y if you want a return SAS macro variable from python */
     ,returnVarName=fromPy  /* name for the macro variable from Python */
     )/des="Semi colon separated set of R commands - drop down to R";
  * write the program to a temporary file;
  filename r_pgm "d:/txt/r_pgm.txt" lrecl=32766 recfm=v;
  data _null_;
    length pgm $32756;
    file r_pgm;
    pgm=&pgmx;
    put pgm;
    putlog pgm;
  run;
  %let __loc=%sysfunc(pathname(r_pgm));
  * pipe file through R;
  filename rut pipe "c:\Progra~1\R\R-3.3.2\bin\x64\R.exe --vanilla --quiet --no-save < &__loc";
  data _null_;
    file print;
    infile rut recfm=v lrecl=32756;
    input;
    put _infile_;
    putlog _infile_;
  run;
  filename rut clear;
  filename r_pgm clear;

  * use the clipboard to create macro variable;
  %if %upcase(%substr(&returnVar.,1,1))=Y %then %do;
    filename clp clipbrd ;
    data _null_;
     length txt $200;
     infile clp;
     input;
     putlog "*******  " _infile_;
     call symputx("&returnVarName.",_infile_,"G");
    run;quit;
  %end;

%mend utl_submit_r64;


Example of new submit R: Evaluate a equation and send the result back to SAS in a macro variable

see documentation on how to use the R interface at the end of this message.

 Macro utl_submit_r64 now returns a 'R' macro variable back into parent SAS.
 Should work for mutiple operating systems.

   WORKING CODE
   ============

     SAS load clipboard with 'x**2 - 4'

       filename clp clipbrd ;
       data _null_;
        file clp;
        equ='x**2 - 4';
        put equ;

     R (read clipboard equation evaluate equation at x=4
        put the result in macro variable fromR

       %utl_submit_r64(resolve('
       str<-readClipboard();
       x=4;
       fx<-eval(parse(text=str));
       strfx<-as.character(fx);
       fof4<-paste("f(4) =",strfx);
       writeClipboard(fof4);
       ')
      ,returnVar=Y
      ,returnVarName=fromR
       );

       %put &=fromR;

 HAVE

    'x**2 - 4' in windows clipboard


 WANT

    Evaluate x**2 - 4 at x=4

    This will be in the log and in macro variable fromR

    FROMR=f(4) = 12

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

%symdel fromPy returnVar returnVarName / nowarn; * just in case;

* clear the paste buffer - clipboard;
data _null_;
  call system('cmd /c "echo off | clip"');
run;quit;

* load equ into clipboard;
filename clp clipbrd ;
data _null_;
 file clp;
 equ='x**2 - 4';
 put equ;
run;quit;


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;


 %utl_submit_r64(resolve('
 str<-readClipboard();
 x=4;
 fx<-eval(parse(text=str));
 strfx<-as.character(fx);
 fof4<-paste("f(4) =",strfx);
 writeClipboard(fof4);
 ')
 ,returnVar=Y
 ,returnVarName=fromR
 );

 %put &=fromR;


LOG

MLOGIC(UTL_SUBMIT_R64):  Beginning execution.
4309   str<-readClipboard();
4310   x=4;
4311   fx<-eval(parse(text=str));
4312   strfx<-as.character(fx);
4313   fof4<-paste("f(4) =",strfx);
4314   writeClipboard(fof4);
4315   ')
4316   ,returnVar=Y
4317   ,returnVarName=fromR
4318   );
MLOGIC(UTL_SUBMIT_R64):  Parameter PGMX has value resolve(' str<-readClipboard();
x=4; fx<-eval(parse(text=str)); strfx<-as.character(fx); fof4<-paste("f(4) =",strfx);
      writeClipboard(fof4); ')
MLOGIC(UTL_SUBMIT_R64):  Parameter RETURNVAR has value Y
MLOGIC(UTL_SUBMIT_R64):  Parameter RETURNVARNAME has value fromR
MPRINT(UTL_SUBMIT_R64):   * write the program to a temporary file;
MPRINT(UTL_SUBMIT_R64):   filename r_pgm "d:/txt/r_pgm.txt" lrecl=32766 recfm=v;
MPRINT(UTL_SUBMIT_R64):   data _null_;
MPRINT(UTL_SUBMIT_R64):   length pgm $32756;
MPRINT(UTL_SUBMIT_R64):   file r_pgm;
SYMBOLGEN:  Macro variable PGMX resolves to resolve(' str<-readClipboard(); x=4;
fx<-eval(parse(text=str)); strfx<-as.character(fx); fof4<-paste("f(4) =",strfx);
            writeClipboard(fof4); ')
MPRINT(UTL_SUBMIT_R64):   pgm=resolve(' str<-readClipboard(); x=4;
fx<-eval(parse(text=str)); strfx<-as.character(fx); fof4<-paste("f(4) =",strfx);
writeClipboard(fof4);
');
MPRINT(UTL_SUBMIT_R64):   put pgm;
MPRINT(UTL_SUBMIT_R64):   putlog pgm;
MPRINT(UTL_SUBMIT_R64):   run;

NOTE: The file R_PGM is:
      Filename=d:\txt\r_pgm.txt,
      RECFM=V,LRECL=32766,File Size (bytes)=0,
      Last Modified=07Sep2017:16:39:47,
      Create Time=04Jul2017:13:44:29

str<-readClipboard(); x=4; fx<-eval(parse(text=str)); strfx<-as.character(fx);
fof4<-paste("f(4) =",strfx); writeClipboard(fof4);
NOTE: 1 record was written to the file R_PGM.
      The minimum record length was 129.
      The maximum record length was 129.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      user cpu time       0.00 seconds
      system cpu time     0.00 seconds
      memory              337.78k
      OS Memory           15340.00k
      Timestamp           09/07/2017 04:39:47 PM
      Step Count                        650  Switch Count  0


MLOGIC(UTL_SUBMIT_R64):  %LET (variable name is __LOC)
MPRINT(UTL_SUBMIT_R64):   * pipe file through R;
SYMBOLGEN:  Macro variable __LOC resolves to d:\txt\r_pgm.txt
MPRINT(UTL_SUBMIT_R64):   filename rut pipe
"c:\Progra~1\R\R-3.3.2\bin\x64\R.exe --vanilla --quiet --no-save < d:\txt\r_pgm.txt";
MPRINT(UTL_SUBMIT_R64):   data _null_;
MPRINT(UTL_SUBMIT_R64):   file print;
MPRINT(UTL_SUBMIT_R64):   infile rut recfm=v lrecl=32756;
MPRINT(UTL_SUBMIT_R64):   input;
MPRINT(UTL_SUBMIT_R64):   put _infile_;
MPRINT(UTL_SUBMIT_R64):   putlog _infile_;
MPRINT(UTL_SUBMIT_R64):   run;

NOTE: The infile RUT is:
      Unnamed Pipe Access Device,
      PROCESS=c:\Progra~1\R\R-3.3.2\bin\x64\R.exe --vanilla --quiet --no-save
< d:\txt\r_pgm.txt,
      RECFM=V,LRECL=32756

> str<-readClipboard(); x=4; fx<-eval(parse(text=str)); strfx<-as.character(fx);
fof4<-paste("f(4) =",strfx); writeClipboard(fof4);
NOTE: 1 lines were written to file PRINT.
Stderr output:
Error in f(4) = 12 : target of assignment expands to non-language object
Calls: eval -> eval
Execution halted
NOTE: 1 record was read from the infile RUT.
      The minimum record length was 131.
      The maximum record length was 131.
NOTE: DATA statement used (Total process time):
      real time           0.43 seconds
      user cpu time       0.00 seconds
      system cpu time     0.04 seconds
      memory              261.09k
      OS Memory           15340.00k
      Timestamp           09/07/2017 04:39:47 PM
      Step Count                        651  Switch Count  0


MPRINT(UTL_SUBMIT_R64):   filename rut clear;
NOTE: Fileref RUT has been deassigned.
MPRINT(UTL_SUBMIT_R64):   filename r_pgm clear;
NOTE: Fileref R_PGM has been deassigned.
MPRINT(UTL_SUBMIT_R64):   * use the clipboard to create macro variable;
SYMBOLGEN:  Macro variable RETURNVAR resolves to Y
MLOGIC(UTL_SUBMIT_R64):  %IF condition %upcase(%substr(&returnVar.,1,1))=Y is TRUE
MPRINT(UTL_SUBMIT_R64):   filename clp clipbrd ;
MPRINT(UTL_SUBMIT_R64):   data _null_;
MPRINT(UTL_SUBMIT_R64):   length txt $200;
MPRINT(UTL_SUBMIT_R64):   infile clp;
MPRINT(UTL_SUBMIT_R64):   input;
MPRINT(UTL_SUBMIT_R64):   putlog "*******  " _infile_;
SYMBOLGEN:  Macro variable RETURNVARNAME resolves to fromR
MPRINT(UTL_SUBMIT_R64):   call symputx("fromR",_infile_,"G");
MPRINT(UTL_SUBMIT_R64):   run;

NOTE: Variable TXT is uninitialized.
NOTE: The infile CLP is:
      (no system-specific pathname available),
      (no system-specific file attributes available)

*******  f(4) = 12
NOTE: 1 record was read from the infile CLP.
      The minimum record length was 9.
      The maximum record length was 9.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      user cpu time       0.01 seconds
      system cpu time     0.01 seconds
      memory              265.43k
      OS Memory           15340.00k
      Timestamp           09/07/2017 04:39:47 PM
      Step Count                        652  Switch Count  0


MPRINT(UTL_SUBMIT_R64):  quit;
MLOGIC(UTL_SUBMIT_R64):  Ending execution.
SYMBOLGEN:  Macro variable FROMR resolves to f(4) = 12
4319   %put &=fromR;
FROMR=f(4) = 12



