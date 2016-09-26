# Virtual Compilers
|       Title      | Algorithms | Industry | Language |   Class  |         Institution         |
|:----------------:|:----------:|:--------:|:--------:|:--------:|:---------------------------:|
| Virtual Compiler |      -     |     -    |    C++   | Complier | Univ. of Missouri-St. Louis |

P0 (Tree Traversals)
P1 (Scanner Implementation and testing)
P2 (Parser Implementation and testing using Scanner)
P3 (Full LAN to ASM compiler)

Invocation: 
```
comp <file>
```
Where <file> is some file that ends in .lan (ex. comp file would compile and generate target code for file.lan). If no file is given input will be read in from keyboard line-by-line until EOF (ctrl+d on unix/linux).

Compiler will take in code written in LAN (fake language professor came up with), and generate a target ASM file that runs on
a specialized virtual machine the professor provided. (A simple single-accumulator based assembler.)

LAN LANGUAGE:
```
<program>  ->      PROGRAM <var> <block> 
<block>    ->      { <var> <stats> }
<var>      ->      empty | <type> Identifier <mvars> ;
<type>     ->      INTEGER
<mvars>    ->      empty | , Identifier <mvars>
<expr>     ->      <T> + <expr> | <T> - <expr> | <T>
<T>        ->      <F> * <T> | <F> / <T> | <F>
<F>        ->      - <F> | <R>
<R>        ->      (<expr>) | Identifier | Number   
<stats>    ->      <stat>  <mStat>
<mStat>    ->      empty | <stat>  <mStat>
<stat>     ->      <in> | <out> | <block> | <if> | <loop> | <assign>
<in>       ->      SCAN Identifier ;
<out>      ->      PRINT <expr>  ;
<if>       ->      IF ( <expr> <RO> <expr>)  THEN <block>             
<loop>     ->      LOOP ( <expr> <RO> <expr> ) <block>
<assign>   ->      Identifier = <expr> .
<RO>       ->      => | =< | == |  > | <  |  !=
```
