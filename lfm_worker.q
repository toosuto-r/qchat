(.lfm.console:{system"c "," "sv string 20 1000|system"c"})[];

/ Last FM bot code
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.httpGet:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

/ variables required to build up messages
.lfm.filters.np:("tracks";"artists")!`toptracks`topartists;                                     / allowed filters
.lfm.periods:("overall";"7day";"1month";"3month";"6month";"12month")!("overall";"7 day";"1 month";"3 month";"6 month";"12 month"); / allowed periods
.lfm.funcs:(`artist`playcount`album,`$"@attr")!(first;"J"$;first;{"true"~last x});              / column functions
.lfm.cols:`topartists`toptracks`recenttracks`tracks_ch`artists_ch`albums_ch!(`name`playcount;`name`artist`playcount;(`name`artist`playcount`album,`$"@attr");`name`artist`playcount;`name`playcount;`name`artist`playcount); / columns for parsing requests

.lfm.request:{[u;l;msg]                                                                         / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  if["chart"~msg`filter;:.lfm.getChart[u;l;msg]];
  res:.lfm.parseMethod[u;l;msg];                                                                / parse inputs
  :neg[.z.w](`worker;`music;raze"Hey @",string[u],", @",string[first key l],res);               / pass message back to server
 };

.lfm.parseMethod:{[u;l;msg]                                                                     / [user;lfm name;msg] parse request methos
  if[not msg[`period]in key .lfm.periods;msg[`period]:"7day"];                                  / set default period
  a:$[msg[`filter]in key .lfm.filters.np;                                                       / determine request params
    (1;"user.gettop",msg[`filter],"&period=",msg`period;.lfm.filters.np msg`filter);
    (1;"user.getrecenttracks";`recenttracks)
  ];
  res:first raze .lfm.httpWrap[a 0;a 1;;;.lfm.cols[a 2]#.lfm.funcs]'[key l;get l];              / http request
  :.lfm.parse[a 2][.lfm.periods msg`period;res];                                                / parse results
 };

.lfm.parse.recenttracks:{[p;m]                                                                  / [period;message] parser for recent tracks
  r:$[m`$"@attr";" is listening";" last listened"];                                             / determine if song is currently playing
  :r," to '",m[`name],"' by ",m[`artist]," from ",m`album;                                      / format message
 };
.lfm.parse.toptracks:{[p;m]                                                                     / [period;message] parser for top tracks
  :"'s ",p," top track is '",m[`name],"' by ",m[`artist]," with ",string[m`playcount]," scrobbles"; / format message
 };
.lfm.parse.topartists:{[p;m]                                                                    / [period;message] parser for top artists
  :"'s ",p," top artist is ",m[`name]," with ",string[m`playcount]," scrobbles";                / format message
 };

.lfm.httpWrap:{[p;r;u;l;c]                                                                      / [limit;request;user;lfm name;cols+funcs]
  q:$[p=0W;("";1b);("&limit=",string p;0b)];                                                    / limit results if necessary
  res:first{[q;p;x;y;z]                                                                         / loop over pages to get all results
    if[p<=count z 0;:@[z;0;sublist[p]]];                                                        / exit early if limit is reached, ensures limit is definitely kept
    r:.lfm.httpGet[x,q[0],"&page=",string z 1;y];                                               / api request
    if[0=count l:first raze r;:z];                                                              / exit early if no results
    z[0]:distinct z[0],{@/[;x;y]x#z}[z 2;z 3]'[l];                                              / update results
    :@[z;1;+;q 1];                                                                              / increment page number
  }[q;p;r;l]/[(();1;key c;get c)];
  if[98=type res;:update users:u from res];                                                     / add username
  :res;
 };

.lfm.filters.chart:`tracks`artists`albums!`tracks_ch`artists_ch`albums_ch;                      / allowed filtersi
.lfm.chart.artists:{`artist`scrobbles xcol x};                                                  / get counts by artists
.lfm.chart.tracks:{`name`artist`scrobbles xcol @[x;`name;trim 50$]};                            / get counts by tracks
.lfm.chart.albums:{`album`scrobbles xcol x};                                                    / get counts by albums
.lfm.getChart:{[u;l;msg]
  if[not msg[`c]in key .lfm.filters.chart;msg[`c]:`tracks];                                     / default to tracks
  res:`playcount xdesc raze .lfm.httpWrap[5;"user.getweekly",(-1_string msg`c),"chart";;;.lfm.cols[.lfm.filters.chart msg`c]#.lfm.funcs]'[key l;get l]; / http request
  if[0=count res;:()];                                                                          / no return for empty chart
  e:$[1=count k:key l;"for @",string[first k]," ";""];                                          / name of requested user
  res:update("@",'string users)from res;                                                        / allow colours
  res:`no xcols update no:1+i from 5 sublist .lfm.chart[msg`c]res;                              / return top 5
  :neg[.z.w](`worker;`music;ssr[;"\n";"\n  "]$[`~u;"T";"Hey @",string[u],", t"],"he current chart ",e,"is:\n",.Q.s@[res;cols[res]where any"C "=\:exec t from meta res;`$]); / pass message back to server
 };
