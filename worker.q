.z.pw:{[u;p]"b"$not count .z.W}
\t 1000

/cron
cron:([]time:"p"$();action:`$();args:())

.z.ts:{pi:exec i from cron where time<.z.P;if[count pi;r:exec action,args from cron where i in pi;delete from `cron where i in pi;({value[x]. (),y}.)'[flip value r]];}

/ update default seed
system"S ",string"j"$.z.T;

/ load additional worker code
\l lfm_worker.q
\l plot.q

/Powered by News API
/default BBC
news_key:first@[read0;`:news_key;""];
src:(),hsym`$"http://newsapi.org/v1/articles?source=",/:@[read0;`:sources.txt;enlist"bbc-news&sortBy=top"],\:"&apiKey=",news_key;

getheadline:{news:.j.k .Q.hg first 1?src;
  neg[.z.w](`worker;`news;raze"(",x,") "," - "sv(),/:"c"$enlist[news`source],first each?[1;news`articles]`title`description`url)}

dictlkup:{
  dictf:{$[2>count t:raze raze rand[.j.k[.Q.hg `$"http://api.pearson.com/v2/dictionaries/ldoce5/entries?headword=",x][`results]][`senses][`definition];"No Results Found";t]};
  :neg[.z.w](`worker;`defino;raze"The definition of ",x," is: ",@[dictf;x;"unable to be retrieved."])
 };

/ bitcoin
.btc.getprice:{
 if[y=`PLOT;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", BTC price over last month:","\n" sv 1_read0`:/tmp/btc.txt)];
 j:.j.k .Q.hg`$":http://api.coindesk.com/v1/bpi/currentprice.json";
 d:`GBP`USD`EUR!("£";"$";"€");
 :neg[.z.w](`worker;`bitcoin;"Hey ",x,", bitcoin price is currently: ",d[y],j[`bpi][y][`rate]," (",string[y],")");
 }

topcheck:30
shamethresh:70
toptab:([]pid:"i"%();user:0#`;mem:0#0f;cmd:0#`;time:0#.z.P)
shamed:([]time:0#.z.P;user:`)
gettop:{toptab,:select from 
  (update time:.z.P from `pid`user`mem`cmd xcol
    ("IS       F S";enlist",")0:","sv'{x where 0<count@'x}@'" "vs'6_system"top -bn1 -o \"%MEM\"") where mem>x;
  shame:(key exec avg mem by user from toptab where time>.z.P-"v"$y+5)except raze exec user from shamed where time>.z.P-"v"$900;
  if[count shame;
    neg[key[.z.W]0](`worker;`shame;
      "user:",(","sv string (),shame)," has averaged above ",string[x],"% memory for the last ",string[y],"s");
    `shamed insert (.z.P;first shame);];
  `cron insert (.z.P+"v"$topcheck;`gettop;(shamethresh,topcheck));
  }

`cron insert (.z.P+"v"$topcheck;`gettop;(shamethresh,topcheck));
