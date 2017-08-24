\c 23 1000
/screen dimensions
w:"I"$raze system"tput cols";
h:"I"$raze system"tput lines";
timer:0.05
/hide the cursor
1"\033[?25l";

/show the cursor again on exit
.z.exit:{1"\033[?25h"}


riser:{1"\033[",string[x],";",string[y],"H|\033[",string[h],";0H";
       1"\033[",string[x+1],";",string[y],"H|\033[",string[h],";0H";
       if[h>x+1;1"\033[",string[x+2],";",string[y],"H \033[",string[h],";0H"];
       system"sleep ",string timer;};

burst:{[x;y;r;s]{1"\033[",x,";",y,"H",z;}./:,'[string[flip(x+r*0 0 1 1 1 -1 -1 -1;y+r*1 -1 1 0 -1 1 0 -1)];s]}
flash:{1"\033[",string[h-x 0],";",string[x 1],"H";
   1"\033[31m*\033[0m";
   system"sleep 0.01";
   1"\033[",string[h-x 0],";",string[x 1],"H";
   1"\033[31m \033[0m";};
trails:enlist each "\033[31m",/:"--\\|//|\\",\:"\033[0m"
stars:trails:\:enlist "\033[31m*\033[0m"

riser[;w div 2]each (h-til h div 2);
1"\033[",string[2+h-h div 2],";",string[w div 2],"H ";
system"sleep ",string timer;
1"\033[",string[1+h-h div 2],";",string[w div 2],"H ";
{burst[h div 2;w div 2;x-2;" "];
  burst[h div 2;w div 2;x-1;trails];
  burst[h div 2;w div 2;x;stars];
  system"sleep ",string timer}'[2+til h div 3];
system"sleep 0.25";
burst[h div 2;w div 2;;" "]'[-2#2+til h div 3];
flash'[flip 100?/:(h div 2;w div 2)+\:{x+til y-x}. -1 1*h div 3];
1"\033[",string[h],";0H";
-1"\033[?25h";

