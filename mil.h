#ifndef MIL_H
#define MIL_H

#include <iostream>

//generates mil instructions
string milGenInstruction(string instr, string arg1){
  return instr + " " + arg1 + "\n";
}

string milGenInstruction(string instr, string arg1, string arg2){
  return instr + " " + arg1 + ", " + arg2 + "\n";
}

string milGenInstruction(string instr, string arg1, string arg2, string arg3){
  return instr + " " + arg1 + ", " + arg2 + ", " + arg3 + "\n";
}


//declare temp in mil code
string milDeclare(string name){
  return milGenInstruction(".", name);
}

//handles arithmetic, comparison, and logical operators
string milCompute(string opr, string dst, string src1){
  return milGenInstruction(opr, dst, src1);
}

//handles arithmetic, comparison, and logical operators
string milCompute(string opr, string dst, string src1, string src2){
  return milGenInstruction(opr, dst, src1, src2);
}

//call function
string milFunctionCall(string name, string dst){
  return milGenInstruction("call", name, dst);
}

void codeGenError(string rulename, int ruleNum){
  cout << endl << "ERROR in " << rulename << " rule " << ruleNum
       << endl << endl;
  //exit(-1);
}

#endif
