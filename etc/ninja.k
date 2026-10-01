/ filesystem
dir:{b:(~*@[!;;:])'d:!x;.+(`dir`name;(b;d))} / get dir as a map
ddirm:{@[dir x;`dir`name]}                   / destruct dir map
dirs:{(d 1)@&*d:ddirm x}                     / get all dir names in a path
files:{(d 1)@&~*d:ddirm x}                   / get all file names in a path

/ util
J:{[s;x]$[0=#x;();{x,s,y}/x@&(~0~#)'x]} / join x by s
sp:J@" ";nl:J@"\n"                      / join x by various delims

/ simple bool flag cli args
/ also takes 1_5#x (ie - + a three char short flag)
BA:{(A@1_5#x)|(A:in[;.z.i])@x}
rel:BA"--release" / release flags
nat:BA"--native"  / ie not cosmo

/ flags and compile options
F:.((`title;  title:  "pcba")                            / project title
    (`o;      o:      "o/")                              / output dir
    (`nat;    nat:    BA"--native")                      / cli flags
    (`rel;    rel:    BA"--release")                     / ^^^
    (`cc;     cc:     $[nat;"clang";"ape/bin/cosmocc"])  / c compiler
    (`ar;     ar:     $[nat;"ar";"ape/bin/ar.ape"])      / obj archiver
    (`cflags; cflags: sp("-Iinc -fno-omit-frame-pointer" / cflags / nightmare
                         $[nat;"-march=native";"-mcosmo -DCOSMO"]
                         $[rel;"-O3"
                           sp($[nat;"-mdbg";""];"-g -O0 -DDBG")])))

/ src files, paths, etc
stem:*"."_
ext:{[e;x]e~|(#e)#|x}                      / x has extension e
srcs:{[e;x]d@&ext[e]'d:(x,)'files x}       / src files with ext e in dir p
libs:@[c:srcs[".c";];"lib/"];bins:c@"bin/" / c src files in various dirs

/ make paths & outputs
outof:"$o/",                          / make an output file
objof:{outof@(stem x),".o"}           / make an output obj file
libof:{outof"lib/lib",stem[x],".a"}   / make a static library
exeof:{(stem x),$[nat;".exe";".com"]} / make an exe according to $[nat;;]

/ ninja rules
R:{[d;R;c] / make a rule: [depfile?;rule;command]
   nl("rule ",R
      "  command = ",c
      $[d;"  depfile = $out.d";""])} / only use d=1 if $out.d is specified!!
br:R@0;dr:R@1 / basic rule, depfile rule

/ build statements
bu:{[R;x;y]"build ",x,": ",R," ",sp y} / build statement generator [rule;out;in]
cc:bu@"cc";ln:bu@"ln";ar:bu@"ar"       / compile c, link, static lib

/ generate rules
rules:nl(dr["cc";"$cc -c $cflags -MD -MF $out.d -o$out $in"] / c -> o
         br["ln";"$ln $cflags -o$out $in"]                   / o -> exe
         br["ar";"$ar rcs $out $in"])                        / o -> a

/ generate build statements based on the files on hand
mkobj:{cc[y;,x]}                  / make a cc build statement
libbs:libs mkobj'libos:objof'libs / lib objs
binbs:bins mkobj'binos:objof'bins / bin objs

/ generate build statements for linked code
slib:ar[libof"$title";libos]        / link the main static lib
exes:binos{cc[y;,x]}'es:exeof'binos / link all exes

/ print all our generated data
`0:nl@out:(nl@{$[x]," = ",$F x}'!F / vars from flag map
           rules                   / rules
           nl libbs;nl binbs       / objs
           nl exes;slib            / link
           "default ",(sp es)," ",(libof"$title"));
`0:,"\n"
\\
