#ifndef MIL_H
#define MIL_H

#include <iostream>

//generates mil instructions
void milGenInstruction(string instr, string arg1){
  cout << instr << " " << arg1 << endl;
}

void milGenInstruction(string instr, string arg1, string arg2){
  cout << instr << " " << arg1 << ", " << arg2 << endl;
}

void milGenInstruction(string instr, string arg1, string arg2, string arg3){
  cout << instr << " " << arg1 << ", " << arg2 << ", " << arg3 << endl;
}


//declare temp in mil code
void milDeclare(string name){
  milGenInstruction(".", name);
}

//handles arithmetic, comparison, and logical operators
void milCompute(string opr, string dst, string src1){
  milGenInstruction(opr, dst, src1);
}

//handles arithmetic, comparison, and logical operators
void milCompute(string opr, string dst, string src1, string src2){
  milGenInstruction(opr, dst, src1, src2);
}

//call function
void milFunctionCall(string name, string dst){
  milGenInstruction(name, dst);
}

void codeGenError(string rulename, int ruleNum){
  cout << endl << "ERROR in " << rulename << " rule " << ruleNum
       << endl << endl;
  exit(-1);
}

#endif
