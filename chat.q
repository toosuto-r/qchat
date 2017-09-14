system"t 1000";
system"S ",string"j"$.z.T

banner:"Welcome to homerchat: discreet and discrete."
if[count n:raze .Q.opt[.z.x]`name;banner:"Chat Room: ",n];

aliases:1b;
challenge:1b
challenge=:"b"$count raze .Q.opt[.z.x]`challenge;
persist:1b;
record:1b;
transfer:1b;

forbiddenkeys:(3233 413;3233 17;3233 2753)
forbiddenkeys:(0N 0N;0N 0N)

qloc:@[system;"which q";getenv[`HOME],"/q/l32/q"]
connectedusers:@[get;`:cu;([]time:"p"$();user:`$())]

/Handles - only allow communication over .z.ps with allowed functions
.z.pi:{if[.z.w;:neg[.z.w]"-1\"Forbidden - use a full q process.\""];.Q.s @[value;x;{'"nw"}]}
.z.ps:.z.po:.z.pm:.z.ph:.z.ws:.z.pp:.z.pg:{neg[.z.w]"-1\"oh no baby what is you doin\"";hclose[.z.w]}
.z.wo:{neg[x]"-1\"too sneaky for your own good tbh\"";hclose x}

/Chat variables - read from file or use defaults
admins:$[count a:.Q.opt[.z.x]`admin;`$a;`ryan]
users:raze .[0:;((enlist "S";",");chatfile:hsym`$raze string md5 banner);`$"-"vs $[count ul:first .Q.opt[.z.x]`users;ul;""]]
chatfile 0: string users;
hiddenusers:`
ckeys:$[`key in key`;2 cut .key.mk[$[challenge;60;5000]][`nkey`pub`nkey`pri];(3233 17;3233 413)]
chatpubkey:ckeys 0
chatprikey:ckeys 1
cron:([]time:"p"$();action:`$();args:())

/Timed events should be added to cron
.z.ts:{pi:exec i from cron where time<.z.P;if[count pi;r:exec action,args from cron where i in pi;delete from `cron where i in pi;({value[x]. (),y}.)'[flip value r]];}

/Key holders
tpks:aw:w:()!()
pks:@[get;`:pks;()!()]
ccache:@[get;`:ccache;()!()]

/colour and last messages
ucol:@[get;`:ucol;enlist[`]!enlist""]
lastmsg:0Np

fallowed:`checker`decider`getpubkey`testdec`testenc`checkphrase`chatter`finalcheck`worker

/Only allow users
.z.ps:{if[x[0] in fallowed;:value x];neg[.z.w]"-1\"Rude.\""}
.z.pw:{[u;p]in[u;users]&not in[u;key aw]}

/On handle close, drop from active handles
.z.pc:{.[`w;();_;w?x];
  if[x in aw;neg[value[hs]]@'0,'ccache[key[hs:aw _aw?x]]@\:string[aw?x]," has left";
    .[`aw;();_;aw?x]];
  if[any p:.z.u in/:plyr`c4;
    .[`plyr;(`c4;where p);except;.z.u]]
  ;}

/On open, close ports on target, turn timer off, make the display wide,
/display welcome and allow jump to end of checks if previously reg'd
.z.po:{
  if[not x in w;@[`w;.z.u;:;x]];
  neg[x](system;"p 0");
  neg[x](system;"t 0");
  neg[x](system;"c 25 1000");
  neg[x]({hclose each key[.z.W] except value x};`.z.w);
  if[all (not any null r;2=count r;7h=type r:pks .z.u);
    neg[x]"-1\"",banner,"\"";
    neg[x]"-1\"Existing verified public key found for ",string[.z.u]," - proceed (enter) or reset (n)\"";
    :neg[x]({`.z.pi set {neg[x](`decider;y)}[value `.z.w]};`)];
  neg[x]"-1\"",banner,"\"";
  if[transfer&not challenge;
    neg[x](set';`.key.p`.key.c`.key.ex`.key.cg`.key.mk;(.key.p;.key.c;.key.ex;.key.cg;.key.mk));
    neg[x]"-1\"New keys - PUBLIC: \",sv[\" \";string nk[`nkey`pub]],\" PRIVATE: \",sv[\" \";string(nk:.key.mk 10000)[`nkey`pri]]"];
  :neg[.z.w]({neg[.z.w](`checker;value `.z.w;@[value;`enc;`];@[value;`dec;`];first`$system"id -u -n")};`);
  };

/if user presses enter, push over the private key verifier
/if challenge is off, use efficient enc/dec
/if user wants to reset, jump back to checker
decider:{if[first[x]="\n";
    neg[.z.w]({`.z.pi set y@value x}[`.z.w];nspk);
    if[transfer;
      neg[.z.w]({`enc set x};ec);
      neg[.z.w]({`dec set x};dc);];
    @[`tpks;.z.u;:;pks .z.u];
    :neg[.z.w]"-1$[`pri in key hsym `$getenv[`HOME],\"/.homerchat\";\"Found local private key from last session - re-use(enter/n)?\";\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"]"];
  :neg[.z.w]({neg[.z.w](`checker;value `.z.w;@[value;`enc;`];@[value;`dec;`];first`$system"id -u -n")};`);
  }

/check based on flags: aliases and *crypt functions
checker:{[x;y;z;u]
  if[not[aliases] and not .z.u~u;:fail"No aliases allowed - try again with your real name - DISCONNECTING"];
  if[challenge;
    if[not count edf:edf where (not `~/:edf)and 99<type each edf:x,y;
      :fail"WARNING - No dyadic encryption/decryption functions names 'enc' and 'dec' found.\\n Function should be dyadic and should take key and message as args.\\n e.g. enc[3233 17;\\\"hello\\\"], dec[3233 413;2170 1313 745 745 2185]\\n DISCONNECTING"];
    if[not all 2=count'[get'[edf][;1]];
      :fail "WARNING - enc and dec should be dyadic, taking to key components as a list, and the message to <en|de>crypt, e.g. enc[3233 17;\\\"hello\\\"] - DISCONNECTING"];];
  neg[.z.w]"-1\"Please enter PUBLIC KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"";
  neg[.z.w]({`.z.pi set {neg[x](`getpubkey;$[like[i:-1_y;"`:*"]; first @[read0;`$1_i;"wrong"];i])}[value `.z.w]};`);};

/Take care of handle and lingering data if something goes wrong
fail:{neg[.z.w]"-1\"",x,"\"";
  if[not challenge;
    neg[.z.w]({.[`.;();_;`dec]};`);
    neg[.z.w]({.[`.;();_;`enc]};`)];
  neg[.z.w](system;"x .z.pi");
  :neg[.z.w]"hclose value `.z.w";};

testphrase:"testphrase if you are reading this something has gone wrong TESTPHRASE$%£!$)(854&$!~@:<>?,/.;#']["

/get and check public key, and prepare private key status
getpubkey:{
  if[not all x in .Q.n," ";:fail"WARNING - Incorrect Input - DISCONNECTING"];
  @[`tpks;.z.u;:;"J"$" "vs x];
  if[not all (not any null r;not desc[r]in forbiddenkeys;2=count r;7h=type r:tpks .z.u);:fail"WARNING - Incorrect Input - DISCONNECTING"];
  neg[.z.w]"-1$[`pri in key hsym `$getenv[`HOME],\"/.homerchat\";\"Found local private key from last session - re-use (enter/n)?\";\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"]";
  neg[.z.w]({`.z.pi set y@value x}[`.z.w];nspk);};

/get and check private key on client only
nspk:{
  if[`pri in key hsym `$getenv[`HOME],"/.homerchat";
  if["\n"=first y;
    `prikey set get hsym `$getenv[`HOME],"/.homerchat/pri";
    :neg[x](`testdec;`)];
  -1"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:";
  y:,[read0 0;"\n"]];
  `prikey set r:"J"$" "vs $[like[i:-1_y;"`:*"];first @[read0;hsym`$1_i;"wrong"];i];
  if[not all (not any null r;2=count r;7h=type r);
    -1"WARNING - Input Incorrect - DISCONNECTING";
    system"x .z.pi";
    :hclose x];
  system"x .z.pi";
  neg[x](`testdec;`);}

/test decryption matches sent test string. Use efficient enc/dec if challenge off
testdec:{
  neg[.z.w]"-1\"Testing decryption - waiting on return message:\"";
  if[not challenge;
    neg[.z.w]({`enc set x};ec);
    neg[.z.w]({`dec set x};dc);];
  neg[.z.w]({neg[.z.w](`checkphrase;.[dec;(prikey;x);"FAILURE"])};(ec[tpks .z.u;testphrase]));
  neg[.z.w]({neg[.z.w](`testenc;`)};`);};

/check matching testphrase
checkphrase:{
  if[c:testphrase~"c"$x;
    if[record;
      `connectedusers insert (.z.P;.z.u);
      `:cu set connectedusers]
    ;neg[.z.w]"-1\"Test successful.\""];
  if[not c;
    .[`tpks;();_;.z.u];
    :fail"WARNING - Incorrect Input - DISCONNECTING"];};

/similar check on encryption
testenc:{
  neg[.z.w]"-1\"Testing encryption - waiting on return message:\"";
  neg[.z.w](set;`chatkey;chatpubkey);
  neg[.z.w]({neg[.z.w](`finalcheck;.[enc;(chatkey;x);"FAILURE"])};(testphrase));
  neg[.z.w]({`.z.pi set {neg[x](`chatter;enc[chatkey;-1_y]);-1"\033[F\r\033[0J\033[F\r";}[value `.z.w]};`);
  };

/if everything checks out, permanently record public key and cache of encrypted values
/clients must have a .z.ps which allows chat or command based on leading integer
finalcheck:{
  if[c:testphrase~"c"$.[dc;(chatprikey;x);"FAILURE"];
    @[`ccache;.z.u;:;ec[tpks .z.u;"c"$til 1000]];
    `:ccache set ccache;
    @[`aw;.z.u;:;.z.w];
    @[`pks;.z.u;:;tpks .z.u];
    `:pks set pks;
    neg[.z.w]"-1\"Test successful - Chat enabled. Type \\\\h for help.\""];
    neg[.z.w]"hsym[`$pkl:getenv[`HOME],\"/.homerchat/pri\"]set prikey;system \"chmod 600 \",pkl";
  if[not c;
    .[`tpks;();_;.z.u];:fail"WARNING - Incorrect Input - DISCONNECTING"];
  neg[.z.w](set;`.z.ps;{if[0=x 0;:-1@"c"$dec[prikey;1_x]];if[1=x 0;:value"c"$dec[prikey;1_x]]});
  neg[value[hs]]@'0,'ccache[key[hs:aw _ aw?.z.w]]@\:string[.z.u]," has joined";};

/check last message time for display
msgtime:{
  if[lastmsg within .z.P-"v"$120 60;
    neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GLast message at: ",string lastmsg;
    lastmsg::0Np];
  `cron insert (.z.P+"v"$10;`msgtime;`);}
msgtime`

/main access function from chat clients
chatter:{tf[tf?tf 3$"c"$r][r:dc[chatprikey;x];.z.w;.z.u];};

coldict:(``default`black`red`green`yellow`blue`magenta`cyan`gray`lightred`lightgreen`lightmagenta`lightcyan`lightgray`darkgray`white!(" \033[0m";" \033[0m";" \033[1;30m";" \033[1;31m";" \033[1;32m";" \033[1;33m";" \033[1;34m";" \033[1;35m";" \033[1;36m";" \033[1;37m";" \033[01;31m";" \033[01;32m";" \033[01;35m";" \033[01;36m";" \033[00;37m";" \033[01;30m";" \033[01;37m"));

/broadcast, namedcast, returncast
bc:{neg[value[aw]]@'0,'ccache[key[aw]]@'x}
nc:{neg[aw y]@'z,'ccache[y]@\:x}
rc:{neg[y]@z,ccache[aw?y]x}

uct:{ucol[.z.u;0],x,ucol[.z.u;1]};
ucn:{ucol[x;0],y,ucol[x;1]};

/main chat - default action
chat:{[x;y;z]lastmsg::.z.P;bc uvol[key aw],\:"\033[G",uct["[",$[10;string z],"]:"],x;};

quit:{[x;y;z]rc[;y;1]"j"$"exit 0"};

help:{[x;y;z]rc[;y;0]"j"$"\033[GMessage typed without prefix are automatically broadcast to all logged in users.\nUseful functions are called with \\X or \\X input, where X is a lower case letter, e.g. '\\q' to quit"}

clrs:{[x;y;z]if[not(`$3_"c"$x) in key coldict;:rc[;y;0]"j"$"Incorrect colour"];
  @[`ucol;z;:;(coldict `$3_"c"$x;"\033[0m ")];
  `:ucol set ucol;
  :rc[;y;0]"j"$"\033[GColour set. Fabulous."};

uvol:![users;()]:\:""

vlme:{[x;y;z]@[`uvol;z;{("";"\007")x~""}];rc[;y;0]"\033[G",$[count uvol z;"Bell on";"Bell off"];}

/chat action dictionary - should be appended to to add extra functions
tf:("";"\\q ";"\\h ";"\\c ";"\\v ")!(chat;quit;help;clrs;vlme);

/handy function - call before exiting
shutdown:{quit["";;""]each value aw}

ec:dc:{{$[any y*c:mod[x*x;z 1];mod[c*z 0;z 1];c]}[;;("j"$y;x 0)]/[1;?[a;1b]_a:0b vs x 1]}
