labels,:("\\ne";"\\ml";"\\bc";"\\df")!("news";"music";"bitcoin";"define");

news:{[x;y;z]rc[;y;0]"\033[GGetting news";neg[wh](`getheadline;uct string z);}
defn:{[x;y;z] neg[wh](`dictlkup;trim "c"$3_x);}
urbd:{[x;y;z] neg[wh](`udlkup;trim "c"$3_x);}
wiki:{[x;y;z] neg[wh](`wikilkup;trim "c"$3_x);}
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
 a:" " vs trim"c"$3_x;
 if[1=count a;a,:enlist"0"];
 if[`~`$upper a[0];a[0]:"USD"];
 if[not (c:`$upper a[0]) in `USD`GBP`EUR`PLOT`KFC;:rc[;y;0]"\033[GUnsupported currency/option. Supported currencies: gbp,usd,eur,kfc. Options: plot"];
 rc[;y;0]"\033[GGetting BTC price";neg[wh](`.btc.getprice;trim uct string z;c;"F"$a[1]);
 };

stkp:{[x;y;z]
  rc[;y;0]"\033[GGetting stock plot";neg[wh](`.plot.getplot;trim uct string z;`$"c"$3_x;y);
 }

workernames,:`news`music`bitcoin`defino`stock`shame`wiki`urbd!"[",/:$[10;("NEWSBOT";"LASTFMBOT";"BTCBOT";"DICTBOT";"STOCKBOT";"SHAMEBOT";"WIKIBOT";"URBANBOT")],\:"]:" / bot names used when printing to chat

tf,:("\\ne";"\\ml";"\\bc";"\\df";"\\st";"\\wk";"\\ud")!(news;mulo;btcp;defn;stkp;wiki;urbd);
