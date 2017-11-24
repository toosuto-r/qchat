\d .plot

/ gnuplot wrapper, plot graph & return
gplt:{[c;i] /c:commands,i:input
  @[system"echo '",sv[`;csv 0:i],"' | gnuplot -e \"",sv[";";c],"\"";0;1_]
 }

/ download csv from Google finance for sym
dcsv:{[s] /s:sym
  a:.Q.hg `$":http://finance.google.com/finance/historical?output=csv&q=",.w.hu string[s];
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

dispfmt:"dpzvutm"!timefmt"duuuuum"

/ dict of tic separation based on time range (seconds)
tic:(!). flip (
    600 3600;       /1  hr range, 10 min tics
    7200 43200;     /12 hr range, 2  hr tics
    14400 86400;    /24 hr range, 4  hr tics
    86400 604800;   /1  wk range, 24 hr tics
    432000 2678400; /1 mth range, 5  dy tics
    2592000 0W      />1 mth range,30 dy tics
 );

/ dict of tic separation based on date range
dtic:(!). flip (
    14400   1;      /1 day, 4 hr tics
    86400   7;      /1 wk,  24 hr tics
    864000  31;     /1 mnth,10 day tics
    2592000 0W      />1mnth, 30 days tics
 );

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

auto:{[t;c;p;z] /t:table,c:cols to plot (x;y),p:plot type (line,boxes etc.),z:y range start from zero
  if[not (11=type c)&(type[t] in 98 99h)&(-11=type p);'`type];  //check types of args
  if[not all c in cols[t];'`cols];                              //ensure columns are present
  t:c#0!t;                                                      //filter to plot columns
  a:base;                                                       //begin with base gnuplot "program"
  if[z;a,:"set yrange [0:",string[max t@c 1],"]"];              //if 1b passed in as z, start y range at zero
  if[s:(10=type first t@c 0)|(f within 20 76)|f:type[t@c 0]=11; //check for sym/enum or string x column
     t:update i:i from t;                                       //add col numbers for x range
     if[p=`boxes;a,:"set xtics 1"];                             //labels on every tic
     a,:"plot '-' using 3:2:xtic(1) with ",string p             //plot command
    ];
  if[16=type t@c 0;t:![t;();0b;(1#c 0)!enlist($;19h;c 0)]];     //if timespan, convert to time
  if[(f:.Q.t[type[t@c 0]]) in key timefmt;                      //check for supported timefmt in first col
     a,:("set xdata time";"set timefmt ",timefmt[f]);           //add timefmt stuff
     a,:("set format x ",dispfmt[f]);                           //set display format to match input
     a,:("set xrange ['",("':'" sv (csv 0: (1#c[0])#t)@/:1+t[c 0]?(min t@c 0;max t@c 0)),"']");  //compute & set xrange
     a,:("set xtics ",string $["d"=f;dtic;tic] binr "i"$"v"$.[-;(max;min)@\:t@c 0])
    ];
  if[(f in "jhi")&p=`boxes;a,:"set xtics 1"];                   //histogram with number x values, label everything
  if[not s;a,:"plot '-' using 1:2 with ",string p];             //plot x=c[0],y=c[1]
  :gplt[a;t];                                                   //plot & return
 }

autokey:{[t;c;p;z] /t:table,c:cols to plot (x;y),p:plot type (line,boxes etc.),z:y range start from zero
  if[not (11=type c)&(type[t] in 98 99h)&(-11=type p);'`type];  //check types of args
  if[not all c in cols[t];'`cols];                              //ensure columns are present
  t:update i:1+i from 0!t;                                      //add col numbers for x range
  p:.plot.auto[t;`i,c[1];p;z];                                  //plot with numbers on x-axis
  p:p,'@[count[p]#enlist"";2+til count a;:;a:"\n" vs .Q.s[(1+til count t@c 0)!t@c 0]]; //join key
  :.[p;(22;til[7],73+til 5);:;" "];                             //remove first & last x axis values
 }

.plot.autocbar:{[t;c;z;k;s] /t:table,c:cols to plot (x;y),z:y range start from zero,k:include key,s:colour list
  if[k;t:update i:1+i from 0!t];        //if using a key, enumerate
  p:auto[t;$[k;`i,c[1];c];`boxes;z];    //plot, using input col or enum col
  n:@[count[t]#enlist 0 0;where 0<t@c 1;:;-1_flip 0 -1 xprev\: where (0<count'[a])&all each "*"='a:trim except[;"-+|"]'[flip -2_p]];                //find vertical lines, use (0 0) for entries of 0
  p:flip {[y;x;z] if[x~0 0;:y];@[y;x[0]+1+til x[1]-x[0]+1;{[z;x]a:ss[x;"[*]"];@[x;a[0]+1+til -1+a[1]-a 0;:;z]}[z]]}/[flip p;n;a:count[t]#.Q.A]; //fill between vertical lines with upper case letter
  p:@[p;til 22;{[a;s;t;x]ssr[;"*";" "]ssr[;"#";"█"](ssr/)[x;a;raze each (count[t]#s),\:"#",\:.plot.pc`default]}[a;s;t]];                        //replace upper case letter with coloured block of corresponding colour
  if[k;
     p:p,'@[count[p]#enlist"";2+til count a;:;a:"\n" vs .Q.s[(1+til count t@c 0)!t@c 0]];   //join key
     p:.[p;(22;til[7],73+til 5);:;" "];                                                     //remove first & last x axis values
    ];
  :@'[;count'[p]-4;:;flip[6#'p] 5].[p;(2 21;6+til 69);:;"-"];          //restore axis lines
 }

pc:,\:[;"m"],/:["\033["] string `default`black`red`green`yellow`blue`purple`cyan`white!0,30+til 8

/ colour point function, takes point char, colour & x:plot
cp0:{[p;c;x]
 :ssr[;p;pc[c],p,pc`default]'[x];
 }

/ colour point project, default * point
cp:cp0["*"];
\d .
