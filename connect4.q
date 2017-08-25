// Connect4 Multiplayer Game
/ TODO
/ DONE  Animate board in-place
/ WIP   Better win celebration (fireworks?) - see fw.q
/       Change "player 1" and "player 2" to usernames
/       Close if one player quits or server exits (ADD QUIT RECORD TO LB TABLE)
/ DONE  Maintain on-disk leaderboard? (in case of quit, award win to non-quitter) ([] p1:`$();p2:`$();w:`$();m:`int$();q:`boolean$())
/       Add "testing" mode where results aren't recorded (auto-enable in case of both players having same username)


players:()!()                                                   / dict for handle!username
curplayer:0                                                     / player 1 starts
moves:0                                                         / moves counter
rec:1b                                                          / flag to enable recording, default to true

b:b:6#enlist 7#" ";                                             / initial empty board
colr:{ssr[;y;"\033[3",z,"m",y,"\033[0m"]'[x]}/[;"XO";"12"]      / colour-ise board
disp:{[b] colr a,("|",'b,'"|"),(a:enlist[9#"-"]),enlist[" 0123456 "]} / function to display board

move:{[p;c;b] /p:player,c:column,b:board
  if[not " " in b[;c];'full];                                   / make sure column isn't full
  b[last where b[;c]=" ";c]:$[1=value[players]?p;"X";"O"];      / place piece
  :b;                                                           / return updated board
 }

bnr:"#################################################\n",
    "#   _____                            _   _  _   #\n",
    "#  / ____|                          | | | || |  #\n",
    "# | |     ___  _ __  _ __   ___  ___| |_| || |_ #\n",
    "# | |    / _ \\| '_ \\| '_ \\ / _ \\/ __| __|__   _|#\n",
    "# | |___| (_) | | | | | | |  __/ (__| |_   | |  #\n",
    "#  \\_____\\___/|_| |_|_| |_|\\___|\\___|\\__|  |_|  #\n",
    "#                                               #\n",
    "#################################################\n";


st:{-1 "\033[H\033[J",y,"\nYou are player ",string[x],"\nType \"quit\" to exit\n";if[2>x;-1"Waiting for second player...\n\n"];}[;bnr]    / startup message
pi:{[h;x] $[x~enlist "\n";"\n";x~"quit\n";exit 0;[h(`play;x);"move sent\n"]]};                                                  / .z.pi for players
dis:{-1"Too many players connected";exit 0;}                                                                                    / disconnect extras
\
/ initial setup when someone connects
.z.po:{
  if[.z.u=`lb;(neg .z.w)(-1;"\n",.Q.s top[]);:0b];                   / if logging in with "lb" username, give them the leaderboard
  if[2=count players;(neg .z.w)(dis;`);:()];                    / disconnect if too many players
  u:`$raze .z.w(system;"whoami");                               / don't trust supplied username
  if[u in value players;u:` sv (u;`1);rec::0b];                 / in case of duplicates, generate a second name & don't record result
  players,:enlist[.z.w]!enlist[u];                              / add to players dict
  (neg .z.w)({`.z.pi set x@neg .z.w};pi);                       / set .z.pi for player
  (neg .z.w)(st;count players);                                 / send startup message
  if[2=count players;turn[]];}                                  / if there are now two players, begin first turn

/ handle quitters
.z.pc:{players::enlist [x]_players;}                            / remove player if they quit

/ move to next turn
turn:{[]
  (neg key players)@\:(-1;"\033[15H\033[J",string[value[players]@curplayer],"'s Turn\n\nCurrent board:\n\n","\n" sv disp b);
  (neg key[players]@curplayer)(-1;"Enter column to make move:");
  moves+:1;                                                                                                                     / increment moves counter
 }

/ check if there's a winner along any line or diagonal
checkboard:{[b]
  chk:{any (4={max deltas (where differ x),count x} each x) & 4>{sum x=" "} each x};      / check a vector for win condition
  c:chk flip b;                                                                 / check cols
  r:chk      b;                                                                 / check rows
  /diagonals
  ul:{.[b] each {reverse[x],'x}til[x]} each 3_til 7;                            / upper-left   quadrant
  br:{.[b] each {reverse[x],'1+x}til[x]} each 6+til 3;                          / bottom-right quadrant
  ur:{.[b] each (0,x)+/:til[7-x]} each 1+til 3;                                 / upper-right  quadrant
  bl:{.[b] each reverse[(x-1)_til 6],'reverse[neg[x] _ til 7]} each 1+til 3;    / bottom-left quadrant
  d:chk ul,br,ur,bl;                                                            / check diagonals
  :d|c|r;
 }

/ function called by player making a move
play:{[x]
  if[curplayer <> key[players]?.z.w;(neg .z.w)(-2;"Wait your turn");:()];
  pb:b;                                                                                         / store previous board
  b::.[move;(players[.z.w];"I"$-1_x;b);{(neg .z.w)(-2;"Column full");:b}];
  if[pb~b;:()];                                                                                 / return if board unchanged i.e. full column
  if[checkboard[b];                                                                             / check for a winner
     (neg key players)@\:(-1;string[value[players]@curplayer]," wins!\n\nWinning board:\n\n",("\n" sv disp b),"\n\nGame Over, exiting...");
     record[;;;moves;0b] . value[players]@0 1,curplayer;
     (neg key players)@\:(exit;0)
    ];
  if[not any " " in/:b;                                                                         / if no spaces & no one has one, it's a draw
     (neg key players)@\:(-1;"Tied game!\n\n",("\n" sv disp b),"\n\nGame Over, exiting...");
     (neg key players)@\:(exit;0)
    ];
  curplayer::1 0@curplayer;
  turn[];
 }

/ record results of game in leaderboard
record:{[p1;p2;w;m;q] /p1:player1;p2:player2;w:winner;m:moves;q:quit
 if[rec;
  `:lb upsert (p1;p2;w;`short$m;q)];
 }

/ get leaderboard
lb:{get `:lb}

/ generate actual leaderboard
top:{`wins xdesc select wins:count i by player:w from lb[]}
