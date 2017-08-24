ostd:enlist[`]!enlist`

usls:{[x;y;z]neg[y]@0,ccache[aw?y]"j"$"\033[Gusers online: ",", "sv string key[aw] except hiddenusers;};
info:{[x;y;z]neg[y]@0,ccache[aw?y]"j"$"\033[G",banner,". Chat admins: ",", "sv string (),admins};

kick:{[x;y;z]if[not .z.u in admins;:neg[y]@0,ccache[aw?y]"j"$"\033[GKicking is an admin-only action"];
  if[not in[t:`$3_"c"$x;users];:neg[y]@0,ccache[aw?y]"j"$"\033[GNot a user"];
  neg[value[hs]]@'0,'ccache[key[hs:aw _aw?y]]@\:"\033[G",string[t]," has been permanently banished";
  neg[aw t]@1,ccache[t]"j"$"exit 0";
  chatfile 0: string users except t}

addu:{[x;y;z]if[not .z.u in admins;:neg[y]@0,ccache[aw?y]"j"$"\033[GAdding is an admin-only action"];
  if[not in[t:`$3_"c"$x;users];:neg[y]@0,ccache[aw?y]"j"$"\033[GNot a user"];
  neg[value[hs]]@'0,'ccache[key[hs:aw _aw?y]]@\:"\033[G",string[t]," has been added";
  chatfile 0: string users,t}


thum:{[x;y;z]t:"i"$"\033[G\n         _     \n        |)\\     \n        :  )    \n_____  /  /__   \n     |`  (____) \n     |   |(____)\n     |__.(____) \n_____|.__(___)";neg[y]@0,ccache[aw?y]t};

ostr:{[x;y;z]neg[value[hs]]@'0,'ccache[key[hs:aw]]@\:"\033[G",string[.z.u]," has initiated ostracism mode.\nYou have 10 seconds to vote for a current user who will be kicked.";
  `cron insert (.z.P+"v"$10;`endost);
  @[`tf;"";:;ostv];};

ostv:{[x;y;z]@[`ostd;.z.u;:;users users?`$"c"$x]};

mkct:{[x;y;z] if[2>count r:r where 1&count'[r:" "vs "c"$3_x];:neg[y]@0,ccache[aw?y]"j"$"\033[GPlease input in format CHATNAME USER1 USER2 USER3... to add users from scratch or CHATNAME -USER1 USER2... to make a new chat with all but the named users from this chat"];
  if[r[0]in ?\:[n;" "]#'n:raze each (6+n ss\:"-name ")_'(n:p where count each(p:system"ps -ef | grep chatter.q")ss\:"chatter.q");
    :neg[y]@0,ccache[aw?y]"j"$"\033[GChat exists and is currently active - quitting chat creation"];
  if[(cn:$[`;raze string md5 "Chat Room: ",r 0]) in key`:.;
    neg[y]@0,ccache[aw?y]"j"$"\033[GChat already exists - taking existing userlist";
    r:enlist[r 0],read0 hsym cn];
  
  flags:" -name ",first[r]," -admin ",string[.z.u]," -users ","-"sv nu:(),/:$["-"~r[1;0];string[.z.u, users]except 1_r;(1_r),enlist string .z.u];
  chatcmd:$[persist;"nohup ",qloc;"q"]," chatter.q -p ",string[np:{$[x~r:@[system;"lsof -i :",string x;x];x;x+1i]}/[system"p"]],flags,$[persist;" &";""];
  system chatcmd;
  neg[aw[th]]@'0,'ccache[th:inter[key aw;.z.u,`$nu]]@\:"\033[G",string[.z.u]," has made a new chat on port: ",string[np],".";
  }

dlte:{[x;y;z]if[not .z.u in admins;:neg[y]@0,ccache[aw?y]"j"$"\033[GDeleting the chatroom is an admin-only action"];
  if[(not "confirm"~i)or  not count i:3_"c"$x;:neg[y]@0,ccache[aw?y]"j"$"\033[Gtype \\d confirm"];
  shutdown`;
  exit 0;}

emdict:(!)."Sj"$flip {enlist[("";"Available: ",", "sv x[;0])],x}2 cut read0`:emojis
emji:{[x;y;z] if[not(`$3_"c"$x) in key emdict;:neg[y]@0,ccache[aw?y]"j"$"\033[GUnknown emoji - meme deficiency detected."];
  if[null`$3_"c"$x;:neg[y]@0,ccache[aw?y]emdict`];
  chat[;y;z]emdict `$"c"$3_x;}

/ghostword:""
/wl:read0`:words
/ghostplayers:0#`
/lastghost:0#`
/ghst:{[x;y;z] if[0=count l:trim "c"$3_x;:neg[y]@0,ccache[aw?y]"j"$"players:",", "sv string ghostplayers];}

tf,:("\\u";"\\i";"\\k";"\\o";"\\y";"\\a";"\\n";"\\d";"\\e")!(usls;info;kick;ostr;thum;addu;mkct;dlte;emji);

/TODO
/ghost
