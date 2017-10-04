labels,:("\\ne";"\\ml";"\\bc";"\\df")!("news";"music";"bitcoin";"define");

news:{[x;y;z]rc[;y;0]"\033[GGetting news";neg[wh](`getheadline;uct string z);}
defn:{[x;y;z] neg[wh](`dictlkup;trim "c"$3_x);}
mulo:{[x;y;z]
  if[()~key`:lfm_key;:rc[;y;0]"\033[Gmusic lookup not enabled"];                                / return error if unenabled
  .lfm.cache:@[get;`:lfm_cache;()!()];                                                          / load cache of lastfm usernames
  if[0=count msg:trim"c"$3_x;                                                                   / return help message if no input is provided
    options:("* enter 'user=<LFM_NAME>' to update lastfm username, leave blank to unset";
      "* usage='\\ml <USERNAME>(&<FILTER>&<PERIOD>)' OR '\\ml chart'";
      "* Filters: tracks, artists, chart\n* Periods: overall, 7day, 1month, 3month, 6month, 12month";
      "  users: ",$[0=count k:key .lfm.cache;"()";atproc", "sv "@",'string k]);
    :rc[;y;0]"\033[Gmusic lookup from lastfm enabled, available options:\n","\n"sv options;
  ];
  if[msg like"chart*";
    rc[;y;0]"\033[GSending Chart Request";
    msg:"&"vs msg;
    if[not(u:`$trim msg 1)in key .lfm.cache;u:`];
    :getchart[z;u;`];
  ];
  if[msg like"user=*";                                                                          / update username for current user
    `:lfm_cache set$[0=count uname:(1+msg?"=")_msg;z _.lfm.cache;.lfm.cache,enlist[z]!enlist uname]; / update cache
    :rc[;y;0]"\033[GUpdated username";
  ];
  msg:@[;`filter`period;lower]{(!).(3&count x)#/:(`name`filter`period;x)}"&"vs msg;             / split message parameters
  if[not(`$msg`name)in key .lfm.cache;:rc[;y;0]"\033[Guser not available"];                     / return error if requested user is unavailable
  rc[;y;0]"\033[GSending Request";
  neg[wh](`.lfm.request;z;((),`$msg`name)#.lfm.cache;msg);                                      / send request to worker process
 };
getchart:{[x;y;z]
  if[not`updatechart in cron`action;`cron insert(09:30+1+.z.D;`updatechart;`update)];           / update cron
  if[()~key`:lfm_key;:()];                                                                      / exit if unenabled
  .lfm.cache:@[get;`:lfm_cache;()!()];                                                          / load cache of lastfm usernames
  if[0=count .lfm.cache;:()];                                                                   / exit if no users are cached
  neg[wh](`.lfm.request;x;$[y=`;(::);((),y)#].lfm.cache;`filter`c!("chart";z));                 / send request
 };
updatechart:getchart[`;`];
updatechart`update;                                                                             / initialise cron job

btcp:{[x;y;z]
 if[`~`$upper trim"c"$3_x;x:"xxxUSD"];
 if[not (c:`$upper trim"c"$3_x) in `USD`GBP`EUR`PLOT;:rc[;y;0]"\033[GUnsupported currency/option. Supported currencies: gbp,usd,eur. Options: plot"];
 rc[;y;0]"\033[GGetting BTC price";neg[wh](`.btc.getprice;trim uct string z;c);
 };

stkp:{[x;y;z]
  rc[;y;0]"\033[GGetting stock plot";neg[wh](`.plot.getplot;trim uct string z;`$"c"$3_x;y);
 }

stkerr:{[x] /x:user handle
  rc[;x;0]"\033[GError, stock not found!";
 }

workernames,:`news`music`bitcoin`defino`stock!"[",/:$[10;("NEWSBOT";"LASTFMBOT";"BTCBOT";"DICTBOT";"STOCKBOT")],\:"]:" / bot names used when printing to chat

tf,:("\\ne";"\\ml";"\\bc";"\\df";"\\st")!(news;mulo;btcp;defn;stkp);
