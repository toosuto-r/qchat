(.lfm.console:{system"c "," "sv string 20 1000|system"c"})[];

/ Last FM bot code
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.httpGet:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

/ variables required to build up messages
.lfm.filters:`tracks`artists`albums;                                                            / allowed filters
.lfm.periods:`overall`7day`1month`3month`6month`12month!("overall";"7 day";"1 month";"3 month";"6 month";"12 month"); / allowed periods
.lfm.funcs:(`artist`playcount`album,`$"@attr")!(first;"J"$;first;{"true"~last x});              / column functions
.lfm.cols:`artists`tracks`albums`recenttracks`getInfo!(`name`playcount;`name`artist`playcount;`name`artist`playcount;(`name`artist`playcount`album,`$"@attr");(),`playcount); / columns for parsing requests

.lfm.http.table:{[p;r;u;l;c]                                                                    / [limit;request;user;lfm name;cols+funcs]
  r,:$[p=0W;"";"&limit=",string p];                                                             / limit results if necessary
  if[0=count d:first raze .lfm.httpGet[r;l];:()];                                               / return empty list if no results
  res:{@/[;x;y]x#z}[key c;get c]'[d];                                                           / apply column functions
  if[98=type res;:update users:u from res];                                              / add username
  :res;
 };

.lfm.http.dict:{[p;r;u;l;c]                                                                     / [limit;request;user;lfm name;cols+funcs]
  if[0=count d:raze .lfm.httpGet[r;l];:()];                                                     / return empty list if no results
  res:{@/[;x;y]x#z}[key c;get c;d];                                                             / apply column functions
  if[type[res]in 98 99h;:update users:u from res];                                              / add username
  :res;
 };

.lfm.request:{[u;l;msg]                                                                         / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  if[`chart=msg`filter;:.lfm.getChart[u;l;msg]];                                                / use chart specific method
  res:.lfm.parseMethod[u;l;msg];                                                                / parse inputs
  :neg[.z.w](`worker;`music;raze"Hey @",string[u],", @",string[first key l],res);               / pass message back to server
 };

.lfm.parseMethod:{[u;l;msg]                                                                     / [user;lfm name;msg] parse request methos
  if[not msg[`period]in key .lfm.periods;msg[`period]:`7day];                                   / set default period
  a:$[msg[`filter]in .lfm.filters;                                                              / determine request params
    ("user.gettop",string[msg`filter],"&period=",string msg`period;msg`filter;`table);
    `scrobbles=msg`filter;
      ("user.getinfo";`getInfo;`dict);
      ("user.getrecenttracks";`recenttracks;`table)
  ];
  res:first raze .lfm.http[a 2][1;a 0;;;.lfm.cols[a 1]#.lfm.funcs]'[key l;get l];                     / http request
  :.lfm.parse[a 1][.lfm.periods msg`period;res];                                                / parse results
 };

.lfm.getChart:{[u;l;msg]
  if[not msg[`c]in .lfm.filters;msg[`c]:`tracks];                                               / default to tracks
  e:$[1=count k:key l;("for @",string[first k]," ";5);("";0W)];                                 / name of requested user
  lbl:-1_string msg`c;
  res:raze .lfm.http.table[e 1;"user.getweekly",lbl,"chart";;;.lfm.cols[msg`c]#.lfm.funcs]'[key l;get l]; / http request
  if[0=count res;:()];                                                                          / no return for empty chart
  res:update("@",'string users)from res;                                                        / allow colours
  res:`no xcols update no:fills?[differ scrobbles;1+i;0N]from 5 sublist`scrobbles xdesc 0!.lfm.chart[msg`c]res;   / collate results and return top 5
  :neg[.z.w](`worker;`music;ssr[;"\n";"\n  "]$[`~u;"T";"Hey @",string[u],", t"],"he current ",lbl," chart ",e[0],"is:\n",.Q.s@[res;cols[res]where any"C "=\:exec t from meta res;`$]); / pass message back to server
 };

.lfm.parse.recenttracks:{[p;m]                                                                  / [period;message] parser for recent tracks
  r:$[m`$"@attr";" is listening";" last listened"];                                             / determine if song is currently playing
  :r," to '",m[`name],"' by ",m[`artist]," from ",m`album;                                      / format message
 };
.lfm.parse.tracks:{[p;m]                                                                        / [period;message] parser for top tracks
  :"'s ",p," top track is '",m[`name],"' by ",m[`artist]," with ",string[m`playcount]," scrobbles"; / format message
 };
.lfm.parse.artists:{[p;m]                                                                       / [period;message] parser for top artists
  :"'s ",p," top artist is ",m[`name]," with ",string[m`playcount]," scrobbles";                / format message
 };
.lfm.parse.albums:{[p;m]                                                                        / [period;message] parser for top albums
  :"'s ",p," top album is '",m[`name],"' by ",m[`artist]," with ",string[m`playcount]," scrobbles"; / format message
 };
.lfm.parse.getInfo:{[p;m]
  :" has ",string[m]," scrobbles";
 };

.lfm.chart.tracks:{select scrobbles:sum playcount,distinct users by track:name,artist from @[x;`name;trim 50$]}; / get counts by tracks
.lfm.chart.artists:{select scrobbles:playcount,distinct users by artist:name from x};           / get counts by artists
.lfm.chart.albums:{select scrobbles:sum playcount,distinct users by album:name,artist from @[x;`name;trim 50$]}; / get counts by albums
