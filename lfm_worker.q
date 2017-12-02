(.lfm.console:{system"c "," "sv string 20 1000|system"c"})[];

/ Last FM bot code
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.httpGet:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

/ variables required to build up messages
.lfm.filters:`tracks`artists`albums;                                                            / allowed filters
.lfm.periods:`overall`7day`1month`3month`6month`12month!("overall";"7 day";"1 month";"3 month";"6 month";"12 month"); / allowed periods
.lfm.funcs:(`artist`playcount`album`attr)!(first;"J"$;first;{"true"~last x});                   / column functions
.lfm.cols:`artists`tracks`albums`recenttracks`getInfo!(`name`playcount;`name`artist`playcount;`name`artist`playcount;(`name`artist`playcount`album`attr);(),`playcount); / columns for parsing requests

.lfm.httpLimit:{[p;r;c;u;l]                                                                     / [limit;request;cols+funcs;user;lfm name]
  r,:$[p=0W;"";"&limit=",string p];                                                             / limit results if necessary
  d:qid raze .lfm.httpGet[r;l];                                                                 / http request
  d:$[m:`attr in key d;first;(::)]d;                                                            / determine method
  if[0=count d;:()];                                                                            / return empty list if no results
  res:{@/[;x;y]x#qid z}[key c;get c]'[$[m;(::);enlist]d];                                       / apply column functions
  :update users:u from res;                                                                     / add username and return
 };

.lfm.request:{[u;l;msg]                                                                         / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  if[`chart=msg`filter;:.lfm.getChart[u;l;msg]];                                                / use chart specific method
  res:.lfm.parseMethod[u;l;msg];                                                                / parse inputs
  :neg[.z.w](`worker;`music;raze"Hey @",string[u],", ",res);                                    / pass message back to server
 };

.lfm.parseMethod:{[u;l;msg]                                                                     / [user;lfm name;msg] parse request methos
  if[not msg[`period]in key .lfm.periods;msg[`period]:`7day];                                   / set default period
  a:`h`m`f!$[msg[`filter]in .lfm.filters;                                                       / determine request params
    ("user.gettop",string[msg`filter],"&period=",string msg`period;msg`filter;first);
  `scrobbles=msg`filter;
    ("user.getinfo";`getInfo;(::));
    ("user.getrecenttracks";`recenttracks;first)
  ];
  res:a[`f]raze .lfm.httpLimit[1;a`h;.lfm.cols[a`m]#.lfm.funcs]'[key l;get l];                  / http request
  :.lfm.parse[a`m]["@",string first key l;.lfm.periods msg`period;res];                         / parse results
 };

.lfm.getChart:{[u;l;msg]
  if[not msg[`c]in .lfm.filters;msg[`c]:`tracks];                                               / default to tracks
  e:$[1=count k:key l;("for @",string[first k]," ";5);("";0W)];                                 / name of requested user
  lbl:-1_string msg`c;
  res:raze .lfm.httpLimit[e 1;"user.getweekly",lbl,"chart";.lfm.cols[msg`c]#.lfm.funcs]'[key l;get l]; / http request
  if[0=count res;:()];                                                                          / no return for empty chart
  res:.lfm.parse.table 5 sublist`scrobbles xdesc .lfm.chart[msg`c]@[res;`name;trim 50$];        / trim wide columns
  :neg[.z.w](`worker;`music;$[`~u;"T";"Hey @",string[u],", t"],"he current ",lbl," chart ",e[0],"is:",res); / pass message back to server
 };

.lfm.parse.plot:{
  c:first[`track`artist`album`users inter cols x],`scrobbles;
  :"\n" sv .plot.autokey[x;c;`boxes;1b];
 }
.lfm.parse.table:{                                                                              / neatly format tables
  x:update("@",''string users)from 0!x;
  x:`no xcols update no:fills?[differ scrobbles;1+i;0N]from x;
  :ssr[;"\n";"\n  "]"\n",-1_.Q.s@[x;cols[x]where any"C "=\:exec t from meta x;`$];
 };
.lfm.parse.recenttracks:{[l;p;m]                                                                / [req user;period;message] parser for recent tracks
  r:$[m`attr;" is listening";" last listened"];                                                 / determine if song is currently playing
  :l,r," to '",m[`name],"' by ",m[`artist]," from ",m`album;                                    / format message
 };
.lfm.parse.tracks:{[l;p;m]                                                                      / [req user;period;message] parser for top tracks
  :l,"'s ",p," top track is '",m[`name],"' by ",m[`artist]," with ",string[m`playcount]," scrobbles"; / format message
 };
.lfm.parse.artists:{[l;p;m]                                                                     / [req user;period;message] parser for top artists
  :l,"'s ",p," top artist is ",m[`name]," with ",string[m`playcount]," scrobbles";              / format message
 };
.lfm.parse.albums:{[l;p;m]                                                                      / [req user;period;message] parser for top albums
  :l,"'s ",p," top album is '",m[`name],"' by ",m[`artist]," with ",string[m`playcount]," scrobbles"; / format message
 };
.lfm.parse.getInfo:{[l;p;m]                                                                     / [req user;period;message] get info for a user
  if[1=count m;:l," has ",string[first m`playcount]," scrobbles"];
  :"the current scrobble counts are:",.lfm.parse.table{@[;`users;enlist']x xdesc x xcol y}[`scrobbles;m];
 };

.lfm.chart.tracks:{select scrobbles:sum playcount,distinct users by track:name,artist from x};  / get counts by tracks
.lfm.chart.artists:{select scrobbles:sum playcount,distinct users by artist:name from x};       / get counts by artists
.lfm.chart.albums:{select scrobbles:sum playcount,distinct users by album:name,artist from x};  / get counts by albums
