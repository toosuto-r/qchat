/Basic functions
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


thum:{[x;y;z]t:"i"$"\033[G\n         _     \n        |)\\     \n        :  )    \n_____  /  /__   \n     |`  (____) \n     |   |(____)\n     |__.(____) \n_____|.__(___)";chat[;y;z]t}

/Ostracism
ostd:enlist[`]!enlist`

ostr:{[x;y;z]neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[G",string[.z.u]," has initiated ostracism mode.\nYou have 10 seconds to vote for a current user who will be kicked.";
  `cron insert (.z.P+"v"$10;`endost;`);
  @[`tf;"";:;ostv];};

ostv:{[x;y;z]x:users a?min a:lvn[x]'[string users];@[`ostd;.z.u;:;x]};

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

/Game interfaces
gamd:()
games:`connect4`ghost!`c4`gh

gamr:{[x;y;z]if[not in[x:`$3_"c"$x;key games];:neg[y]@0,ccache[aw?y]"j"$"\033[GNot a known game";];
  if[gameon games x;:neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GGame already in progress";gamd::()];
  neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[G",string[.z.u]," has initiated a game of ",string[x],". Press enter within the next 10 seconds to join.";
  `cron insert (.z.P+"v"$10;`endgv;games x);
  @[`tf;"";:;gamv];}

gamv:{[x;y;z]if[null first "c"$x;gamd,:.z.u];}

endgv:{@[`tf;"";:;chat];
  neg[aw ul]@'0,'ccache[ul:key[aw]except pl:distinct gamd]@\:"\033[GEnded game voting";
  if[2>count pl;:neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GNot enough players";gamd::()];
  t:2 0N#neg[count pl]?pl;
  .[`plyr;(x;0);:;(),t 0];
  .[`plyr;(x;1);:;(),t 1];
  @[`gameon;x;:;1b]; 
  neg[aw pl]@'0,'ccache[pl]@'"j"$"you're in team ",/:raze string 1+where each pl in/:\:t;
  neg[aw pl]@'1,'ccache[pl]@\:"j"$raze"`.z.pi set {neg[x](`chatter;enc[chatkey;-1_\"\\\\",string[x],"\",y]);-1\"\\033[F\\r\\033[0J\\033[F\\r\";}[value `.z.w]";
  neg[aw pl]@'1,'ccache[pl]@\:"j"$
  "`.z.ps set {
   if[0=x 0;:-1@raze\"\\033[\",(string y-1),\";1H\\033[0J\\033[F\\r\\033[2K\",\"c\"$dec[prikey;1_x];];
   if[1=x 0;:value\"c\"$dec[prikey;1_x]];
   if[2=x 0;:1@raze\"\\033[s\\033[;H\",(\"c\"$dec[prikey;1_x]),\"\\033[u\\033[\",(string y-1),\";1H\";]}[;\"J\"$system\"tput lines\"]";
  .c4.step[];
  `cron insert (.z.P+"v"$turnlengths x;`endturn;x);}

plyr:(``c4`gh!()):\:(();())
turn:(``c4`gh!()):\:0
gtvote:``c4`gh!(();();())
gameon:(``c4`gh!()):\:0b
turnlengths:``c4`gh!0N 7 10 

gtf:`c4`gh!(`.c4.play;{})

play:{
  value[gtf[y]]@x
  }

//TODO add a if[not gameon`c4;chat[x;y;z] thing
c4tn:{[x;y;z]
  if[not within[i:"J"$"c"$first 3_x;0 9];:tf[tf?tf 3$"c"$3_x][3_x;y;z]];
  if[not .z.u in plyr[`c4]turn[`c4]mod 2;
    :neg[.z.w]@0,ccache[.z.u]"j"$"Wait your turn!"];
  @[`gtvote;`c4;,;i];
  neg[.z.w]@0,ccache[.z.u]"j"$"Vote received";}

endturn:{
  if[not gameon x;:()];
  @[`turn;x;+;1];
  mv:first key desc count'[group (),$[0=count v:gtvote x;1?7;v]];
  @[`gtvote;x;:;()];
  play[;x] string mv;
  `cron insert (.z.P+"v"$turnlengths[x];`endturn;x);
  }

resetgame:{
  neg[aw pl]@'1,'ccache[pl:raze plyr x]@\:"j"$"`.z.pi set {neg[x](`chatter;enc[chatkey;-1_y]);-1\"\\033[F\\r\\033[0J\\033[F\\r\";}[value `.z.w]";
  neg[aw pl]@'1,'ccache[pl]@\:"j"$"`.z.ps set {if[0=x 0;:-1@\"c\"$dec[prikey;1_x]];if[1=x 0;:value\"c\"$dec[prikey;1_x]]}";
  @[`plyr;x;:;(();())];
  @[`gameon;x;:;0b];}


/New chat functions
mkct:{[x;y;z] if[2>count r:r where 1&count'[r:" "vs "c"$3_x];:neg[y]@0,ccache[aw?y]"j"$"\033[GPlease input in format CHATNAME USER1 USER2 USER3... to add users from scratch or CHATNAME -USER1 USER2... to make a new chat with all but the named users from this chat"];
  if[r[0]in ?\:[n;" "]#'n:raze each (6+n ss\:"-name ")_'(n:p where count each(p:system"ps -ef | grep chatter.q")ss\:"chatter.q");
    :neg[y]@0,ccache[aw?y]"j"$"\033[GChat exists and is currently active - quitting chat creation"];
  if[(cn:$[`;raze string md5 "Chat Room: ",r 0]) in key`:.;
    neg[y]@0,ccache[aw?y]"j"$"\033[GChat already exists - taking existing userlist";
    r:enlist[r 0],read0 hsym cn];
  
  flags:" -name ",first[r]," -admin ",string[.z.u]," -users ","-"sv nu:(),/:$["-"~r[1;0];string[.z.u, users]except 1_r;(1_r),enlist string .z.u];
  chatcmd:raze $[persist;"nohup ",qloc;"q"]," chatter.q -p ",string[np:{$[x~r:@[system;"lsof -i :",string x;x];x;x+1i]}/[system"p"]],flags,$[persist;" &";""];
  system chatcmd;
  neg[aw[th]]@'0,'ccache[th:inter[key aw;.z.u,`$nu]]@\:"\033[G",string[.z.u]," has made a new chat on port: ",string[np],".";
  }

dlte:{[x;y;z]if[not .z.u in admins;:neg[y]@0,ccache[aw?y]"j"$"\033[GDeleting the chatroom is an admin-only action"];
  if[(not "confirm"~i)or  not count i:3_"c"$x;:neg[y]@0,ccache[aw?y]"j"$"\033[Gtype \\d confirm"];
  shutdown`;
  exit 0;}

/Emojis
emdict:(!)."Sj"$flip {enlist[("";"Available: ",", "sv x[;0])],x}2 cut read0`:emojis

emji:{[x;y;z] if[not(`$3_"c"$x) in key emdict;:neg[y]@0,ccache[aw?y]"j"$"\033[GUnknown emoji - meme deficiency detected."];
  if[null`$3_"c"$x;:neg[y]@0,ccache[aw?y]emdict`];
  chat[;y;z]emdict `$"c"$3_x;}

labels:("\\q ";"\\h ";"\\c ";"\\u ";"\\i ";"\\k ";"\\o ";"\\y ";"\\a ";"\\n ";"\\d ";"\\e ";"\\g ";"\\v ";"\\me";"\\t ")!("quit";"help";"colour";"users";"info";"kick";"ostracise";"(y)";"add";"newchat";"delete";"emoji";"game";"volume";"action";"topic")

words:@[read0;`:works;enlist"unknown"]

topc:{[x;y;z]lastmsg::.z.P;neg[value[aw]]@'0,'ccache[key[aw]]@'uvol[key aw],\:"\033[GThe current topic is: ",first 1?words;}

medo:{[x;y;z]lastmsg::.z.P;neg[value[aw]]@'0,'ccache[key[aw]]@'uvol[key aw],\:"\033[G",1_ucol[.z.u;0],string[z],ucol[.z.u;1],4_x;}

func:{[x;y;z] neg[aw z]@0,ccache[z]"\n"sv key[labels],'" ",'value labels}

cemdict:"c"$emdict
pemji:{raze#[1;r],(cemdict`$td#'dr),'(td:?\:[dr;" "])_'dr:1_r:"//e "vs x}
pcols:{raze#[1;r],(1_'coldict coldict?coldict`$td#'dr),'(1+td:?\:[dr;" "])_'dr:1_r:"//c "vs x}
atproc:{#[a;x],1_first[ucol`$t],t,_[-1;(),last[ucol`$t::1_a _e#x]],_[e:count[x]^w?[(a:?[x;"@"])<w:where not x in .Q.an;1b];x]}/

chat:{[x;y;z]lastmsg::.z.P;neg[value[aw]]@'0,'ccache[key[aw]]@'uvol[key aw],\:"\033[G",ucol[.z.u;0],"[",$[10;string z],"]:",ucol[.z.u;1],$[any $["@"in cx:$["c";x];"c"$x:"j"$atproc cx;cx]like/:("*//c*";"*//e*");"j"$pemji[pcols cx],"\033[0m";x];};

boks:{[x;y;z]chat[;y;z]'["j"$("╔",((3*1+2*count x)#"═"),"╗";"║",(raze " ",'upper x)," ║";"╚",((3*1+2*count x:"c"$3_x)#"═"),"╝")];}

tf[""]:chat

tf,:("\\  ";"\\u ";"\\i ";"\\k ";"\\o ";"\\y ";"\\a ";"\\n ";"\\d ";"\\e ";"\\g ";"\\c4";"\\b ";"\\t ";"\\me")!(func;usls;info;kick;ostr;thum;addu;mkct;dlte;emji;gamr;c4tn;boks;topc;medo);
