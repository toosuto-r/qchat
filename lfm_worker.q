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
  res:first raze .lfm.httpLimit[a 0;a 1;;;.lfm.cols[a 2]#.lfm.funcs]'[key l;get l];             / http request
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

.lfm.httpLimit:{[p;r;u;l;c]                                                                     / [limit;request;user;lfm name;cols+funcs]
  q:$[p=0W;"";"&limit=",string p];                                                              / limit results if necessary
  res:{[q;r;l;c]                                                                                / loop over pages to get all results
    if[0=count d:first raze .lfm.httpGet[r,q;l];:()];                                           / return empty list if no results
    :({@/[;x;y]x#z}.(key c;get c))'[d];                                                         / apply column functions
  }[q;r;l;c];
  if[98=type res;:update users:u from res];                                                     / add username
  :res;
 };

.lfm.filters.chart:`tracks`artists`albums!`tracks_ch`artists_ch`albums_ch;                      / allowed filters
.lfm.chart.tracks:{select scrobbles:sum playcount,distinct users by track:name,artist from @[x;`name;trim 50$]}; / get counts by tracks
.lfm.chart.artists:{select scrobbles:playcount,distinct users by artist:name from x};           / get counts by artists
.lfm.chart.albums:{select scrobbles:sum playcount,distinct users by album:name,artist from @[x;`name;trim 50$]}; / get counts by albums
.lfm.getChart:{[u;l;msg]
  if[not msg[`c]in key .lfm.filters.chart;msg[`c]:`tracks];                                     / default to tracks
  e:$[1=count k:key l;("for @",string[first k]," ";5);("";0W)];                                 / name of requested user
  lbl:-1_string msg`c;
  res:raze .lfm.httpLimit[e 1;"user.getweekly",lbl,"chart";;;.lfm.cols[.lfm.filters.chart msg`c]#.lfm.funcs]'[key l;get l]; / http request
  if[0=count res;:()];                                                                          / no return for empty chart
  res:update("@",'string users)from res;                                                        / allow colours
  res:`no xcols update no:fills?[differ scrobbles;1+i;0N]from 5 sublist`scrobbles xdesc 0!.lfm.chart[msg`c]res;   / collate results and return top 5
  :neg[.z.w](`worker;`music;ssr[;"\n";"\n  "]$[`~u;"T";"Hey @",string[u],", t"],"he current ",lbl," chart ",e[0],"is:\n",.Q.s@[res;cols[res]where any"C "=\:exec t from meta res;`$]); / pass message back to server
 };
