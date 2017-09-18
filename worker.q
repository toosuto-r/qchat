.z.pw:{[u;p]"b"$not count .z.W}

/ update default seed
system"S ",string"j"$.z.T;

/Powered by News API
/default BBC
news_key:first@[read0;`:news_key;""];
src:(),hsym`$"http://newsapi.org/v1/articles?source=",/:@[read0;`:sources.txt;enlist"bbc-news&sortBy=top"],\:"&apiKey=",news_key;

getheadline:{news:.j.k .Q.hg first 1?src;
  neg[.z.w](`worker;`news;raze"(",x,") "," - "sv(),/:"c"$enlist[news`source],first each?[1;news`articles]`title`description`url)}

dictlkup:{
  dictf:{$[2>count t:raze raze .j.k[.Q.hg`$"http://api.pearson.com/v2/dictionaries/entries?headword=",x,"&limit=1"][`results;`senses][0][`definition];"No Results Found";t]};
  :neg[.z.w](`worker;`defino;raze"The definition of ",x," is: ",@[dictf;x;"unable to be retrieved."])
 };

/ last fm analysis
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.req:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

.lfm.filters:("tracks";"artists");
.lfm.periods:("overall";"7day";"1month";"3month";"6month";"12month")!("";"7d ";"1m ";"3m ";"6m ";"12m ");

.lfm.parseMethod:{
  if[not x[`filter]in .lfm.filters;:"user.getrecenttracks"];
  f:"user.gettop",x`filter;
  if[x[`period]in key .lfm.periods;f,:"period=",x`period];
  :f;
 };

.lfm.parse.recenttracks:{[x;y;z;m]
  if[0=count m:m[`recenttracks]`track;:""];                                                     / no recent tracks for user
  r:$[(`$"@attr")in key a:first m;"is listening";"last listened"];                              / determine if song is currently playing
  s:"'",a[`name],"' by ",a[`artist]`$"#text";                                                   / return track details
  :" "sv(z`name;r;"to";s);
 };
.lfm.parse.toptracks:{[x;y;z;m]
  if[0=count m:m[`toptracks]`track;:""];                                                        / no top tracks for user
  s:" by "sv@[;0;{"'",x,"'"}]@[;1;first]first[m]`name`artist;
  :z[`name],"'s top track ",.lfm.periods[z`period],"is ",s;
 };
.lfm.parse.topartists:{[x;y;z;m]
  if[0=count m:m[`topartists]`artist;:""];                                                      / no top tracks for user
  s:first m`name;
  :z[`name],"'s top artist ",.lfm.periods[z`period],"is ",s;
 };

.lfm.nowPlaying:{[x;y;z]                                                                        / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  msg:.lfm.req[.lfm.parseMethod z]y;
  if[not(k:first[key msg])in key .lfm.parse;:()];
  res:.lfm.parse[k][x;y;z;msg];
  if[0=count res;:()];                                                                          / no return on bad request
  :neg[.z.w](`worker;`music;"Hey ",x,", ",res);                                                 / pass message back to server
 };

/ bitcoin
.btc.getprice:{
 if[y=`PLOT;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", BTC price over last month:","\n" sv 1_read0`:/tmp/btc.txt)];
 j:.j.k .Q.hg`$":http://api.coindesk.com/v1/bpi/currentprice.json";
 d:`GBP`USD`EUR!("£";"$";"€");
 :neg[.z.w](`worker;`bitcoin;"Hey ",x,", bitcoin price is currently: ",d[y],j[`bpi][y][`rate]," (",string[y],")");
 }
