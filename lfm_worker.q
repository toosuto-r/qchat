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

.lfm.httpWrap:{[p;x;y;z]
  q:$[p=0W;("";1b);("&limit=",string p;0b)];                                                    / limit results if necessary
  res:first{[q;x;y;z]                                                                           / loop over pages to get all tracks
    r:.lfm.httpGet[x,q[0],"&page=",string z 1;y];
    if[0=count l:first raze r;:z];
    z[0]:distinct z[0],{@/[;x;y]x#z}[z 2;z 3]'[l];
    :@[z;1;+;q 1];
  }[q;x;y]/[(();1;key z;value z)];
  :res;
 };

.lfm.ch:.lfm.httpWrap[0W;"user.gettoptracks&period=7day";;`name`artist`playcount!(::;first;"J"$)];
.lfm.rec:.lfm.httpWrap[1;"user.getrecenttracks";;(`name`artist`album,`$"@attr")!(::;first;first;{"true"~last x})];
.lfm.tt:.lfm.httpWrap[1;"user.gettoptracks&period=7day";;`name`artist`playcount!(::;first;"J"$)];
.lfm.ta:.lfm.httpWrap[1;"user.gettopartists&period=7day";;`name`playcount!(::;first)];

.lfm.getChart:{[x;y;z]
  res:@[get;`.lfm.chart;()];
  if[(""~x`u)or 0=count res;                                                                    / if called from cron update results
    res:raze{r:.lfm.getOver y;if[98=type r;r:update user:x from r];r}'[key z;value z];
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
