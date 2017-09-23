labels,:("\\ne";"\\ml";"\\bc";"\\df")!("news";"music";"bitcoin";"define");

news:{[x;y;z]rc[;y;0]"\033[GGetting news";neg[wh](`getheadline;uct string z);}
defn:{[x;y;z] neg[wh](`dictlkup;trim "c"$3_x);}
mulo:{[x;y;z]
  if[()~key`:lfm_key;:rc[;y;0]"\033[Gmusic lookup not enabled"];                                / return error if unenabled
  .lfm.cache:@[get;`:lfm_cache;()!()];                                                          / load cache of lastfm usernames
  if[0=count msg:trim"c"$3_x;                                                                   / return help message if no input is provided
    options:("* enter 'user=<LFM_NAME>' to update lastfm username, leave blank to unset";
      "* usage='\\ml <USERNAME>(&<FILTER>&<PERIOD>)' OR '\\ml chart'";
      "* Filters: tracks, artists\n* Periods: overall, 7day, 1month, 3month, 6month, 12month";
      "  users: ",$[0=count k:key .lfm.cache;"()";", "sv trim'[ucn'[k;string k]]]);
    :rc[;y;0]"\033[Gmusic lookup from lastfm enabled, available options:\n","\n"sv options;
  ];
  if[msg like"chart*";
    rc[;y;0]"\033[GSending Chart Request";
    msg:"&"vs msg;
    if[not(u:`$trim msg 1)in key .lfm.cache;u:`];
    :getchart[.z.u;u];
  ];
  if[msg like"user=*";                                                                          / update username for current user
    `:lfm_cache set$[0=count uname:(1+msg?"=")_msg;.z.u _.lfm.cache;.lfm.cache,enlist[.z.u]!enlist uname]; / update cache
    :rc[;y;0]"\033[GUpdated username";
  ];
  msg:@[;`filter`period;lower]{(count[x]#`name`filter`period)!x}"&"vs msg;                      / split message parameters
  if[not(`$msg`name)in key .lfm.cache;:rc[;y;0]"\033[Guser not available"];                     / return error if requested user is unavailable
  rc[;y;0]"\033[GSending Request";
  neg[wh](`.lfm.request;trim uct string z;.lfm.cache`$msg`name;@[msg;`name;{trim ucn[`$x;x]}]); / send request to worker process
 };

getchart:{[x;y]
  if[()~key`:lfm_key;:()];                                                                      / exit if unenabled
  .lfm.cache:@[get;`:lfm_cache;()!()];                                                          / load cache of lastfm usernames
  if[0=count .lfm.cache;:()];
  d:`u`f`c!(trim ucn[x;string x];y;trim ucn[y;string y]);
  neg[wh](`.lfm.getChart;d;{trim ucn'[x;string x]}key .lfm.cache;.lfm.cache);
  if[not`getchart in cron`action;`cron insert(09:30+1+.z.D;`updatechart;`update)];
 };
updatechart:getchart[`];
updatechart`update;
btcp:{[x;y;z]
 if[`~`$upper trim"c"$3_x;x:"xxxUSD"];
 if[not (c:`$upper trim"c"$3_x) in `USD`GBP`EUR`PLOT;:rc[;y;0]"\033[GUnsupported currency/option. Supported currencies: gbp,usd,eur. Options: plot"];
 rc[;y;0]"\033[GGetting BTC price";neg[wh](`.btc.getprice;trim uct string z;c);
 };

workernames,:`news`music`bitcoin`defino!"[",/:$[10;("NEWSBOT";"LASTFMBOT";"BTCBOT";"DICTBOT")],\:"]:" / bot names used when printing to chat

tf,:("\\ne";"\\ml";"\\bc";"\\df")!(news;mulo;btcp;defn);
