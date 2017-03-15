#ifndef MIL_H
#define MIL_H

#include <iostream>

//declare temp in mil code
void milDeclare(string name){
  cout << ". " << name << endl;
}

//handles arithmetic, comparison, and logical operators
void milCompute(string opr, string dst, string src1){
  cout << opr << " " << dst << ", " << src1 << endl;
}

//handles arithmetic, comparison, and logical operators
void milCompute(string opr, string dst, string src1, string src2){
  cout << opr << " " << dst << ", " << src1 << ", " << src2 << endl;
}

#endif
