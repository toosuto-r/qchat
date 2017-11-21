\d .plot

/ gnuplot wrapper, plot graph & return
gplt:{[c;i] /c:commands,i:input
  @[system"echo '",sv[`;csv 0:i],"' | gnuplot -e \"",sv[";";c],"\"";0;1_]
 }

/ download csv from Google finance for sym
dcsv:{[s] /s:sym
  a:.Q.hg `$":http://finance.google.com/finance/historical?output=csv&q=",string[s];
  if[0<count ss[a;"Error 400"];:()];
  ("DFFFFI";enlist ",")0: 3_a
 }

/ dict of gnuplot timefmts based on kdb datatype
timefmt:"dpzvutm"!
  ("'%Y-%m-%d'";            /d
   "'%Y-%m-%dD%H:%M:%S'";   /p
   "'%Y-%m-%d %H:%M:%S'";   /z
   "'%H:%M:%S'";            /v
   "'%H:%M'";               /u
   "'%H:%M:%S'";            /t
   "'%Y-%m'")               /m

/ gnuplot program
base:("set terminal dumb";
      "set datafile separator ','";
      "set key off");

c:base,("set xdata time";
        "set timefmt ",timefmt["d"];
        "plot '-' using 1:5 with lines");

/ plot close prices for given sym, make red
plt:{[c;s] /c:gnuplot commands,s:sym
  if[()~t:dcsv s;:()];
  ssr[;"*";"\033[31m*\033[0m"] ` sv gplt[c] 31#t
 }[c]

/ stock plot
getplot:{[u;s;h] /u:user,s:sym,h:user handle
  if[()~p:.plot.plt s;:neg[.z.w](`errw;"\033[GError: stock not found";h)];
  :neg[.z.w](`worker;`stock;"Hey ",u,", plot for ",string[s]," over last month:",p)
 }

auto:{[t;c;p] /t:table,c:cols to plot (x;y),p:plot type (line,boxes etc.)
  if[not (11=type c)&(type[t] in 98 99h)&(-11=type p);'`type];  //check types of args
  if[not all c in cols[t];'`cols];                              //ensure columns are present
  t:c#0!t;                                                      //filter to plot columns
  a:base;                                                       //begin with base gnuplot "program"
  if[s:(10=type first t@c 0)|(f within 20 76)|f:type[t@c 0]=11; //check for sym/enum or string x column
     t:update i:i from t;                                       //add col numbers for x range
     a,:"plot '-' using 3:2:xtic(1) with ",string p             //plot command
    ];
  if[(f:.Q.t[type[t@c 0]]) in key timefmt;                      //check for supported timefmt in first col
     a,:("set xdata time";"set timefmt ",timefmt[f])            //add timefmt stuff
    ];
  if[not s;a,:"plot '-' using 1:2 with ",string p];             //plot x=c[0],y=c[1]
  :gplt[a;t];                                                   //plot & return
 }
\d .
