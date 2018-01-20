
.z.pw:{[u;p]"b"$not count .z.W};
\t 1000

/cron
cron:([]time:"p"$();action:`$();args:());
qid:{$[99h=type x;.Q.id'[key x]!get x;.Q.id x]};                                                / purge bad chars

.z.ts:{pi:exec i from cron where time<.z.P;if[count pi;r:exec action,args from cron where i in pi;delete from `cron where i in pi;({value[x]. (),y}.)'[flip value r]];};

/ update default seed
system"S ",string"j"$.z.T;

/ load additional worker code
\l lfm_worker.q
\l plot.q
\l stock.q
\l aoc.q
\l so.q

cfg:1!("SS";(),",")0:`:config.csv    

/Powered by News API
/default BBC
news_key:first@[read0;`:news_key;""];
src:(),hsym`$"http://newsapi.org/v1/articles?source=",/:@[read0;`:sources.txt;enlist"bbc-news&sortBy=top"],\:"&apiKey=",news_key;

getheadline:{news:.j.k .Q.hg first 1?src;
  neg[.z.w](`worker;`news;raze"(",x,") "," - "sv(),/:"c"$enlist[news`source],first each?[1;news`articles]`title`description`url)}

dictlkup:{
  dictf:{$[2>count t:@[rand[.j.k[.Q.hg `$"http://api.pearson.com/v2/dictionaries/ldoce5/entries?headword=",x][`results]][`headword`senses];1;{raze raze x`definition}];"No Results Found";t]};
  :neg[.z.w](`worker;`defino;raze"The definition of ",x[0]," is: ",(x:@[dictf;x;(x;"unable to be retrieved.")])1)
 };

udlkup:{
  d:.j.k .Q.hg`$":http://api.urbandictionary.com/v0/define?term=",x;
  d:$["no_results"~d`result_type;"not found";rand d[`list;where s>0.25*max[s:sum d[`list;`thumbs_up`thumbs_down]];`definition]];
  :neg[.z.w](`worker;`urbd;raze"The definition of ",x," is: ",d)
 };

.w.hu1:@[("%00";"%01";"%02";"%03";"%04";"%05";"%06";"%07";"%08";"%09";"%0a";"%0b";"%0c";"%0d";"%0e";"%0f";"%10";"%11";"%12";"%13";"%14";"%15";"%16";"%17";"%18";"%19";"%1a";"%1b";"%1c";"%1d";"%1e";"%1f";"%20";"!";"%22";"%23";"$";"%25";"%26";"%27";"%28";"%29";"%2A";"%2B";"%2C";"-";".";"%2f";"0";"1";"2";"3";"4";"5";"6";"7";"8";"9";"%3a";"%3b";"%3c";"%3d";"%3e";"%3f";"%40";"A";"B";"C";"D";"E";"F";"G";"H";"I";"J";"K";"L";"M";"N";"O";"P";"Q";"R";"S";"T";"U";"V";"W";"X";"Y";"Z";"%5b";"%5c";"%5d";"%5e";"_";"%60";"a";"b";"c";"d";"e";"f";"g";"h";"i";"j";"k";"l";"m";"n";"o";"p";"q";"r";"s";"t";"u";"v";"w";"x";"y";"z";"%7b";"%7c";"%7d";"%7e";"%7f";"%80";"%81";"%82";"%83";"%84";"%85";"%86";"%87";"%88";"%89";"%8a";"%8b";"%8c";"%8d";"%8e";"%8f";"%90";"%91";"%92";"%93";"%94";"%95";"%96";"%97";"%98";"%99";"%9a";"%9b";"%9c";"%9d";"%9e";"%9f";"%a0";"%a1";"%a2";"%a3";"%a4";"%a5";"%a6";"%a7";"%a8";"%a9";"%aa";"%ab";"%ac";"%ad";"%ae";"%af";"%b0";"%b1";"%b2";"%b3";"%b4";"%b5";"%b6";"%b7";"%b8";"%b9";"%ba";"%bb";"%bc";"%bd";"%be";"%bf";"%c0";"%c1";"%c2";"%c3";"%c4";"%c5";"%c6";"%c7";"%c8";"%c9";"%ca";"%cb";"%cc";"%cd";"%ce";"%cf";"%d0";"%d1";"%d2";"%d3";"%d4";"%d5";"%d6";"%d7";"%d8";"%d9";"%da";"%db";"%dc";"%dd";"%de";"%df";"%e0";"%e1";"%e2";"%e3";"%e4";"%e5";"%e6";"%e7";"%e8";"%e9";"%ea";"%eb";"%ec";"%ed";"%ee";"%ef";"%f0";"%f1";"%f2";"%f3";"%f4";"%f5";"%f6";"%f7";"%f8";"%f9";"%fa";"%fb";"%fc";"%fd";"%fe";"%ff")]
.w.hu:{raze .w.hu1 x}

wikilkup:{
  q:.w.hu x;
  w:.j.k .Q.hg`$":https://en.wikipedia.org/w/api.php?action=query&titles=",q,"&prop=revisions&rvprop=content&format=json";
  if[$[`;"-1"] in key w[`query][`pages];:neg[.z.w](`worker;`wiki;"No wiki entry found for ",x)];
  a:ssr[;;"}"]/[;("}}";"-->")]ssr[;;"{"]/[raze (first w[`query][`pages])[`revisions][`$"*"];("{{";"<!--")];
  if["#REDIRECT"~upper 9#a;
     :.z.s a b+til first ss[a;"[]]]"]-b:1+last ss[a;"[[[]"]];
  a@:where not {x or (<>)scan x} a in "{}";
  a@:where not {x or (<>)scan x} a in "()";
  c:ss[a]'[("'''";".")];
  c:@[c;0;first];
  c:@[c;1;{y^first z where z>x}[c 0;count a]];
  d:except[;"'[]\n"] a c[0]+til 1+c[1]-c[0];
  :neg[.z.w](`worker;`wiki;d)
 };

word:{[t;x]
 j:@[.j.k;.Q.hg`$"http://words.bighugelabs.com/api/2/f4c57c19c2c2f0f1021c3c145959ef40/",x,"/json";enlist[`]!enlist enlist[`]!enlist`];
 a:"\n" sv {$[y in key a:x@z;string[z],": ",", " sv 5 sublist a@y;""]}[j;t]'[key j];
 r:$[""~a except "\n";"No ",string[t],"onyms found for ",x;string[t],"onyms for ",x," by category:\n",a];
 :neg[.z.w](`worker;t;r);
 }

anty:word[`ant]
syny:word[`syn]

rhym:{
 j:@[.j.k;.Q.hg`$"https://api.datamuse.com/words?rel_rhy=",x;flip `word`score`numSyllables!()];
 r:$[0=count j;
     "No rhymes found for ",x;
     "Rhymes for ",x,": ",", " sv 5 sublist j[;`word]];
 :neg[.z.w](`worker;`rhym;r);
 }
/ bitcoin

.btc.getprice:{
 sym:"BTCUSD"; //symbol for insertion into query strings
 if[(y=`PLOT)&($[`;z] in `0`month);:neg[.z.w](`worker;`bitcoin;"Hey ",x,", BTC price over last month:","\n" sv
             .plot.cp[`red] .plot.auto[;`date`close;`line;0b]
             flip `date`close!({"D"$string key x};get)@\:(.j.k .Q.hg`:https://api.coindesk.com/v1/bpi/historical/close.json)`bpi)];
 if[(y=`PLOT)&$[`;lower z] in `btc`today;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", BTC price over today:","\n" sv
             .plot.cp[`red] .plot.auto[;`time`spot;`line;0b]`::1234"b 20*til floor count[b:select from btc where sym=`",sym,"]%20")];
 if[(y=`PLOT)&$[`;lower z]=`eth;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", ETH price over today:","\n" sv
             .plot.cp[`red] .plot.auto[;`time`spot;`line;0b]`::1234"b 20*til floor count[b:select from btc where sym=`ETHUSD]%20")];
 if[(y=`PLOT)&$[`;lower z]=`bch;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", BCH price over today:","\n" sv
             .plot.cp[`red] .plot.auto[;`time`spot;`line;0b]`::1234"b 20*til floor count[b:select from btc where sym=`BCHUSD]%20")];
 if[(y=`PLOT)&$[`;z]=`yday;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", BTC price over yesterday:","\n" sv
             .plot.cp[`red] .plot.auto[;`time`spot;`line;0b]`::5012"b@20*til floor count[b:select from btc where date=last date,sym=`",sym,"]%20")];
 if[(y=`PLOT)&$[`;z]=`mcap;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", market cap in USD for top 5 cryptocoins:","\n" sv
             .plot.autocbar[;`name`market_cap_usd;0b;1b;value .plot.pc] @[;`market_cap_usd;"F"$].j.k .Q.hg`$"https://api.coinmarketcap.com/v1/ticker/?limit=5")];
 j:c!(.j.k .Q.hg`$":https://api.coinbase.com/v2/exchange-rates?currency=BTC")[`data][`rates]c:`GBP`USD`EUR;
 d:`GBP`USD`EUR!("£";"$";"€");
 if[y<>`KFC;m:"Hey ",x,", bitcoin price is currently: ",d[y],j[y]," (",string[y],")"];
 if[(y<>`KFC) & $["F";z]<>0;m,:" and your holding is worth: ",d[y],string $["F";z]*"F"$j[y]];
 if[y=`KFC;z:$[0<>"F"$z;"F"$z;1f];m:"Hey ",x,", with ",string[z]," BTC you can currently buy this many bargain buckets:\n",
              -1_.Q.s `6pc`10pc`14pc!`${string[x 0]," (",string[x 1]," pieces)"}'[(1 6;1 10;1 14)*\:'floor z*$["F";j`GBP]%10.49 13.49 16.49]];
 :neg[.z.w](`worker;`bitcoin;m);
 }

strm:{
 rq:"GET /lookup?country=uk&term=",.w.hu[x]," http/1.0\r\n",
    "X-Mashape-Key: ZcDyNcEqBTmshqEcRa21k5UjoukWp1w6WNSjsn2oOehFjAHN05\r\n",
    "Accept: application/json\r\n",
    "host:utelly-tv-shows-and-movies-availability-v1.p.mashape.com\r\n\r\n";
 j:.j.k {(first ss[x;"{"])_x} (`$":https://utelly-tv-shows-and-movies-availability-v1.p.mashape.com") rq;
 r:"Matches found on streaming services for '",x,"'\n";
 r,:"\n" sv {"Locations for '",x[`name],"': ",", " sv raze value {x where c=min c:count'[x]} each a@group 5#'a:exec display_name from x[`locations]}'[j`results];
 :neg[.z.w](`worker;`stream;r);
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

getSimpsons:{`:simpsons.csv 0:("\n"vs .Q.hg`$"https://raw.githubusercontent.com/vibronicshark55/simpsons_quotes/master/quotes.csv")except enlist"";} / http request for quotes, save result to disk

simp:{[h;u]                                                                                     / [handle;user]
  if[0=count@[value;`simpsonsQuotes;""];                                                        / if no quotes then download from internet
    if[()~key`:simpsons.csv;getSimpsons[]];                                                     / download quotes if none exist on disk
    simpsonsQuotes::neg[count a]?a:@[("**JJ";1#",")0:;`:simpsons.csv;([]quote:"";character:"";season:"j"$();episode:"j"$())]; / parse results and randomise
  ];
  if[0=count simpsonsQuotes;:neg[.z.w](`errw;"\033[GError: no Simpsons quotes";h)];             / exit with error if no quotes on disk
  r:first simpsonsQuotes;                                                                       / get first quote from memory
  @[`.;`simpsonsQuotes;1_];                                                                     / drop first quote from memory
  msg:" "sv raze each("@",string u;"-";"\"",r[`quote],"\"";"-";r`character);                    / create message
  if[not null r`season;msg,:", s"," e"sv"0"^-2$string r`season`episode];                        / append season data if available
  :neg[.z.w](`worker;`simp;msg);                                                                / return message to chat
 };

clng:{[h;u;ul;cul]
  if[not `challengehub in key cfg;:neg[.z.w](`errw;"\033[GError: no challenge hub available";h)];
  lb:get ` sv hsym[cfg[`challengehub;`val]],`cmp;
  head:enlist["hey ",u,", the challenge hub leaderboard for active qchat members is:"];
  nums:neg[11+c]$raze each string c#'10 vs til 11|c:count first lb;
  body:$[22;(ul!cul)nn],'raze each (".";"\033[33;1m*\033[0m")lb nn:key[desc lb] inter ul;
  msg:"\n "sv head,nums,body;
  :neg[.z.w](`worker;`clng;msg);
  }

