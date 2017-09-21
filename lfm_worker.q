/ Last FM bot code
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.httpGet:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

.lfm.filters:("tracks";"artists");                                                              / allowed filters
.lfm.periods:enlist["overall"]!enlist"overall ";
.lfm.periods,:("7day";"1month";"3month";"6month";"12month")!"over the last ",/:("7 days ";"1 month ";"3 months ";"6 months ";"12 months "); / allowed periods

.lfm.parseMethod:{                                                                              / parse request methos
  if[not x[`filter]in .lfm.filters;:"user.getrecenttracks"];                                    / default to recent tracks
  :"user.gettop",x[`filter],"&limit=1&period=",x`period;
 };

.lfm.parse.recenttracks:{[x;y;z;m]                                                              / parser for recent tracks
  if[0=count m:m[`recenttracks]`track;:""];                                                     / exit if no recent tracks for user
  r:$[(`$"@attr")in key a:first m;"is listening";"last listened"];                              / determine if song is currently playing
  s:raze{"'",x[0],"' by ",x[1]," from ",x 2}@[;1 2;first]first[m]`name`artist`album;
  :" "sv(z`name;r;"to";s);                                                                      / format message
 };
.lfm.parse.toptracks:{[x;y;z;m]                                                                 / parser for top tracks
  if[0=count m:m[`toptracks]`track;:""];                                                        / exit if no top tracks for user
  s:" by "sv@[;0;{"'",x,"'"}]@[;1;first]first[m]`name`artist;
  :raze z[`name],"'s top track ",.lfm.periods[z`period],"is ",s," with ",m[`playcount]," scrobbles"; / format message
 };
.lfm.parse.topartists:{[x;y;z;m]                                                                / parser for top artists
  if[0=count m:m[`topartists]`artist;:""];                                                      / exit if no top artists for user
  :raze z[`name],"'s top artist ",.lfm.periods[z`period],"is ",first[m`name]," with ",m[`playcount]," scrobbles"; / format message
 };

.lfm.request:{[x;y;z]                                                                           / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  if[not z[`period]in key .lfm.periods;z[`period]:"7day"];                                      / set default period
  msg:.lfm.httpGet[.lfm.parseMethod z]y;                                                        / make request to last fm
  if[not(k:first key msg)in key .lfm.parse;:()];                                                / exit if improper message returned
  res:.lfm.parse[k][x;y;z;msg];                                                                 / parse returned message
  if[0=count res;:()];                                                                          / no return on bad request
  :neg[.z.w](`worker;`music;"Hey ",x,", ",res);                                                 / pass message back to server
 };

.lfm.getChartUser:{[x;y]
  res:first{
    r:.lfm.httpGet["user.gettoptracks&period=7day&page=",string y 1;x];
    if[0=count l:r[`toptracks]`track;:y];
    y[0]:y[0],select name,{x`name}'[artist],"J"$playcount from l;
    @[y;1;1+]
  }[y]/[(();1)];
  if[98=type res;:update users:x from res];
  :res;
 };

.lfm.getChart:{[x;y;z]
  res:@[get;`.lfm.chart;()];
  if[(""~x`u)or 0=count res;                                                                    / if called from cron update results after 9.30am
    res:raze .lfm.getChartUser'[key z;value z];
    `.lfm.chart set res;
  ];
  e:"";
  if[not any ``update=x`f;
    res:select from res where users=x`f;
    e:raze"for ",string[x`c]," ";
  ];
  if[0=count res;:()];                                                                          / no return for empty chart
  res:0!`scrobbles xdesc select scrobbles:sum playcount,users by name,artist from res;
  res:select no:1+i,name,artist,scrobbles,users from res;
  res:5#res;
  :neg[.z.w](`worker;`music;$[""~x`u;"T";"Hey ",x[`u],", t"],"he current chart ",e,"is:\n","\n"sv"  ",/:"\n"vs ssr/[.Q.s res;("\" ";"\""),string key z;("   ";""),y]); / pass message back to server
 };
