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
  dictf:{$[2>count t:raze raze .j.k[.Q.hg `$"http://api.pearson.com/v2/dictionaries/ldoce5/entries?headword=",x,"&limit=1"][`results][`senses][0][`definition];"No Results Found";t]};
  :neg[.z.w](`worker;`defino;raze"The definition of ",x," is: ",@[dictf;x;"unable to be retrieved."])
 };

/ last fm analysis
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.httpGet:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

.lfm.filters:("tracks";"artists");                                                              / allowed filters
.lfm.periods:enlist["overall"]!enlist"";
.lfm.periods:("7day";"1month";"3month";"6month";"12month")!"over last ",/:("7 days ";"1 month ";"3 months ";"6 months ";"12 months "); / allowed periods

.lfm.parseMethod:{                                                                              / parse request methos
  if[not x[`filter]in .lfm.filters;:"user.getrecenttracks"];                                    / default to recent tracks
  f:"user.gettop",x`filter;
  if[x[`period]in key .lfm.periods;f,:"&period=",x`period];                                     / add period if available
  :f;
 };

.lfm.parse.recenttracks:{[x;y;z;m]                                                              / parser for recent tracks
  if[0=count m:m[`recenttracks]`track;:""];                                                     / exit if no recent tracks for user
  r:$[(`$"@attr")in key a:first m;"is listening";"last listened"];                              / determine if song is currently playing
  :" "sv(z`name;r;"to";"'",a[`name],"'";"by";a[`artist]`$"#text");                              / format message
 };
.lfm.parse.toptracks:{[x;y;z;m]                                                                 / parser for top tracks
  if[0=count m:m[`toptracks]`track;:""];                                                        / exit if no top tracks for user
  s:" by "sv@[;0;{"'",x,"'"}]@[;1;first]first[m]`name`artist;
  :z[`name],"'s top track ",.lfm.periods[z`period],"is ",s;                                     / format message
 };
.lfm.parse.topartists:{[x;y;z;m]                                                                / parser for top artists
  if[0=count m:m[`topartists]`artist;:""];                                                      / exit if no top artists for user
  :z[`name],"'s top artist ",.lfm.periods[z`period],"is ",first m`name;                         / format message
 };

.lfm.request:{[x;y;z]                                                                           / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  msg:.lfm.httpGet[.lfm.parseMethod z]y;                                                        / make request to last fm
  if[not(k:first[key msg])in key .lfm.parse;:()];                                               / exit if improper message returned
  res:.lfm.parse[k][x;y;z;msg];                                                                 / parse returned message
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
