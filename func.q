ostd:enlist[`]!enlist`

coldict:(`default`black`red`green`yellow`blue`magenta`cyan`gray!(" \033[0m";" \033[1;30m";" \033[1;31m";" \033[1;32m";" \033[1;33m";" \033[1;34m";" \033[1;35m";" \033[1;36m";" \033[1;37m"))

usls:{[x;y;z]neg[y]@0,ccache[aw?y]"j"$"users online: ",", "sv string key[aw] except hiddenusers;};
info:{[x;y;z]neg[y]@0,ccache[aw?y]"j"$banner,". Chat admins: ",", "sv string admins};
help:{[x;y;z]neg[y]@0,ccache[aw?y]"j"$"Message typed without prefix are automatically broadcast to all logged in users.\nUseful functions are called with \\X or \\X input, where X is a lower case letter, e.g. '\\q' or '\\quit' to quit"};

kick:{[x;y;z]if[not .z.u in admins;:neg[y]@0,ccache[aw?y]"j"$"Kicking is an admin-only action"];
  if[not in[t:`$3_"c"$x;users];:neg[y]@0,ccache[aw?y]"j"$"Not a user"];
  neg[value[hs]]@'0,'ccache[key[hs:aw _aw?y]]@\:string[t]," has been permanently banished";
  neg[aw t]@1,ccache[t]"j"$"exit 0";
  chatfile 0: string users except t}

addu:{[x;y;z]if[not .z.u in admins;:neg[y]@0,ccache[aw?y]"j"$"Adding is an admin-only action"];
  if[not in[t:`$3_"c"$x;users];:neg[y]@0,ccache[aw?y]"j"$"Not a user"];
  neg[value[hs]]@'0,'ccache[key[hs:aw _aw?y]]@\:string[t]," has been added";
  chatfile 0: string users,t}

clrs:{[x;y;z]if[not(`$3_"c"$x) in key coldict;:neg[y]@0,ccache[aw?y]"j"$"Incorrect colour"];@[`ucol;z;:;(coldict `$3_"c"$x;"\033[0m ")];:neg[y]@0,ccache[aw?y]"j"$"colour set. Fabulous."};

thum:{[x;y;z]chat[t:"i"$"\n         _     \n        |)\\     \n        :  )    \n_____  /  /__   \n     |`  (____) \n     |   |(____)\n     |__.(____) \n_____|.__(___)";y;z];neg[y]@0,ccache[aw?y]t};

ostr:{[x;y;z]neg[value[hs]]@'0,'ccache[key[hs:aw]]@\:string[.z.u]," has initiated ostracism mode.\nYou have 10 seconds to vote for a current user who will be kicked.";
  `cron insert (.z.P+"v"$10;`endost);
  @[`tf;"";:;ostv];};

ostv:{[x;y;z]@[`ostd;.z.u;:;users users?`$"c"$x]};

mkct:{[x;y;z] if[2>count r:r where 1&count'[r:" "vs "c"$3_x];:neg[y]@0,ccache[aw?y]"j"$"Please input in format CHATNAME USER1 USER2 USER3... to add users from scratch or CHATNAME -USER1 USER2... to make a new chat with all but the named users from this chat"];
  show $[`;raze string md5 "Chat Room: ",r 0]; show r 0;
  if[$[`;raze string md5 "Chat Room: ",r 0] in key`:.; :neg[y]@0,ccache[aw?y]"j"$"Chat already exists";]
  show flags:" -name ",first[r]," -admin ",string[.z.u]," -users ","-"sv nu:(),/:$["-"~r[1;0];string[.z.u, users]except 1_r;(1_r),enlist string .z.u];
  show chatcmd:$[persist;"nohup ",qloc;"q"]," chat.q -p ",string[np:{$[x~r:@[system;"lsof -i :",string x;x];x;x+1i]}/[system"p"]],flags,$[persist;" &";""];
  system chatcmd;
  neg[aw[th]]@'0,'ccache[th:inter[key aw;.z.u,`$nu]]@\:string[.z.u]," has made a new chat on port: ",string[np],".";
  }

dlte:{[x;y;z]if[not .z.u in admins;:neg[y]@0,ccache[aw?y]"j"$"Deleting the chatroom is an admin-only action"];
  if[(not "confirm"~i)or  not count i:3_"c"$x;:neg[y]@0,ccache[aw?y]"j"$"type \\d confirm"];
  shutdown`;
  exit 0;}

ghostword:""
wl:read0`:words
ghostplayers:0#`
lastghost:0#`
ghst:{[x;y;z] if[0=count l:trim "c"$3_x;:neg[y]@0,ccache[aw?y]"j"$"players:",", "sv string ghostplayers];}

tf,:("\\u";"\\i";"\\h";"\\c";"\\k";"\\o";"\\y";"\\a";"\\n";"\\d")!(usls;info;help;clrs;kick;ostr;thum;addu;mkct;dlte);
