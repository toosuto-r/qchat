/ Last FM bot code
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.httpGet:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

.lfm.filters:("tracks";"artists")!`toptracks`topartists;                                        / allowed filters
.lfm.periods:enlist["overall"]!enlist"overall ";
.lfm.periods,:("7day";"1month";"3month";"6month";"12month")!"over the last ",/:("7 days ";"1 month ";"3 months ";"6 months ";"12 months "); / allowed periods

.lfm.parse.recenttracks:{[z;m]                                                                  / parser for recent tracks
  r:$[(`$"@attr")in key a:first m;" is listening";" last listened"];                            / determine if song is currently playing
  s:raze{"'",x[0],"' by ",x[1]," from ",x 2}@[;1 2;first]a`name`artist`album;
  :r," to ",s;                                                                                  / format message
 };
.lfm.parse.toptracks:{[z;m]                                                                     / parser for top tracks
  s:" by "sv@[;0;{"'",x,"'"}]@[;1;first]first[m]`name`artist;
  :"'s top track ",z,"is ",s," with ",m[`playcount]," scrobbles";                               / format message
 };
.lfm.parse.topartists:{[z;m]                                                                    / parser for top artists
  :"'s top artist ",z,"is ",first[m`name]," with ",m[`playcount]," scrobbles";                  / format message
 };

.lfm.parseMethod:{                                                                              / parse request methos
  if[not x[`filter]in key .lfm.filters;:("user.getrecenttracks";`recenttracks)];                / default to recent tracks
  :("user.gettop",x[`filter],"&limit=1&period=",x`period;.lfm.filters x`filter);
 };

.lfm.request:{[x;y;z]                                                                           / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  if[not z[`period]in key .lfm.periods;z[`period]:"7day"];                                      / set default period
  p:.lfm.parseMethod z;
  if[0=count msg:first first .lfm.httpGet[p 0]y;:()];                                           / make request to last fm
  res:.lfm.parse[p 1][.lfm.periods z`period;msg];                                               / parse returned message
  if[0=count res;:()];                                                                          / no return on bad request
  :neg[.z.w](`worker;`music;raze"Hey ",x,", ",z[`name],res);                                    / pass message back to server
 };

.lfm.getChartUser:{[x;y]
  res:first{                                                                                    / loop over pages to get all tracks
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
