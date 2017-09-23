/ Last FM bot code
.lfm.key:first@[read0;`:lfm_key;""];                                                            / api key
.lfm.httpGet:{.j.k .Q.hg`$"http://ws.audioscrobbler.com/2.0/?format=json&api_key=",.lfm.key,"&method=",x,"&user=",y};

/ variables required to build up messages
.lfm.filters:("tracks";"artists")!`toptracks`topartists;                                        / allowed filters
.lfm.periods:("overall";"7day";"1month";"3month";"6month";"12month")!("overall";"7 day";"1 month";"3 month";"6 month";"12 month"); / allowed periods
.lfm.funcs:(`artist`playcount`album,`$"@attr")!(first;"J"$;first;{"true"~last x});              / column functions
.lfm.cols:(`topartists;`toptracks;`recenttracks)!(`name`playcount;`name`artist`playcount;(`name`artist`playcount`album,`$"@attr")); / columns for parsing requests

.lfm.request:{[x;y;z]                                                                           / [user;lfm name;msg] return users now playing track, mentioning the user who made the request
  res:.lfm.parseMethod[x;y;z];
  :neg[.z.w](`worker;`music;raze"Hey @",string[x],", @",string[first key y],res);               / pass message back to server
 };

.lfm.parseMethod:{[x;y;z]                                                                       / parse request methos
  if[not z[`period]in key .lfm.periods;z[`period]:"7day"];                                      / set default period
  a:$[z[`filter]in key .lfm.filters;
    ("user.gettop",z[`filter],"&limit=1&period=",z`period;.lfm.filters z`filter);
    ("user.getrecenttracks";`recenttracks)
  ];
  res:.lfm.httpWrap[1;a 0;first value y;(.lfm.cols a 1)#.lfm.funcs];
  :.lfm.parse[a 1][.lfm.periods z`period;first res];
 };

.lfm.parse.recenttracks:{[z;m]                                                                  / parser for recent tracks
  r:$[m`$"@attr";" is listening";" last listened"];                                             / determine if song is currently playing
  :r," to '",m[`name],"' by ",m[`artist]," from ",m`album;                                      / format message
 };
.lfm.parse.toptracks:{[z;m]                                                                     / parser for top tracks
  :"'s ",z," top track is '",m[`name],"' by ",m[`artist]," with ",string[m`playcount]," scrobbles"; / format message
 };
.lfm.parse.topartists:{[z;m]                                                                    / parser for top artists
  :"'s ",z," top artist is ",m[`name]," with ",string[m`playcount]," scrobbles";                / format message
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

.lfm.getChart:{[x;y;z]
  res:@[get;`.lfm.chart;()];
  if[(""~x`u)or 0=count res;                                                                    / if called from cron update results
    res:raze{r:.lfm.ch y;if[98=type r;r:update users:x from r];r}'[key z;value z];
    `.lfm.chart set res;
  ];
  e:"";
  if[not any ``update=x`f;
    res:select from res where users=x`f;
    e:raze"for ",string[x`c]," ";
  ];
  if[0=count res;:()];                                                                          / no return for empty chart
  res:update("@",'string users)from res;                                                        / allow colours
  res:0!`scrobbles xdesc select scrobbles:sum playcount,users by name,artist from res;
  res:5#select no:1+i,name,artist,scrobbles,users from res;
  :neg[.z.w](`worker;`music;ssr[;"\n";"\n  "]$[""~x`u;"T";"Hey ",x[`u],", t"],"he current chart ",e,"is:\n",.Q.s@[res;cols[res]where"C"=exec t from meta res;`$]); / pass message back to server
 };
