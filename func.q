ostd:enlist[`]!enlist`
gamd:()

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

ostr:{[x;y;z]neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[G",string[.z.u]," has initiated ostracism mode.\nYou have 10 seconds to vote for a current user who will be kicked.";
  `cron insert (.z.P+"v"$10;`endost;`);
  @[`tf;"";:;ostv];};

ostv:{[x;y;z]@[`ostd;.z.u;:;users users?`$"c"$x]};

endost:{neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GEnded ostracism voting";
  @[`tf;"";:;chat];
  h:aw u:c?max c:1_count'[group raze ostd];
  if[not n:null h;
    neg[h]@0,ccache[u]"j"$"\033[GYou know what you did.";
    neg[h]@1,ccache[u]"j"$"exit 0";
    neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[G",string[u]," has been BANISHED"];
  if[n;neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GInsufficient ill-will to kick."];
  `ostd set enlist[`]!enlist`;
  };

games:(),`connect4

gamr:{[x;y;z]if[not in[`$3_"c"$x;games];:neg[y]@0,ccache[aw?y]"j"$"\033[GNot a known game";];
  neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[G",string[.z.u]," has initiated a game of ",$["c";3_x],". Press enter to join.";
  `cron insert (.z.P+"v"$10;`endgv;`);
  @[`tf;"";:;gamv];}

gamv:{[x;y;z]if[null first "c"$x;gamd,:.z.u];}

endgv:{@[`tf;"";:;chat];
  neg[aw ul]@'0,'ccache[ul:key[aw]except pl:distinct gamd]@\:"\033[GEnded game voting";
  /if[2>pl;:eg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GNot enough players"];
  gamd::();
  t:2 0N#neg[count pl]?pl;
  .[`plyr;(`c4;0);:;(),t 0];
  .[`plyr;(`c4;1);:;(),t 1];
  neg[aw pl]@'0,'ccache[pl]@'"j"$"you're in team ",/:raze string 1+where each pl in/:\:t;
  neg[aw pl]@'1,'ccache[pl]@\:"j"$"`.z.pi set {neg[x](`chatter;enc[chatkey;-1_\"\\\\c4\",y]);-1\"\\033[F\\r\\033[0J\\033[F\\r\";}[value `.z.w]";
  neg[aw pl]@'1,'ccache[pl]@\:"j"$
  "`.z.ps set {
   if[0=x 0;:-1@raze\"\\033[\",(string y-1),\";1H\\033[0J\\033[F\\r\\033[2K\",\"c\"$dec[prikey;1_x];];
   if[1=x 0;:value\"c\"$dec[prikey;1_x]];
   if[2=x 0;:1@raze\"\\033[s\\033[;H\",(\"c\"$dec[prikey;1_x]),\"\\033[u\\033[\",(string y-1),\";1H\";]}[;\"J\"$system\"tput lines\"]";}

c4ms:{}
gcom:(enlist"\\c4")!enlist c4ms

plyr:(``c4!()):\:(();())
turn:(``c4!()):\:0
gtvote:``c4!(();())
gameon:(``c4!()):\:0b

playc4:{


  }




c4tn:{[x;y;z]
  if[not within[i:"J"$"c"$first 3_x;0 9];:tf[tf?tf 3$"c"$3_x][3_x;y;z]];
  if[not .z.u in plyr[`c4]turn[`c4]mod 2;
    :neg[.z.w]@0,ccache[.z.u]"j"$"Wait your turn!"];
  @[gtvote;`c4;,;i];
  neg[.z.w]@0,ccache[.z.u]"j"$"Vote recieved";}

endc4turn:{
  if[not gameon`c4;
    neg[aw pl]@'1,'ccache[pl:raze plyr`c4]@\:"j"$"`.z.pi set {neg[x](`chatter;enc[chatkey;-1_y]);-1\"\\033[F\\r\\033[0J\\033[F\\r\";}[value `.z.w]";
    :@[`plyr;`c4;:;(();())];];
  @[`turn;c4;+;1];
  mv:first key desc count'[group gtvote`c4];
  @[`gtvote;`c4;:;()];
  playc4 mv;
  `cron insert (.z.P+"v"$turnlengths[`c4];endc4turn;`)
  }

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

tf,:("\\u ";"\\i ";"\\k ";"\\o ";"\\y ";"\\a ";"\\n ";"\\d ";"\\e ";"\\g ";"\\c4")!(usls;info;kick;ostr;thum;addu;mkct;dlte;emji;gamr;c4tn);

/TODO
/ghost
/ns "emoji"?
/UX - "enter" to re-use old keys
