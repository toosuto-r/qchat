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
  if[not any null raze b;:b];
  if[not " " in b[;c];c:first 1?where " "in/:flip b];                                   / make sure column isn't full
  b[last where b[;c]=" ";c]:("X";"O")p;      / place piece
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
/
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
\
/ move to next turn
step:{[]
  neg[value[`..aw]pl]@'2,'(cc:value`..ccache)[pl:raze value[`..plyr]`c4]@\:raze "\033[1;1H\033[J",bnr,"\n\033[J\n\033[J\n\033[J\n\033[J\n\033[J\n\033[J\n\033[J\n\033[J";
  neg[value[`..aw]pl]@'2,'cc[pl]@\:"\033[15H\033[JTeam ",string[1+value[`..turn][`c4]mod 2],"'s Turn\n\nCurrent board:\n\n",sv["\n";" ",/:disp b],"\n";
  neg[value[`..aw]pl]@'2,'cc[pl]@'raze'["\033[28H\033[J",/:("Enter column to make a move. You have ",string[value[`..turnlengths]`c4]," seconds:\n";"The other team is moving.\n")raze count'[value[`..plyr]`c4]#'mod[value[`..turn][`c4]+0 1;2]];
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
  pb:b;                                                                                         / store previous board
  b::.[move;(curplayer;0|("I"$x)&7;b)];
  if[pb~b;:()];
  if[checkboard[b] or 0=count value[`..plyr][`c4;not curplayer];                                                                             / check for a winner
    record[;;;moves;0b] . (value[`..plyr]`c4)@0 1,curplayer;
    neg[value[`..aw]pl]@'2,'value[`..ccache][pl:raze value[`..plyr]`c4]@\:raze"\033[15H\033[JTeam ",string[1+curplayer]," wins!\n\nWinning board:\n\n",("\n" sv disp b),"\n\nGame Over, exiting...\n";
    value[`..resetgame]`c4;
    :b::6#enlist 7#" ";];
  if[not any " " in/:b;                                                                         / if no spaces & no one has one, it's a draw
    :neg[value[`..aw]pl]@'2,'value[`..ccache][pl:raze value[`..plyr]`c4]@\:raze"\033[15H\033[J","Tied game!\n\n",("\n" sv disp b),"\n\nGame Over, exiting...\n";
    value[`..resetgame]`c4;
    :b::6#enlist 7#" ";];
  curplayer::1 0@curplayer;
  step[];
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
